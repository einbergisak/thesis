import Vapor
import Fluent
import FluentPostgresDriver


// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    
    // Configure Postgres database
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                port: 5432,
                username: "postgres",
                password: "password",
                database: "postgres",
                tls: .disable
            )
        ),
        as: .psql
    )
    
    
    // register routes
    try routes(app)
}

