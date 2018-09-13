//
//  GameController.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/13.
//

import Vapor
import Crypto
import Authentication

final class GameController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let group = router.grouped("games")
        
        group.get("getGameList", use: getGameListHandler)
        group.get("getGameInfo", use: getGameInfoHandler)
        group.get("icon",String.parameter, use: getGameIconHandler)
        group.get("cover",String.parameter, use: getGameCoverHandler)
        
    }
    
}

extension GameController {
    
    //TODO: 获取游戏列表
    func getGameListHandler(_ req: Request) throws -> Future<Response> {
        
        return GameInfo
            .query(on: req)
            .all()
            .flatMap({ (game) in
                let fultueWords = game.compactMap({ GameInfo -> GameInfo in
                    var w = GameInfo;w.id = nil;return w
                })
                return try ResponseJSON<[GameInfo]>(data: fultueWords).encode(for: req)
            })
    }
    
    //TODO:  获取游戏信息
    func getGameInfoHandler(_ req: Request) throws -> Future<Response> {
        
        guard let gameID = req.query[String.self,at: "gameID"]
        else {
            return try ResponseJSON<Empty> (
                status: .error,
                message: "缺少 gameID 参数").encode(for: req)
        }
        
        return GameInfo.query(on: req)
            .filter(\.gameID == gameID)
            .all()
            .flatMap({ (cords) in
                guard cords.count > 0 else {
                    return try ResponseJSON<[GameInfo]>(status: .ok,
                                                      message: "没有数据了",
                                                      data: []).encode(for: req)
                }
                return try ResponseJSON<[GameInfo]>(data: cords).encode(for: req)
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
    
}


struct GameInfoContainer: Content {
    
    var title: String?
    var iconName: File?
    var coverName: File?
    var price: Double?
    var category: String?
    var join: Int?
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

