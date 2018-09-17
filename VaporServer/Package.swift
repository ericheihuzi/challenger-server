// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        
        .package(url: "https://github.com/skelpo/APIErrorMiddleware.git", from: "0.1.0"),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP.git", from: "4.0.1"),
        
        // JWT Middleware to authenticate
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.6.1"),
        
        .package(url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
        
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),
        
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc"),
        
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.1"),
        .package(url: "https://github.com/PerfectSideRepos/Perfect-ICONV.git",from:"3.0.1")
        ],
    targets: [
        .target(name: "App", dependencies: ["SwiftSMTP",
                                            "Leaf",
                                            "FluentPostgreSQL",
                                            "PerfectICONV",
                                            "Vapor",
                                            "JWTMiddleware",
                                            "JWT",
                                            "Multipart",
                                            "Authentication",
                                            "Crypto",
                                            "Logging",
                                            "Redis",
                                            "SwiftSoup",
                                            "APIErrorMiddleware"
            ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

