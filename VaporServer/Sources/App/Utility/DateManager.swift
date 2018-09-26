//
//  DateManager.swift
//  App
//
//  Created by 黑胡子 on 2018/9/26.
//

import Vapor

struct DateManager {
    
    static let shared = DateManager()
    
    fileprivate let matter = DateFormatter()
    
    init() {
        matter.dateFormat = "yyyy-MM-dd"
        matter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    }
    
    func currentDate() -> String {
        return matter.string(from: Date())
    }
    
    static func currentDate() -> String {
        return self.shared.matter.string(from: Date())
    }
}

