//
//  Grade+Populate.swift
//  App
//
//  Created by 黑胡子 on 2018/9/27.
//

import Vapor
import FluentPostgreSQL

//struct gradeData {
//    let grade: String
//    let minscore: Int
//    let maxscore: Int
//    let describe: String?
//}

/// 数据填充
final class PopulateGradeForms: Migration {
    typealias Database = PostgreSQLDatabase
    
    static let data = [
        ("石头","你确定是人类?",0,50),
        ("痴者","老年痴呆患者",51,60),
        ("愚者","愚蠢的人类",61,80),
        ("凡者","正常的人类",81,110),
        ("明者","比较聪明的人",111,120),
        ("灵者","非常聪明的人",121,140),
        ("智者","大仙级人物",141,150),
        ("歌者","人类的领头羊",151,200),
        ("归零者","你确定是人类?",201,300)
    ]
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let futures = data.map { data in
            return Grade(grade: data.0, describe: data.1, minscore: data.2, maxscore: data.3)
                    .create(on: conn)
                    .map(to: Void.self) { _  in return }
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        let futures = data.map { data in
            return Grade
                .query(on: conn)
                .filter(\Grade.grade == data.0)
                .filter(\Grade.describe == data.1)
                .filter(\Grade.minscore == data.2)
                .filter(\Grade.maxscore == data.3)
                .delete()
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }
    
}
