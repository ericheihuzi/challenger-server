//
//  Ranking.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct WorldRanking: BaseSQLModel {
    
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    var userID: String?
    //var worldRanking: String
    //var rankingChange: Int?
    
    var score: Int?
    var grade: String?
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
}


// 设置外键
extension WorldRanking {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.userID)
        }
    }
}

extension WorldRanking {
    
    mutating func update(with container: WorldRankingContainer) -> WorldRanking {
        
        if let new = container.score {
            self.score = new
        }
        if let new = container.grade {
            self.grade = new
        }
        
        if let new = container.sex {
            self.sex = new
        }
        if let new = container.nickName {
            self.nickName = new
        }
        if let new = container.location {
            self.location = new
        }
        if let new = container.picName {
            self.picName = new
        }
        
        return self
    }
    
}


