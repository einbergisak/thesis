import Foundation
import Vapor

struct EchoData: Codable, Content {
    let id: Int
    let message: String
    let innerDataList: [InnerData]
}

struct InnerData: Codable, Content {
    let id: Int
    let number: Double
    let itemList: [ListItem]
}

struct ListItem: Codable, Content {
    let id: Int
    let boolean: Bool
    let string: String
}
