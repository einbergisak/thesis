import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("lipsum.txt") { req async throws -> Response in
        let filePath = "/tmp/lipsum.txt"
        return try await req.fileio.asyncStreamFile(at: filePath)
    }

    app.get("json") { req async throws -> EchoData in
        do {
            // Decode JSON from the request body
            let json = try req.content.decode(EchoData.self)

            // Vapor automatically reencodes data as EchoData implements the Codable and Content protocols.
            return json
        } catch {
            throw Abort(.badRequest, reason: "Invalid request")
        }
    }
}
