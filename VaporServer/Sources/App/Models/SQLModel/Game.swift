//
//  Game.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/14.
//

import Foundation
import Vapor
import Authentication

struct Game: BaseSQLModel {
    
    var id: Int?
    
    var gameID: String?
    
    static var entity: String { return self.name + "s" }
    
    var title: String?
    //var iconName: String?
    var coverName: String?
    var price: Double?
    var category: String?
    var join: Int?
    //var level: Int?
    //var round: Int?
    var color: String?
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
    static var createdAtKey: TimestampKey? = \Game.createdAt
    static var updatedAtKey: TimestampKey? = \Game.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
    
}


