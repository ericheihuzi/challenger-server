import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    router.get("vapor") { req in
        return "Hello, vapor! "
    }
    
    router.get("version") { (req) in
        return req.description
    }
    
    // ` Register Controllers `
    try router.register(collection: EmailController()) // 邮件
    try router.register(collection: HTMLController()) // H5
    try router.register(collection: TestController()) // 测试

    try router.register(collection: UserController()) // 用户
    try router.register(collection: AuthenRouteController())
    try router.register(collection: RecordController()) // 动态
    
    try router.register(collection: GameController()) // 游戏
    try router.register(collection: ChallengeController()) // 挑战
    
}
