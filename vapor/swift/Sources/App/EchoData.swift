import Foundation
import Vapor

struct EchoData: Codable, Content {
    let message: String
}
