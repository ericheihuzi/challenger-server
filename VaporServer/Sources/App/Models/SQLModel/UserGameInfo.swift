//
//  UserGameInfo.swift
//  APP
//
//  Created by 黑胡子 on 2018/9/14.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct UserGameInfo: BaseSQLModel {
    
    var id: Int?
    
    var userID: String
    var gameID: String
    
    static var entity: String { return self.name + "s" }
    // 0-未支付/未解锁，1-已支付/已解锁
    var ispay: Int?
    
    var newscore: Int?
    var maxscore: Int?
    
    var level: Int?
    var ranking: Int?
    var rankingChange: Int?
    
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
}

// 设置外键
extension UserGameInfo {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.userID)
            builder.reference(from: \.gameID, to: \GameInfo.gameID)
        }
    }
}

extension UserGameInfo {
    
    mutating func update(with container: UserGameInfoContainer) -> UserGameInfo {
        
        if let new = container.ispay {
            self.ispay = new
        }
        if let new = container.newscore {
            self.newscore = new
        }
        if let new = container.maxscore {
            self.maxscore = new
        }
        if let new = container.level {
            self.level = new
        }
        
        if let new = container.rescore {
            self.rescore = new
        }
        if let new = container.cascore {
            self.cascore = new
        }
        if let new = container.inscore {
            self.inscore = new
        }
        if let new = container.mescore {
            self.mescore = new
        }
        if let new = container.spscore {
            self.spscore = new
        }
        if let new = container.crscore {
            self.crscore = new
        }
        
        return self
    }
    
}

