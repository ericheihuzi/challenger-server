//
//  Migrations.swift
//  APIErrorMiddleware
//
//  Created by 黑胡子 on 2018/10/11.
//

import Foundation
import Vapor
import Fluent
extension MigrationConfig {
    
    mutating func setupModels() {
        
        add(model: User.self, database: .psql)
        add(model: EmailResult.self, database: .psql)
        
        add(model: PageView.self, database: .psql)
        add(model: AccessToken.self, database: .psql)
        add(model: RefreshToken.self, database: .psql)
        
        add(model: Record.self, database: .psql) //动态
        add(model: Report.self, database: .psql) //举报
        add(model: UserInfo.self, database: .psql) //用户信息
        
        add(model: ChallengeInfo.self, database: .psql)
        add(model: GameInfo.self, database: .psql)
        add(model: ChallengeLog.self, database: .psql)
        add(model: Grade.self, database: .psql) //必须在Actor前面
        add(model: ActorInfo.self, database: .psql)
        
        // Populate
        add(migration: PopulateGradeForms.self, database: .psql)
        
        //test
        add(model: MyModel.self, database: .psql)
        
    }
    
}
