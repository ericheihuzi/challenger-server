//
//  RankingController.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/14.
//

import Vapor
import Crypto
import Authentication
import Redis

final class RankingController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let group = router.grouped("rankings")
        
        //group.post(UserGameInfoContainer.self, at: "updateUserGameInfo", use: updateUserGameInfoHandler)
        
        //group.get("getGameRanking", use: getGameRankingHandler)
        group.get("getWorldRanking", use: getWorldRankingHandler)
        
    }
    
}

extension RankingController {
    
    //TODO: 获取游戏排名
    func getWorldRankingHandler(_ req: Request) throws -> Future<Response> {
        
        return ChallengeInfo
            .query(on: req)
            .all()
            .flatMap({ (challenge) in
                let list = challenge.compactMap({ ChallengeInfo -> ChallengeInfo in
                    var w = ChallengeInfo;w.id = nil;return w
                })
                return try ResponseJSON<[ChallengeInfo]>(data: list).encode(for: req)
            })
        
        /*
        return ChallengeInfo
            .query(on: req)
            .all()
            .flatMap({ (challenge) in
                let fultueWords = challenge.compactMap({ ChallengeInfo -> ChallengeInfo in
                    var w = ChallengeInfo;w.id = nil;return w
                })
                return try ResponseJSON<[ChallengeInfo]>(data: fultueWords).encode(for: req)
            })
        */
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

struct GameRankingContainer: Content {
    
    var token:String
    
    var score: Int?
    var grade: String?
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
}

struct WorldRankingContainer: Content {
    
    var score: Int?
    var grade: String?
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
}
