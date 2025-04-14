import Foundation
import Fluent
import Vapor

// UNCHECKED SENDABLE: https://blog.vapor.codes/posts/fluent-models-and-sendable/
final class DBTable: Model, @unchecked Sendable, Content {
    static let schema = "tableone"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
