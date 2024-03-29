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
        
        // 更新/添加游戏信息
        group.post(GameInfoContainer.self, at: "updateGameInfo", use: updateGameInfoHandler)
        
        // 更新用户指定游戏的信息/更新参与者信息/更新挑战信息--/更新挑战记录
        group.post(ActorInfoContainer.self, at: "updateActorInfo", use: updateActorInfoHandler)
        
        group.get("getGameList", use: getGameListHandler) // 获取游戏列表
        group.get("getGameInfo", use: getGameInfoHandler) // 获取指定游戏信息
        group.get("getUserGameInfo", use: getUserGameInfoHandler) // 获取用户游戏信息
        group.get("icon",String.parameter, use: getGameIconHandler) // 获取游戏图标
        group.get("cover",String.parameter, use: getGameCoverHandler) // 获取游戏封面
        
        group.get("getGameActor", use: getGameActorHandler) // 获取游戏参与者列表
        group.get("getGameRanking", use: getGameRankingHandler) //获取指定游戏的排名列表
        //group.get("getTodayWorldRanking", use: getTodayWorldRankingHandler) // 获取全部游戏的当日排名列表
        group.get("getGameJoin", use: getGameJoinHandler) // 获取指定游戏的参与人数
    }
    
}

extension GameController {
    
