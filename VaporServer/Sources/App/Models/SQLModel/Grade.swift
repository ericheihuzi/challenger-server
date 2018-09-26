//
//  Grade.swift
//  App
//
//  Created by 黑胡子 on 2018/9/26.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Grade: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    
    var grade: String?
    var describe: String?
    var minscore: Int?
    var maxscore: Int?
}

// 设置唯一键
extension Grade {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.grade)
        }
    }
}
