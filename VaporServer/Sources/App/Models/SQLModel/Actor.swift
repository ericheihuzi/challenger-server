////
////  Actor.swift
////  APP
////
////  Created by 黑胡子 on 2018/9/26.
////
//
//import Foundation
//import Vapor
//import FluentPostgreSQL
//
//struct Actor: BaseSQLModel {
//
//    var id: Int?
//    var userID: String
//    var gameID: String
//
//    static var entity: String { return self.name + "s" }
//
//    var score: Int?
//    var grade: String?
//    
//    var sex: Int?
//    var nickName: String?
//    var location: String?
//    var picName: String?
//
//    var date: String?
//    var time: String?
//
////    static var createdAtKey: TimestampKey? = \Actor.createdAt
////    static var updatedAtKey: TimestampKey? = \Actor.updatedAt
////    var createdAt: Date?
////    var updatedAt: Date?
//
//    init(date: String = DateManager.shared.currentDate(),
//         time: String = TimeManager.shared.current(),
//         userID: String,
//         gameID: String,
//         score: Int?,
//         grade: String?,
//         sex: Int?,
//         nickName: String?,
//         location: String?,
//         picName: String?) {
//        self.date = date
//        self.time = time
//        self.userID = userID
//        self.gameID = gameID
//        self.score = score
//        self.grade = grade
//        self.sex = sex
//        self.nickName = nickName
//        self.location = location
//        self.picName = picName
//    }
//
//}
//
//extension Actor {
//    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
//        return Database.create(self, on: connection) { builder in
//            try addProperties(to: builder)
//            builder.reference(from: \.userID, to: \User.userID) //外键
//            builder.reference(from: \.gameID, to: \GameInfo.gameID) //外键
//            builder.reference(from: \.grade, to: \Grade.grade) //外键
//        }
//    }
//}
//
//extension Actor {
//
//    mutating func update(with container: ActorContainer) -> Actor {
//
//        self.date = DateManager.shared.currentDate()
//        self.time = TimeManager.shared.current()
//
//        if let new = container.score {
//            self.score = new
//        }
//        if let new = container.grade {
//            self.grade = new
//        }
//
//        if let new = container.sex {
//            self.sex = new
//        }
//        if let new = container.nickName {
//            self.nickName = new
//        }
//        if let new = container.location {
//            self.location = new
//        }
//        if let new = container.picName {
//            self.picName = new
//        }
////
//        return self
//    }
//
//}