    //MARK: 更新用户指定游戏的信息/更新参与者信息/更新挑战信息--/更新挑战记录
    func updateActorInfoHandler(_ req: Request,container: ActorInfoContainer) throws -> Future<Response> {
        
        try updateChallengeInfoHandler(req, container: container).always {} //更新挑战信息
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return ActorInfo
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .filter(\.gameID == container.gameID)
                    .first()
                    .flatMap({ (existInfo) in
                        
                        let res = container.rescore!
                        let cas = container.cascore!
                        let ins = container.inscore!
                        let mes = container.mescore!
                        let sps = container.spscore!
                        let crs = container.crscore!
                        
                        let arr = [res,cas,ins,mes,sps,crs]
                        let new = arr.max() ?? 0
                        var max:Int = 0
                        
                        let oldMax = existInfo?.maxscore ?? 0
                        if new > oldMax {
                            max = new
                        } else {
                            max = oldMax
                        }
                        
                        let actorInfo: ActorInfo?
                        if var existInfo = existInfo { //存在则更新。
                            
                            existInfo.maxscore = max
                            existInfo.newscore = new
                            
                            actorInfo = existInfo.update(with: container)
                        } else {
                            actorInfo = ActorInfo(userID: existToken.userID,
                                                  gameID: container.gameID,
                                                  ispay: container.ispay,
                                                  maxscore: max,
                                                  newscore: new,
                                                  level: container.level,
                                                  rescore: container.rescore,
                                                  cascore: container.cascore,
                                                  inscore: container.inscore,
                                                  mescore: container.mescore,
                                                  spscore: container.spscore,
                                                  crscore: container.crscore,
                                                  sex: container.sex,
                                                  nickName: container.nickName,
                                                  location: container.location,
                                                  picName: container.picName)
                        }
                        
                        let challengeLog: ChallengeLog?
                        challengeLog = ChallengeLog(userID: existToken.userID,
                                                    gameID: container.gameID,
                                                    score: new)
                        
                        challengeLog!.save(on: req).always {} // 更新挑战记录
                        
                        return (actorInfo!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "Updated successfully!").encode(for: req)
                        }))
                    })
            })
    }
    
    //MARK: 更新挑战信息
    func updateChallengeInfoHandler(_ req: Request,container: ActorInfoContainer) throws -> Future<Response> {
        
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
                        
                        let res = container.rescore!
                        let cas = container.cascore!
                        let ins = container.inscore!
                        let mes = container.mescore!
                        let sps = container.spscore!
                        let crs = container.crscore!
                        
                        let arr = [res,cas,ins,mes,sps,crs]
                        let new = arr.max() ?? 0
                        var max:Int = 0
                        
                        let oldMax = existInfo?.maxscore ?? 0
                        if new > oldMax {
                            max = new
                        } else {
                            max = oldMax
                        }
                        
                        var grade: String = "段位"
                        if max >= 0 && max <= 50 {
                            grade = "石头"
                        } else if max > 50 && max <= 60 {
                            grade = "痴者"
                        } else if max > 60 && max <= 80 {
                            grade = "愚者"
                        } else if max > 80 && max <= 110 {
                            grade = "凡者"
                        } else if max > 110 && max <= 120 {
                            grade = "明者"
                        } else if max > 120 && max <= 140 {
                            grade = "灵者"
                        } else if max > 140 && max <= 150 {
                            grade = "智者"
                        } else if max > 150 && max <= 200 {
                            grade = "歌者"
                        } else if max > 200 && max <= 300 {
                            grade = "归零者"
                        }
                        
                        let oldRew = existInfo?.rewscore ?? 0
                        let oldCaw = existInfo?.cawscore ?? 0
                        let oldInw = existInfo?.inwscore ?? 0
                        let oldMew = existInfo?.mewscore ?? 0
                        let oldSpw = existInfo?.spwscore ?? 0
                        let oldCrw = existInfo?.crwscore ?? 0
                        
                        var newRew = container.rescore ?? 0
                        var newCaw = container.cascore ?? 0
                        var newInw = container.inscore ?? 0
                        var newMew = container.mescore ?? 0
                        var newSpw = container.spscore ?? 0
                        var newCrw = container.crscore ?? 0
                        
                        if newRew < oldRew { newRew = oldRew }
                        if newCaw < oldCaw { newCaw = oldCaw }
                        if newInw < oldInw { newInw = oldInw }
                        if newMew < oldMew { newMew = oldMew }
                        if newSpw < oldSpw { newSpw = oldSpw }
                        if newCrw < oldCrw { newCrw = oldCrw }
                        
                        let challengeInfo: ChallengeInfo?
                        if var existInfo = existInfo { //存在则更新。
                            
                            existInfo.maxscore = max
                            existInfo.grade = grade
                            
                            existInfo.rewscore = newRew
                            existInfo.cawscore = newCaw
                            existInfo.inwscore = newInw
                            existInfo.mewscore = newMew
                            existInfo.spwscore = newSpw
                            existInfo.crwscore = newCrw
                            
                            challengeInfo = existInfo.update(with: container)
                        } else {
                            challengeInfo = ChallengeInfo(userID: existToken.userID,
                                                          
                                                          maxscore: max,
                                                          grade: grade,
                                                          
                                                          rewscore: newRew,
                                                          cawscore: newCaw,
                                                          inwscore: newInw,
                                                          mewscore: newMew,
                                                          spwscore: newSpw,
                                                          crwscore: newCrw,
                                                          
                                                          sex: container.sex,
                                                          nickName: container.nickName,
                                                          location: container.location,
                                                          picName: container.picName)
                        }
                        
                        return (challengeInfo!.save(on: req).flatMap({ (info) in
                            return try ResponseJSON<Empty>(status: .ok,
                                                           message: "Updated successfully!").encode(for: req)
                        }))
                    })
            })
    }
    
    //MARK: 更新/添加游戏信息
    func updateGameInfoHandler(_ req: Request,container: GameInfoContainer) throws -> Future<Response> {
        
        return GameInfo
            .query(on: req)
            .filter(\.gameID == container.gameID)
            .first()
            .flatMap({ (existInfo) in
                
                var iconName: String?
                if let file = container.iconImage { //如果上传了图片，就判断下大小，否则就揭过这一茬。
                    guard file.data.count < ImageMaxByteSize else {
                        return try ResponseJSON<Empty>(status: .pictureTooBig).encode(for: req)
                    }
                    iconName = try VaporUtils.imageName()
                    let path = try VaporUtils.localRootDir(at: ImagePath.gameIcon, req: req) + "/" + iconName!
                    
                    try Data(file.data).write(to: URL(fileURLWithPath: path))
                }
                
                var coverName: String?
                if let file = container.coverImage { //如果上传了图片，就判断下大小，否则就揭过这一茬。
                    guard file.data.count < ImageMaxByteSize else {
                        return try ResponseJSON<Empty>(status: .pictureTooBig).encode(for: req)
                    }
                    coverName = try VaporUtils.imageName()
                    let path = try VaporUtils.localRootDir(at: ImagePath.gameCover, req: req) + "/" + coverName!
                    
                    try Data(file.data).write(to: URL(fileURLWithPath: path))
                }
                
                var gameInfo: GameInfo?
                if var existInfo = existInfo { //存在则更新。
                    gameInfo = existInfo.update(with: container)
                    
                    if let existIconName = existInfo.iconName,let iconName = iconName { //移除原来的图片
                        let path = try VaporUtils.localRootDir(at: ImagePath.gameIcon, req: req) + "/" + existIconName
                        try FileManager.default.removeItem(at: URL.init(fileURLWithPath: path))
                        gameInfo?.iconName = iconName
                    } else if gameInfo?.iconName == nil {
                        gameInfo?.iconName = iconName
                    }
                    
                    if let existCoverName = existInfo.coverName,let coverName = coverName { //移除原来的图片
                        let path = try VaporUtils.localRootDir(at: ImagePath.gameCover, req: req) + "/" + existCoverName
                        try FileManager.default.removeItem(at: URL.init(fileURLWithPath: path))
                        gameInfo?.coverName = coverName
                    } else if gameInfo?.coverName == nil {
                        gameInfo?.coverName = coverName
                    }
                    
                } else {
                    gameInfo = GameInfo(id: nil,
                                        gameID: container.gameID,
                                        title: container.title,
                                        iconName: container.iconName,
                                        coverName: container.coverName,
                                        price: container.price,
                                        category: container.category,
                                        level: container.level,
                                        average: container.average,
                                        color: container.color,
                                        rescore: container.rescore,
                                        cascore: container.cascore,
                                        inscore: container.inscore,
                                        mescore: container.mescore,
                                        spscore: container.spscore,
                                        crscore: container.crscore)
                }
                
                return (gameInfo!.save(on: req).flatMap({ (info) in
                    return try ResponseJSON<Empty>(status: .ok,
                                                   message: "Updated successfully!").encode(for: req)
                }))
            })
    }
    
    //MARK: 获取游戏列表
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
    
    //MARK: 获取指定游戏信息
    func getGameInfoHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "Missing `token` parameter").encode(for: req)
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
    
    //MARK: 获取用户游戏信息
    func getUserGameInfoHandler(_ req: Request) throws -> Future<Response> {
        
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
                
                let first = ActorInfo
                    .query(on: req)
                    .filter(\.userID == existToken.userID)
                    .filter(\.gameID == gameID)
                    .first()
                
                return first.flatMap({ (existInfo) in
                    guard let existInfo = existInfo else {
                        return try ResponseJSON<Empty>(status: .error,
                                                       message: "User game information is empty.").encode(for: req)
                    }
                    return try ResponseJSON<ActorInfo>(data: existInfo).encode(for: req)
                })
            })
    }
    
    //MARK: 获取游戏图标
    func getGameIconHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.gameIcon, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error, message: "Image does not exist")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    //MARK: 获取游戏封面
    func getGameCoverHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.gameCover, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error, message: "Image does not exist")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    //MARK: 获取指定游戏的排名列表
    func getGameRankingHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "Missing `token` parameter").encode(for: req)
        }
        
        return ActorInfo
            .query(on: req)
            .filter(\.gameID == gameID)
            .sort(\.maxscore,.descending) //ascending or descending:升序或降序
            .all()
            .flatMap({ (actor) in
                let actorList = actor.compactMap({ ActorInfo -> ActorInfo in
                    var w = ActorInfo;w.id = nil;return w
                })
                return try ResponseJSON<[ActorInfo]>(data: actorList).encode(for: req)
            })
    }
    
    //MARK: 获取指定游戏的参与者列表
    func getGameActorHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "Missing `token` parameter").encode(for: req)
        }
        
        return ActorInfo
            .query(on: req)
            .filter(\.gameID == gameID)
            .all()
            .flatMap({ (actor) in
                let actorList = actor.compactMap({ ActorInfo -> ActorInfo in
                    var w = ActorInfo;w.id = nil;return w
                })
                return try ResponseJSON<[ActorInfo]>(data: actorList).encode(for: req)
            })
    }
    
    
    //MARK: 获取指定游戏的参与人数
    func getGameJoinHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,
                                     at: "gameID"] else {
                                        return try ResponseJSON<Empty> (status: .error,
                                                                        message: "Missing `token` parameter").encode(for: req)
        }
        
        return ActorInfo
            .query(on: req)
            .filter(\.gameID == gameID)
            .all()
            .flatMap({ (actor) in
                let join = actor.count
                return try join.encode(for: req)
                //let data = ["join": join]
                //return try ResponseJSON(data: data).encode(for: req)
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
    
    var gameID: String
    
    var title: String?
    var iconName: String?
    var coverName: String?
    var price: Double?
    var category: String?
    var level: Int?
    var average: Int?
    var color: String?
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
    var iconImage: File?
    var coverImage: File?
    
}

struct ActorInfoContainer: Content {
    
    var token: String
    var gameID: String
    
    var ispay: Int?
    
    var newscore: Int? //无需用户提交
    var maxscore: Int? //无需用户提交
    var grade: String? //无需用户提交
    var level: Int?
    
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
    var date: String? //无需用户提交
    var time: String? //无需用户提交
    
}

struct ChallengeInfoContainer: Content {
    
    var token:String
    
    var maxscore: Int?
    var grade: String?
    
    var rewscore: Int? //无需用户提交
    var cawscore: Int? //无需用户提交
    var inwscore: Int? //无需用户提交
    var mewscore: Int? //无需用户提交
    var spwscore: Int? //无需用户提交
    var crwscore: Int? //无需用户提交
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
    var date: String? //无需用户提交
    var time: String? //无需用户提交
    
}

