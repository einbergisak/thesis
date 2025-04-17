import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) async throws {
    // Configure Postgres database
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "db",  // Network configured with Docker compose (docker-compose.yml)
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
