//
//  HTMLController.swift
//  APIErrorMiddleware
//
//  Created by Jinxiansen on 2018/6/1.
//

import Vapor


class HTMLController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.get("/", use: api)
      
        router.group("h5") { (group) in
            group.get("userPrivacy", use: userPrivacy)
            group.get("userProtocol", use: userProtocol)
        }
        
        router.group("help") { (group) in
            group.get("IN-0001", use: help_in_0001)
            group.get("RE-0001", use: help_re_0001)
            group.get("CA-0001", use: help_ca_0001)
        }
        
    }
    

}

extension HTMLController {

    
    func api(_ req: Request) throws -> Future<View> {
        
        return try req.view().render("leaf/web")
    }
    
    //MARK: H5
    
    func hello(_  req: Request) throws -> Future<View> {
        
        struct Person: Content {
            var name: String?
            var age: Int?
        }
        let per = Person(name: "jack", age: 18)
        return try req.view().render("leaf/hello",per)
    }
    
    func userPrivacy(_  req: Request) throws -> Future<View> {
        return try req.view().render("leaf/userPrivacy")
    }
    
    func userProtocol(_  req: Request) throws -> Future<View> {
        return try req.view().render("leaf/userProtocol")
    }
    
    func help_in_0001(_  req: Request) throws -> Future<View> {
        return try req.view().render("leaf/IN-0001")
    }
    func help_re_0001(_  req: Request) throws -> Future<View> {
        return try req.view().render("leaf/IN-0001")
    }
    func help_ca_0001(_  req: Request) throws -> Future<View> {
        return try req.view().render("leaf/IN-0001")
    }
}












