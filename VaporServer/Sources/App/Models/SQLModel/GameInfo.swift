//
//  GameInfo.swift
//  APP
//
//  Created by 黑胡子 on 2018/9/13.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct GameInfo : BaseSQLModel {
    var id: Int?
    
    var gameID: String
    
    static var entity: String { return self.name + "s" }
    
    var title: String?
    var iconName: String?
    var coverName: String?
    var price: Double?
    var category: String?
    //var join: Int
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

// 设置唯一键
extension GameInfo {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.gameID)
        }
    }
}

