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
        
        group.post(ChallengeInfoContainer.self, at: "updateChallengeInfo", use: updateChallengeInfoHandler)
        group.post(ChallengeLogContainer.self, at: "updateChallengeLog", use: updateChallengeLogHandler)
        
        group.get("getChallengeInfo", use: getChallengeInfoHandler)
        group.get("getChallengeLog", use: getChallengeLogHandler)
        group.get("getGameChallengeLog", use: getGameChallengeLogHandler)
        
    }
    
}


private extension User {
    
    func user(with digest: BCryptDigest) throws -> User {
        return try User(userID: UUID().uuidString, account: account, password: digest.hash(password))
    }
}

extension ChallengeController {
    
    //TODO: 获取挑战信息
    func getChallengeInfoHandler(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .error,
                                                                       message: "缺少 token 参数").encode(for: req)
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
    
    //TODO: 获取全部游戏挑战记录
    func getChallengeLogHandler(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .error,
                                                                       message: "缺少 token 参数").encode(for: req)
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
    
    //TODO: 获取指定游戏挑战记录
    func getGameChallengeLogHandler(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
                                        return try ResponseJSON<Empty>(status: .error,
                                                                       message: "缺少 token 参数").encode(for: req)
        }
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "缺少 gameID 参数").encode(for: req)
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
    
    //TODO: 更新挑战信息
    func updateChallengeInfoHandler(_ req: Request,container: ChallengeInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return ChallengeInfo
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .first()
                    .flatMap({ (existInfo) in
                        
                        let challengeInfo: ChallengeInfo?
                        if var existInfo = existInfo { //存在则更新。
                            challengeInfo = existInfo.update(with: container)
                        } else {
                            challengeInfo = ChallengeInfo(id: nil,
                                                          userID: existToken.userID,
                                                          wordRanking: nil,
                                                          rankingChange: nil,
                                                          challengeTime: container.challengeTime,
                                                          score: container.score,
                                                          grade: container.grade,
                                                          rewscore: container.rewscore,
                                                          cawscore: container.cawscore,
                                                          inwscore: container.inwscore,
                                                          mewscore: container.mewscore,
                                                          spwscore: container.spwscore,
                                                          crwscore: container.crwscore)
                        }
                        
                        return (challengeInfo!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "更新成功").encode(for: req)
                        }))
                    })
            })
    }
    
    //TODO: 更新挑战记录
    func updateChallengeLogHandler(_ req: Request,container: ChallengeLogContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return ChallengeLog
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .first()
                    .flatMap({ (existInfo) in
                        
                        let challengeLog: ChallengeLog?
                        challengeLog = ChallengeLog(userID: existToken.userID,
                                                    gameID:container.gameID,
                                                    score: container.score)
                        
                        return (challengeLog!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "更新成功").encode(for: req)
                        }))
                    })
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

struct ChallengeInfoContainer: Content {
    
    var token:String
    
    var challengeTime: Int?
    var score: Int?
    var grade: String?
    
    var rewscore: Int?
    var cawscore: Int?
    var inwscore: Int?
    var mewscore: Int?
    var spwscore: Int?
    var crwscore: Int?
    
}

struct ChallengeLogContainer: Content {
    
    var token:String
    var gameID:String
    
    var score: Int
    
}

