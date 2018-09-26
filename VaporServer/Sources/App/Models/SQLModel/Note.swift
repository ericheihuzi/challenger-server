//
//  Note.swift
//  App
//
//  Created by 晋先森 on 2018/9/6.
//

import Foundation

// 生活动态、心情
struct NoteLive: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    var userID: String
    var title: String
    var time: TimeInterval?
    var content: String?
    var imgName: String?
    
    var desc: String?
    
}

// 账单
struct NoteBill: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    var userID: String
    var time: TimeInterval?
    var total: Float
    var number: Int
    var type: Int? //类型
    var desc: String?
    
}


