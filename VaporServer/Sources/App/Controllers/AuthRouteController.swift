//
//  AuthRouteController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/1.
//

import Foundation
import Vapor
import Fluent
import Crypto
import Authentication

struct AuthenRouteController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        let group = router.grouped("api","token")
        
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let basicAuthGroup = group.grouped([basicAuthMiddleware,guardAuthMiddleware])
        basicAuthGroup.post(UserContext.self, at: "revoke", use: accessTokenRevocationHandler)
    }
    
}


extension AuthenRouteController {
    
    fileprivate func refreshAccessTokenHandler(_ req: Request,container: RefreshTokenContainer) throws -> Future<AuthContainer> {
        return try authController.authContainer(for: container.refreshToken, on: req)
    }
    
    fileprivate func accessTokenRevocationHandler(_ req: Request,container: UserContext) throws -> Future<HTTPResponseStatus> {
        return try authController.remokeTokens(userID: container.userID,
                                               on: req).transform(to: .noContent)
    }
}


fileprivate struct UserContext: Content {
    
    let userID: String
    
    
}




