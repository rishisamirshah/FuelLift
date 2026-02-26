import Foundation
import SwiftData

@Model
final class WaterEntry {
    var id: String
    var amountML: Int
    var date: Date

    init(amountML: Int, date: Date = Date()) {
        self.id = UUID().uuidString
        self.amountML = amountML
        self.date = date
    }
}
