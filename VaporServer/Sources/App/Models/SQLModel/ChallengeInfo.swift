//
//  ChallengeInfo.swift
//  App
//
//  Created by 黑胡子 on 2018/9/15.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct ChallengeInfo : BaseSQLModel {
    var id: Int?
    
    var userID: String?
    
    static var entity: String { return self.name + "s" }
    
    var wordRanking: Int?
    var rankingChange: Int?
    
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

// 设置外键
extension ChallengeInfo {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.userID)
        }
    }
}

extension ChallengeInfo {
    
    mutating func update(with container: ChallengeInfoContainer) -> ChallengeInfo {
        
        if let new = container.challengeTime {
            self.challengeTime = new
        }
        if let new = container.score {
            self.score = new
        }
        if let new = container.grade {
            self.grade = new
        }
        
        if let new = container.rewscore {
            self.rewscore = new
        }
        if let new = container.cawscore {
            self.cawscore = new
        }
        if let new = container.inwscore {
            self.inwscore = new
        }
        if let new = container.mewscore {
            self.mewscore = new
        }
        if let new = container.spwscore {
            self.spwscore = new
        }
        if let new = container.crwscore {
            self.crwscore = new
        }
        
        return self
    }
    
}

