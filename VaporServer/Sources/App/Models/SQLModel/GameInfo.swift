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
    var level: Int?
    var average: Int?
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

extension GameInfo {
    
    mutating func update(with container: GameInfoContainer) -> GameInfo {
        
        if let new = container.title {
            self.title = new
        }
        
        if let new = container.price {
            self.price = new
        }
        if let new = container.category {
            self.category = new
        }
        
        if let new = container.level {
            self.level = new
        }
        if let new = container.average {
            self.average = new
        }
        if let new = container.color {
            self.color = new
        }
        
        if let new = container.rescore {
            self.rescore = new
        }
        if let new = container.inscore {
            self.inscore = new
        }
        if let new = container.cascore {
            self.cascore = new
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

