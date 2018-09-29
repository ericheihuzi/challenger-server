//
//  EnJobController.swift
//  App
//
//  Created by 晋先森 on 2018/8/31.
//

import Foundation
import Vapor
import SwiftSoup
import Fluent
import FluentPostgreSQL
import Authentication

class EnJobController: RouteCollection {
    
    var page = 1
    var dicts: [[String:EnJob]]?
    var currentIndex = 0
    
    func boot(router: Router) throws {
        
        router.group("enJob") { (router) in
            router.get("start", use: startParseJobHandler)
            
            router.get("list", use: getJobListHandler)
            router.get("detail", use: getJobDetailHandler)
            router.post(ApplyContext.self, at: "post", use: postJobDataHandler)
            router.get("record", use: getMyRecordHandler)
        }
        
    }
}


//MARK: API
extension EnJobController {
    
    // my apply list
    private func getMyRecordHandler(_ req: Request) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: req.token)
        
        return AccessToken.authenticate(using: token, on: req).flatMap({
            guard let exist = $0 else {
                return try ResponseJSON<String>(status: .token).encode(for: req)
            }
            return EnJobApply
                .query(on: req)
                .filter(\.userID == exist.userID)
                .query(page: req.page)
                .all()
                .flatMap({
                    return try ResponseJSON<[EnJobApply]>(data: $0).encode(for: req)
                })
        })
    }
    
    //
    private func postJobDataHandler(_ req: Request,context: ApplyContext) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: context.token)
        return AccessToken.authenticate(using: token, on: req).flatMap({
            guard let exist = $0 else {
                return try ResponseJSON<String>(status: .token).encode(for: req)
            }
            
            let apply = EnJobApply(id: nil,
                                   jobId: context.jobId,
                                   userID: exist.userID,
                                   email: context.email,
                                   name: context.name,
                                   phone: context.phone,
                                   desc: context.desc,
                                   time: Date().timeIntervalSince1970)
            
            return apply.save(on: req).flatMap({ save in
                return try ResponseJSON<String>(data: "apply success !").encode(for: req)
            })
        })
    }
    
    private func getJobListHandler(_ req: Request) throws -> Future<Response> {
        
        let company = req.query[String.self, at: "company"] ?? ""
        
        return EnJob
            .query(on: req)
            .filter(\.title ~~ req.key)
            .filter(\.company ~~ company)
            .query(page: req.page)
            .all()
            .flatMap({
            return try ResponseJSON<[EnJob]>(data: $0).encode(for: req)
        })
    }
    
    private func getJobDetailHandler(_ req: Request) throws -> Future<Response> {
        
        guard let jobId = req.query[String.self, at: "jobId"] else {
            return try ResponseJSON<String>(data: "缺少 jobId ").encode(for: req)
        }
        
        return EnJobDetail.query(on: req).filter(\.jobId == jobId).first().flatMap({
            return try ResponseJSON<EnJobDetail>(data: $0).encode(for: req)
        })
    }
    
}


private struct ApplyContext: Content {
    
    var token: String
    var jobId: String
    var email: String?
    var name: String?
    var phone: String?
    var desc: String?
    
}

//MARK: Crawler
extension EnJobController {
    
    func startParseJobHandler(_ req: Request) throws -> Future<Response> {
        
        let url = "https://www.naukri.com/part-time-jobs-\(page)"
        self.dicts = [[String:EnJob]]()
        self.currentIndex = 0
        
        return try req.client().get(url,headers: CrawlerHeader).flatMap({ response in
            
            let html = try SwiftSoup.parse(response.utf8String)
            
            let container = try html.select("div[class='container fl']")
            let group = try container.select("div[type='tuple']").array()
            
            for (_,element) in group.enumerated() {
                
                let title = try element.select("a").select("ul").text()
                let jobId = try element.attr("id")
                let link = try element.select("a").attr("href")
                let exp = try element.select("span[class='exp']").text()
                let company = try element.select("span[class='org']").text()
                let loc = try element.select("span[class='loc']").text()
                let more = try element.select("div[class='more']").text()
                let detailSoup = try element.select("div[class='other_details']")
                let salary = try detailSoup.select("span[class='salary  ']").text()
                let publisher = try detailSoup.select("div[class='rec_details']").text()
                
                let job = EnJob(id: nil,title: title,jobId: jobId, exp: exp,company: company, loc: loc, more: more, salary: salary, publisher: publisher)
                
                self.dicts?.append([link:job])
                
                _ = EnJob.query(on: req).filter(\.jobId == jobId).first().map({
                    if let exist = $0 {
                        debugPrint("\(exist.jobId) 已存在 ~~~ \(TimeManager.current())")
                    }else {
                        _ = job.save(on: req).map({
                            debugPrint("\($0.jobId) 保存成功! \(TimeManager.current())")
                        })
                    }
                })
            }
            
            if group.count == 0 {
                debugPrint("已经爬完。\(TimeManager.current())")
            }else { // 定时循环执行爬详情
                let s = TimeAmount.seconds(30)
                _ = req.eventLoop.scheduleRepeatedTask(initialDelay: s, delay: s, { (task) in
                    
                    try self.parseDetailInfoHandler(req)
                })
            }
            
            return try ResponseJSON<String>(data: "已开始").encode(for: req)
        })
    }
    
