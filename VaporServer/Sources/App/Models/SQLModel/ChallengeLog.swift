//
//  Game.swift
//  APP
//
//  Created by 黑胡子 on 2018/9/14.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct ChallengeLog: BaseSQLModel {
    
    var id: Int?
    
    var userID: String
    var gameID: String
    
    static var entity: String { return self.name + "s" }
    
    var score: Int?
    var time: String?
    
    init(userID: String,
         gameID: String,
        time: String = TimeManager.shared.current(),
        score: Int?) {
        self.userID = userID
        self.gameID = gameID
        self.time = time
        self.score = score
    }
    
}

// 设置外键
extension ChallengeLog {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.userID)
            builder.reference(from: \.gameID, to: \GameInfo.gameID)
        }
    }
}
