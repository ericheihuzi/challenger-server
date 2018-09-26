//
//  GameController.swift
//  APP
//
//  Created by 黑胡子 on 2018/9/13.
//

import Vapor
import Crypto
import Authentication

final class GameController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let group = router.grouped("games")
        
        group.post(UserGameInfoContainer.self, at: "updateUserGameInfo", use: updateUserGameInfoHandler)
        group.post(ActorContainer.self, at: "updateGameActor", use: updateGameActorHandler)
        
        group.get("getGameList", use: getGameListHandler)
        group.get("getGameInfo", use: getGameInfoHandler)
        group.get("getUserGameInfo", use: getUserGameInfoHandler)
        group.get("icon",String.parameter, use: getGameIconHandler)
        group.get("cover",String.parameter, use: getGameCoverHandler)
        
        group.get("getGameActor", use: getGameActorHandler)
        group.get("getGameRanking", use: getGameRankingHandler)
        group.get("getTodayWorldRanking", use: getTodayWorldRankingHandler)
        group.get("getGameJoin", use: getGameJoinHandler)
    }
    
}

extension GameController {
    
    //TODO: 更新用户指定游戏的信息
    func updateUserGameInfoHandler(_ req: Request,container: UserGameInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return UserGameInfo
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .filter(\.gameID == container.gameID)
                    .first()
                    .flatMap({ (existInfo) in
                        
                        let userGameInfo: UserGameInfo?
                        if var existInfo = existInfo { //存在则更新。
                            userGameInfo = existInfo.update(with: container)
                        } else {
                            userGameInfo = UserGameInfo(id: nil,
                                                          userID: existToken.userID,
                                                          gameID: container.gameID,
                                                          ispay: container.ispay,
                                                          newscore: container.newscore,
                                                          maxscore: container.maxscore,
                                                          level: container.level,
                                                          ranking: nil,
                                                          rankingChange: nil,
                                                          rescore: container.rescore,
                                                          cascore: container.cascore,
                                                          inscore: container.inscore,
                                                          mescore: container.mescore,
                                                          spscore: container.spscore,
                                                          crscore: container.crscore)
                        }
                        
                        return (userGameInfo!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "更新成功").encode(for: req)
                        }))
                    })
            })
    }
    
    //TODO: 获取游戏列表
    func getGameListHandler(_ req: Request) throws -> Future<Response> {
        
        return GameInfo
            .query(on: req)
            .all()
            .flatMap({ (game) in
                let gameList = game.compactMap({ GameInfo -> GameInfo in
                    var w = GameInfo
                    w.id = nil
                    return w
                })
                return try ResponseJSON<[GameInfo]>(data: gameList).encode(for: req)
            })
    }
    
    //TODO: 获取指定游戏信息
    func getGameInfoHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "缺少 gameID 参数").encode(for: req)
        }
        
        let first = GameInfo
            .query(on: req)
            .filter(\.gameID == gameID)
            .first()
        
        return first.flatMap({ (existInfo) in
            guard let existInfo = existInfo else {
                return try ResponseJSON<Empty>(status: .error,
                                               message: "游戏信息为空").encode(for: req)
            }
            return try ResponseJSON<GameInfo>(data: existInfo).encode(for: req)
        })

    }
    
    //TODO: 获取用户游戏信息
    func getUserGameInfoHandler(_ req: Request) throws -> Future<Response> {
        
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
                
                let first = UserGameInfo
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .filter(\.gameID == gameID)
                    .first()
                
                return first.flatMap({ (existInfo) in
                    guard let existInfo = existInfo else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "用户游戏信息为空").encode(for: req)
                    }
                    return try ResponseJSON<UserGameInfo>(data: existInfo).encode(for: req)
                })
            })
    }
    
    //TODO: 获取游戏图标
    func getGameIconHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.gameIcon, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error, message: "图片不存在")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    //TODO: 获取游戏封面
    func getGameCoverHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.gameCover, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error, message: "图片不存在")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    //TODO: 获取指定游戏的排名列表
    func getGameRankingHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "缺少 gameID 参数").encode(for: req)
        }
        
        return Actor
            .query(on: req)
            .filter(\.gameID == gameID)
            .sort(\.score,.descending) //ascending or descending:升序或降序
            .all()
            .flatMap({ (actor) in
                let actorList = actor.compactMap({ Actor -> Actor in
                    var w = Actor;w.id = nil;return w
                })
                return try ResponseJSON<[Actor]>(data: actorList).encode(for: req)
            })
    }
    
    //TODO: 获取指定游戏的参与者列表
    func getGameActorHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "缺少 gameID 参数").encode(for: req)
        }
        
        return Actor
            .query(on: req)
            .filter(\.gameID == gameID)
            .all()
            .flatMap({ (actor) in
                let actorList = actor.compactMap({ Actor -> Actor in
                    var w = Actor;w.id = nil;return w
                })
                return try ResponseJSON<[Actor]>(data: actorList).encode(for: req)
            })
    }
    
    
    //TODO: 获取指定游戏的参与人数
    func getGameJoinHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "缺少 gameID 参数").encode(for: req)
        }
        
        return Actor
            .query(on: req)
            .filter(\.gameID == gameID)
            .all()
            .flatMap({ (actor) in
                let join = actor.count
                //let data = ["join": join]
                return try join.encode(for: req)
                //return try ResponseJSON(data: data).encode(for: req)
            })
    }
    
    //TODO: 更新参与者信息
    func updateGameActorHandler(_ req: Request,container: ActorContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return Actor
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .filter(\.gameID == container.gameID)
                    .first()
                    .flatMap({ (existActor) in
                        
                        let actor: Actor?
                        if var existActor = existActor { //存在则更新。
                            actor = existActor.update(with: container)
                        } else {
                            actor = Actor(userID: existToken.userID,
                                          gameID: container.gameID,
                                          score: container.score,
                                          grade: container.grade,
                                          sex: container.sex,
                                          nickName: container.nickName,
                                          location: container.location,
                                          picName: container.picName)
                        }
                        
                        return (actor!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "更新成功").encode(for: req)
                        }))
                    })
            })
    }
    
    //TODO: 获取全部游戏的当日排名列表
    func getTodayWorldRankingHandler(_ req: Request) throws -> Future<Response> {
        
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.system
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: nowDate)
        
        return Actor
            .query(on: req)
            .filter(\.date == date)
            .sort(\.score,.descending) //ascending or descending:升序或降序
            .all()
            .flatMap({ (actor) in
                let actorList = actor.compactMap({ Actor -> Actor in
                    var w = Actor;w.id = nil;return w
                })
                return try ResponseJSON<[Actor]>(data: actorList).encode(for: req)
            })
    }
    
}

fileprivate struct TokenContainer: Content {
    var token: String
}

fileprivate struct AccessContainer: Content {
    
    var accessToken: String
    var userID:String?
    
    init(accessToken: String,userID: String? = nil,gameID: String? = nil) {
        self.accessToken = accessToken
        self.userID = userID
    }
}

struct GameInfoContainer: Content {
    
    var token: String
    
    var title: String?
    var iconName: File?
    var coverName: File?
    var price: Double?
    var category: String?
    //var join: Int?
    var level: Int?
    var round: Int?
    var color: String?
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
}

struct UserGameInfoContainer: Content {
    
    var token: String
    var gameID: String
    
    var ispay: Int?
    
    var newscore: Int?
    var maxscore: Int?
    
    var level: Int?
    
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
}

struct ActorContainer: Content {
    
    var token: String
    var gameID: String
    
    var score: Int?
    var grade: String?
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
    var date: String?
    var time: String?
    
}
