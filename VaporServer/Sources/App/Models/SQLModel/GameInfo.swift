//
//  GameInfo.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/13.
//

import Foundation
import Vapor

struct GameInfo : BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    
    var gameID: String
    
    var title: String?
    var iconName: String?
    var coverName: String?
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

/*
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
        if let new = container.round {
            self.round = new
        }
        if let new = container.color {
            self.color = new
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
*/

