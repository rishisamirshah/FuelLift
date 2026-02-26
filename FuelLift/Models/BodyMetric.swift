import Foundation
import SwiftData

@Model
final class BodyMetric {
    var id: String
    var date: Date
    var weightKG: Double?
    var bodyFatPercent: Double?
    var chestCM: Double?
    var waistCM: Double?
    var hipsCM: Double?
    var bicepsCM: Double?
    var thighsCM: Double?
    var photoData: Data?

    init(date: Date = Date()) {
        self.id = UUID().uuidString
        self.date = date
    }
}
