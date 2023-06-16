import Vapor
import FluentMySQLDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.mysql(hostname: Environment.get("DB_HOST")!, username: Environment.get("DB_USER")!,
        password: Environment.get("DB_PASSWORD")!, database: Environment.get("DB_SCHEMA")!), as: .mysql)

    app.migrations.add(Initial(), to: .mysql)

    do {
        try await app.autoMigrate()
    } catch {
        try await app.autoRevert()
    }
    

    // register routes
    try routes(app)
}
