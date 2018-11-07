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

    var grade: String?
    var maxscore: Int?

    var rewscore: Int?
    var cawscore: Int?
    var inwscore: Int?
    var mewscore: Int?
    var spwscore: Int?
    var crwscore: Int?

    var sex: Int?
    var nickName: String?
    var location: String?
    var picName: String?

    var date: String?
    var time: String?

    init(userID: String,
         
         maxscore: Int?,
         grade: String?,
         
         rewscore: Int?,
         cawscore: Int?,
         inwscore: Int?,
         mewscore: Int?,
         spwscore: Int?,
         crwscore: Int?,
         
         sex: Int?,
         nickName: String?,
         location: String?,
         picName: String?,
         
         date: String = DateManager.shared.currentDate(),
         time: String = TimeManager.shared.current()
        
        ) {
        
        self.userID = userID
        
        self.maxscore = maxscore
        self.grade = grade
        
        self.rewscore = rewscore
        self.cawscore = cawscore
        self.inwscore = inwscore
        self.mewscore = mewscore
        self.spwscore = spwscore
        self.crwscore = crwscore
        
        self.sex = sex
        self.nickName = nickName
        self.location = location
        self.picName = picName
        
        self.date = date
        self.time = time
    }

}

// 设置外键
extension ChallengeInfo {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.userID) // 外键
            builder.unique(on: \.userID) // 唯一键
        }
    }
}

extension ChallengeInfo {
    
    mutating func update(with container: ActorInfoContainer) -> ChallengeInfo {
        
        if let new = container.maxscore {
            self.maxscore = new
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

