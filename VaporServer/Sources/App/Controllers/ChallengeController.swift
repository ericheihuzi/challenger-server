//
//  ChallengeController.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/26.
//

import Vapor
import Crypto
import Authentication

final class ChallengeController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        let group = router.grouped("challenges")
        
        group.get("getChallengeInfo", use: getChallengeInfoHandler) // 获取挑战信息
        group.get("getChallengeLog", use: getChallengeLogHandler) // 获取挑战记录
        group.get("getGameChallengeLog", use: getGameChallengeLogHandler) // 获取指定游戏挑战记录
        group.get("getTodayWorldRanking", use: getTodayWorldRankingHandler) // 获取全部游戏的当日排名列表
        group.get("getWorldRanking", use: getWorldRankingHandler) // 获取全部游戏的排名列表
        group.get("getGradeList", use: getGradeHandler) // 获取段位列表
    }
    
}


private extension User {
    
    func user(with digest: BCryptDigest) throws -> User {
        return try User(userID: UUID().uuidString, account: account, password: digest.hash(password))
    }
}

extension ChallengeController {
    
    //MARK: 获取挑战信息
    func getChallengeInfoHandler(_ req: Request) throws -> Future<Response> {

        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .missesToken).encode(for: req)
        }

        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in

                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }

                let first = ChallengeInfo
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .first()

                return first.flatMap({ (existInfo) in
                    guard let existInfo = existInfo else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "挑战信息为空").encode(for: req)
                    }
                    return try ResponseJSON<ChallengeInfo>(data: existInfo).encode(for: req)
                })
            })
    }
    
    //MARK: 获取全部游戏挑战记录
    func getChallengeLogHandler(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .missesToken).encode(for: req)
        }
        
        let bearToken = BearerAuthorization(token: token)
        
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let all = ChallengeLog
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .all()
                
                return all.flatMap({ (log) in
                    let logList = log.compactMap({ ChallengeLog -> ChallengeLog in
                        var w = ChallengeLog;w.id = nil;return w
                    })
                    return try ResponseJSON<[ChallengeLog]>(data: logList).encode(for: req)
                })
            })
    }
    
    //MARK: 获取指定游戏挑战记录
    func getGameChallengeLogHandler(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .missesToken).encode(for: req)
        }
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "Missing `token` parameter").encode(for: req)
        }
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                let all = ChallengeLog
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .filter(\.gameID == gameID)
                    .all()
                
                return all.flatMap({ (log) in
                    let logList = log.compactMap({ ChallengeLog -> ChallengeLog in
                        var w = ChallengeLog;w.id = nil;return w
                    })
                    return try ResponseJSON<[ChallengeLog]>(data: logList).encode(for: req)
                })
            })
    }
    
    //MARK: 获取全部游戏的当日排名列表
    func getTodayWorldRankingHandler(_ req: Request) throws -> Future<Response> {
        
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: nowDate)
        
        return ChallengeInfo
            .query(on: req)
            .filter(\.date == date)
            .sort(\.maxscore,.descending) //ascending or descending:升序或降序
            .all()
            .flatMap({ (info) in
                let infoList = info.compactMap({ ChallengeInfo -> ChallengeInfo in
                    var w = ChallengeInfo;w.id = nil;return w
                })
                return try ResponseJSON<[ChallengeInfo]>(data: infoList).encode(for: req)
            })
    }
    
    //MARK: 获取全部游戏的排名列表
    func getWorldRankingHandler(_ req: Request) throws -> Future<Response> {
        
        return ChallengeInfo
            .query(on: req)
            .sort(\.maxscore,.descending) //ascending or descending:升序或降序
            .all()
            .flatMap({ (info) in
                let infoList = info.compactMap({ ChallengeInfo -> ChallengeInfo in
                    var w = ChallengeInfo;w.id = nil;return w
                })
                return try ResponseJSON<[ChallengeInfo]>(data: infoList).encode(for: req)
            })
    }
    
    //MARK: 获取段位列表
    func getGradeHandler(_ req: Request) throws -> Future<Response> {
        return Grade
            .query(on: req)
            .all()
            .flatMap({ (grade) in
                let list = grade.compactMap({ Grade -> Grade in
                    var w = Grade
                    w.id = nil
                    return w
                })
                return try ResponseJSON<[Grade]>(data: list).encode(for: req)
            })
    }
    
    //MARK: 获取全部游戏的参与人数
    func getChallengeNumHandler(_ req: Request) throws -> Future<Response> {
        
        return ChallengeInfo
            .query(on: req)
            .sort(\.maxscore,.descending) //ascending or descending:升序或降序
            .all()
            .flatMap({ (info) in
                let num = info.count
                return try num.encode(for: req)
            })
    }
    
}



fileprivate struct TokenContainer: Content {
    var token: String
}

fileprivate struct PasswordContainer: Content {
    var account: String
    var password: String
    var newPassword: String
    
}

fileprivate struct AccessContainer: Content {
    
    var accessToken: String
    var userID:String?
    
    init(accessToken: String,userID: String? = nil) {
        self.accessToken = accessToken
        self.userID = userID
    }
}
