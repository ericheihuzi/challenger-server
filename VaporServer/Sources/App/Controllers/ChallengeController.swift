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
        
//        group.post(ChallengeInfoContainer.self, at: "updateChallengeInfo", use: updateChallengeInfoHandler)
//        group.post(ChallengeLogContainer.self, at: "updateChallengeLog", use: updateChallengeLogHandler)
        
        group.get("getChallengeInfo", use: getChallengeInfoHandler) // 获取挑战信息
        group.get("getChallengeLog", use: getChallengeLogHandler) // 获取挑战记录
        group.get("getGameChallengeLog", use: getGameChallengeLogHandler) // 获取指定游戏挑战记录
        group.get("getTodayWorldRanking", use: getTodayWorldRankingHandler) // 获取全部游戏的当日排名列表
        
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
    
//    //MARK: 更新挑战信息
//    func updateChallengeInfoHandler(_ req: Request,container: ChallengeInfoContainer) throws -> Future<Response> {
//
//        let bearToken = BearerAuthorization(token: container.token)
//        return AccessToken
//            .authenticate(using: bearToken, on: req)
//            .flatMap({ (existToken) in
//                guard let existToken = existToken else {
//                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
//                }
//
//                return ChallengeInfo
//                    .query(on: req)
//                    .filter(\.userID == existToken.userID)
//                    .first()
//                    .flatMap({ (existInfo) in
//
//                        let res = container.rewscore!
//                        let cas = container.cawscore!
//                        let ins = container.inwscore!
//                        let mes = container.mewscore!
//                        let sps = container.spwscore!
//                        let crs = container.crwscore!
//
//                        let arr = [res,cas,ins,mes,sps,crs]
//                        let score = arr.max()
//
//                        let challengeInfo: ChallengeInfo?
//                        if var existInfo = existInfo { //存在则更新。
//                            existInfo.score = score
//                            challengeInfo = existInfo.update(with: container)
//                        } else {
//                            challengeInfo = ChallengeInfo(userID: existToken.userID,
//                                                          challengeTime: container.challengeTime,
//                                                          score: score!,
//                                                          grade: container.grade,
//                                                          rewscore: container.rewscore,
//                                                          cawscore: container.cawscore,
//                                                          inwscore: container.inwscore,
//                                                          mewscore: container.mewscore,
//                                                          spwscore: container.spwscore,
//                                                          crwscore: container.crwscore,
//                                                          sex: container.sex,
//                                                          nickName: container.nickName,
//                                                          location: container.location,
//                                                          picName: container.picName)
//                        }
//
//                        return (challengeInfo!.save(on: req).flatMap({ (info) in
//                            return try ResponseJSON<Empty>(status: .ok,
//                                                           message: "Updated successfully!").encode(for: req)
//                        }))
//                    })
//            })
//    }
    
//    //MARK: 更新挑战记录
//    func updateChallengeLogHandler(_ req: Request,container: ChallengeLogContainer) throws -> Future<Response> {
//
//        let bearToken = BearerAuthorization(token: container.token)
//        return AccessToken
//            .authenticate(using: bearToken, on: req)
//            .flatMap({ (existToken) in
//                guard let existToken = existToken else {
//                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
//                }
//
//                return ChallengeLog
//                    .query(on: req)
//                    .filter(\.userID == existToken.userID)
//                    .first()
//                    .flatMap({ (existInfo) in
//
//                        let challengeLog: ChallengeLog?
//                        challengeLog = ChallengeLog(userID: existToken.userID,
//                                                    gameID:container.gameID,
//                                                    score: container.score)
//
//                        return (challengeLog!.save(on: req).flatMap({ (info) in
//                            return try ResponseJSON<Empty>(status: .ok,
//                                                           message: "Updated successfully!").encode(for: req)
//                        }))
//                    })
//            })
//    }
    
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

//struct ChallengeInfoContainer: Content {
//
//    var token:String
//
//    var challengeTime: Int?
//    var score: Int?
//    var grade: String?
//
//    var rewscore: Int?
//    var cawscore: Int?
//    var inwscore: Int?
//    var mewscore: Int?
//    var spwscore: Int?
//    var crwscore: Int?
//
//    var sex: Int?
//    var nickName: String?
//    var location: String?
//    var picName: String?
//
//    var date: String?
//    var time: String?
//
//}

//struct ChallengeLogContainer: Content {
//
//    var token:String
//    var gameID:String
//
//    var score: Int
//
//}

