import Vapor
import APIErrorMiddleware
import Leaf
import Authentication
import FluentPostgreSQL
import Redis

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    
    // Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    // 认证
    services.register(DirectoryConfig.detect())
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
//    let myService = NIOServerConfig.default(port: 8030)
//    services.register(myService)

    /* * ** ** ** ** *** ** ** ** Middleware ** ** ** ** ** ** ** ** ** */
    var middlewares = MiddlewareConfig()
    
    middlewares.use(LocalHostMiddleware())
    
    middlewares.use(APIErrorMiddleware.init(environment: env, specializations: [
        ModelNotFound()
    ]))
    
    middlewares.use(ExceptionMiddleware(closure: { (req) -> (EventLoopFuture<Response>?) in
        let dict = ["status":"404","message":"访问路径不存在"]
        return try dict.encode(for: req)
//        return try req.view().render("leaf/loader").encode(for: req)
    }))
    
    middlewares.use(ErrorMiddleware.self)
    // Serves files from `Public/` directory
    middlewares.use(FileMiddleware.self)
    
    //
    middlewares.use(PageViewMeddleware())
    
    middlewares.use(GuardianMiddleware(rate: Rate(limit: 20, interval: .minute), closure: { (req) -> EventLoopFuture<Response>? in
        let dict = ["status":"429","message":"访问太频繁"]
        return try dict.encode(for: req)
    }))
    
    services.register(middlewares)
    
    /* ** ** ** ** *** ** ** ** SQL ** ** ** ** ** ** ** ** ** */
    try services.register(FluentPostgreSQLProvider())
    let pgSQL = PostgreSQLDatabaseConfig.loadSQLConfig(env)
    services.register(pgSQL)
    
    /* ** ** ** ** *** ** ** ** 𝐌odels ** ** ** ** ** ** ** ** ** */
    var migrations = MigrationConfig()
    
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: EmailResult.self, database: .psql)
    
    migrations.add(model: PageView.self, database: .psql)
    migrations.add(model: AccessToken.self, database: .psql)
    migrations.add(model: RefreshToken.self, database: .psql)
    migrations.add(model: Record.self, database: .psql) //动态
    
//    migrations.add(model: Word.self, database: .psql) //字
//    migrations.add(model: Idiom.self, database: .psql) //词
//    migrations.add(model: XieHouIdiom.self, database: .psql) //歇后语
    migrations.add(model: Report.self, database: .psql) //举报
    migrations.add(model: UserInfo.self, database: .psql) //用户信息
//    migrations.add(model: LGWork.self, database: .psql) //拉钩
//    migrations.add(model: CrawlerLog.self, database: .psql) //爬虫日志
//    migrations.add(model: ScreenShot.self, database: .psql) //爬虫相关
//    migrations.add(model: BookChapter.self, database: .psql)
//    migrations.add(model: BookInfo.self, database: .psql)
//    migrations.add(model: HKJob.self, database: .psql)
//    migrations.add(model: SinWord.self, database: .psql)
//    migrations.add(model: EnJob.self, database: .psql)
//    migrations.add(model: EnJobDetail.self, database: .psql)
//    migrations.add(model: EnJobApply.self, database: .psql)
    
    migrations.add(model: ChallengeInfo.self, database: .psql)
    migrations.add(model: GameInfo.self, database: .psql)
//    migrations.add(model: UserGameInfo.self, database: .psql)
    migrations.add(model: ChallengeLog.self, database: .psql)
    migrations.add(model: Grade.self, database: .psql) //必须在Actor前面
//    migrations.add(model: Actor.self, database: .psql)
    migrations.add(model: ActorInfo.self, database: .psql)
    
    // Populate
    migrations.add(migration: PopulateGradeForms.self, database: .psql)
    
    //test
    migrations.add(model: MyModel.self, database: .psql)
    
    services.register(migrations)
    
    /* ** ** ** ** *** ** ** ** Redis ** ** ** ** ** ** ** ** ** */
    // register Redis provider
    //try services.register(RedisProvider())

}









