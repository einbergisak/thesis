import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("lipsum.txt") { req async throws -> Response in
        let filePath = "/tmp/lipsum.txt"
        return try await req.fileio.asyncStreamFile(at: filePath)
    }
}
