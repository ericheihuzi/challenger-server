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
    
    // Example of configuring a controlle
    try router.register(collection: EmailController())
    try router.register(collection: HTMLController()) // H5
    try router.register(collection: TestController())

    try router.register(collection: UserController())
    try router.register(collection: AuthenRouteController())
    try router.register(collection: RecordController()) //动态
//    try router.register(collection: WordController())
//    try router.register(collection: LaGouController())
//    try router.register(collection: ProcessController())
//    try router.register(collection: BookController())
//    try router.register(collection: ConstellationController())
//    try router.register(collection: HKJobController())
//    try router.register(collection: EnJobController())
    
    try router.register(collection: GameController())
//    try router.register(collection: RankingController())
    
}
