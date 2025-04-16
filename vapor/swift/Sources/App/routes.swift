import Vapor
import FluentPostgresDriver
import Fluent

final class Film : Model, @unchecked Sendable, Content {
    static let schema = "film"
    
    @ID(custom: "film_id")
    var id: Int?
    
    @Field(key:"title")
    var title: String
    
    @Field(key:"description")
    var description: String
    
    init() {}
}

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
    
    app.get("postgres") { req async throws -> Response in
        do {
            let randomId = Int.random(in: 1...1000)
            let film = try await Film.query(on: req.db(.psql)).filter(\.$id == randomId).first()

            return try await film!.encodeResponse(for: req)
        } catch  {
            throw Abort(.internalServerError)
        }
    }
    
    app.get("fibonacci") {req async throws -> Int in
        func fib(_ n: Int) -> Int {
            if n <= 1 {
               return n
            } else {
                return fib(n - 1) + fib(n - 2)
            }
        }
        
        return fib(40)
    }
}
