import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("lipsum.txt") { req async throws -> Response in
        let filePath = "/tmp/lipsum.txt"
        return try await req.fileio.asyncStreamFile(at: filePath)
    }

    app.post("json") { req async throws -> Response in
        do {
            // Receive and deserialize JSON into EchoData
            let json = try req.content.decode(EchoData.self)

            // Serialize EchoData and respond
            return try await json.encodeResponse(for: req)
        } catch {
            throw Abort(.badRequest, reason: "Invalid JSON")
        }
    }
}