    func parseDetailInfoHandler(_ req: Request) throws {
        
        guard let dicts = self.dicts, dicts.count > currentIndex else {
            debugPrint("dict 为空，或 currentIndex 超出。\(TimeManager.current())")
            return
        }
        
        let dict = dicts[currentIndex]
        guard let url = dict.first?.key, let job = dict.first?.value else { return }
        
        let coneactUrl = "https://www.naukri.com/jd/contactDetails?file=\(job.jobId)"
        let contactResponse = try req.client().get(coneactUrl,headers: CrawlerHeader)
        let detailResponse = try req.client().get(url,headers: CrawlerHeader)
        
        _ = map(to: Void.self, contactResponse, detailResponse) { contact, detail in
            guard let conData = contact.http.body.data,let result = try JSONSerialization.jsonObject(with: conData, options: []) as? Dictionary<String, Any> else {
                return
            }
            
            var item = EnJobDetail(jobId: job.jobId)
            item.title = job.title
            item.salary = job.salary
            item.loc = job.loc
            item.company = job.company
            item.exp = job.exp
            item.publisher = job.publisher
            item.more = job.more
            
            if let fields = result["fields"] as? Dictionary<String, String> {
                let webSite = fields["Website"]
                let telPhone = fields["Telephone"]
                item.webSite = webSite
                item.telPhone = telPhone
            }
            
            let html = try SwiftSoup.parse(detail.utf8String)
            let leftSecSoup = try html.select("div[class='fl lftSec']")
            
            let views = try leftSecSoup
                .select("span[class='fr jViews']")
                .select("strong").text()
            let applys = try leftSecSoup
                .select("span[class='fr jApplys']")
                .select("strong")
                .text()
            let desc = try leftSecSoup
                .select("ul[class='listing mt10 wb']")
                .text()
            
            item.views = views
            item.applys = applys
            item.desc = desc
            
            let mtSoup = try leftSecSoup
                .select("div[class='jDisc mt20']")
                .select("p").array()
            
            let content = try mtSoup
                .compactMap({ "\(try $0.select("em").text())" + " " + "\(try $0.select("span").text())" })
                .joined(separator: "\n")
            item.content = content
            
            let tagSoup = try leftSecSoup.select("div[class='ksTags']")
                .select("font[class='hlite']")
                .array()
            let keys = try tagSoup
                .compactMap({ try $0.text() })
                .joined(separator: "|")
            
            let desiredCandidateProfile = try leftSecSoup.select("ul[class='listing mt15']").text()
            let companyProfile = try leftSecSoup.select("div[class='aboutCompany']").text()
            
            item.keys = keys
            item.desiredCandidateProfile = desiredCandidateProfile
            item.companyProfile = companyProfile
            
            _ = EnJobDetail
                .query(on: req)
                .filter(\.jobId == job.jobId)
                .first()
                .map({ exist in
                    if let exist = exist {
                        debugPrint("\(exist.jobId) 详情已存在。\(TimeManager.current())")
                    }else {
                        _ = item.save(on: req).map({
                            debugPrint("\($0.jobId) 详情已保存--------- \(TimeManager.current())")
                        })
                    }
                    
                    self.currentIndex += 1
                    
                    if  self.currentIndex == dicts.count {
                        self.page += 1
                        debugPrint("开始第\(self.page)页 \(TimeManager.current())")
                        _ = try self.startParseJobHandler(req)
                        return
                    }
                })
        }
    }
    
}






















