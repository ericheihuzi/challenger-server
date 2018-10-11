//
//  ActorInfo.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/9/28.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct ActorInfo : BaseSQLModel {
    var id: Int?
    
    var userID: String
    var gameID: String
    
    static var entity: String { return self.name + "s" }
    
    var ispay: Int? // 0-未支付/未解锁，1-已支付/已解锁
    
    var newscore: Int?
    var maxscore: Int?
    var level: Int?
    
    var rescore: Int?
    var cascore: Int?
    var inscore: Int?
    var mescore: Int?
    var spscore: Int?
    var crscore: Int?
    
    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?
    
    var date: String?
    var time: String?
    
    init(userID: String,
         gameID: String,
         
         ispay: Int?,
         
         maxscore: Int?,
         newscore: Int?,
         level: Int?,
         
        
         rescore: Int?,
         cascore: Int?,
         inscore: Int?,
         mescore: Int?,
         spscore: Int?,
         crscore: Int?,
         
         sex: Int?,
         nickName: String?,
         location: String?,
         picName: String?,
        
        date: String = DateManager.shared.currentDate(),
        time: String = TimeManager.shared.current()
        
        ) {
        
        self.userID = userID
        self.gameID = gameID
        
        self.ispay = ispay
        
        self.maxscore = maxscore
        self.newscore = newscore
        self.level = level
        
        self.rescore = rescore
        self.cascore = cascore
        self.inscore = inscore
        self.mescore = mescore
        self.spscore = spscore
        self.crscore = crscore
        
        self.sex = sex
        self.nickName = nickName
        self.location = location
        self.picName = picName
        
        self.date = date
        self.time = time
    }
    
}

// 设置外键
extension ActorInfo {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.userID) // 外键
            builder.reference(from: \.gameID, to: \GameInfo.gameID) // 外键
        }
    }
}

extension ActorInfo {
    
    mutating func update(with container: ActorInfoContainer) -> ActorInfo {
        
        if let new = container.ispay {
            self.ispay = new
        }
        
        if let new = container.maxscore {
            self.maxscore = new
        }
        if let new = container.newscore {
            self.newscore = new
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
        
        self.date = DateManager.shared.currentDate()
        self.time = TimeManager.shared.current()
        
        return self
    }
    
}

