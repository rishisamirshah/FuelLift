import Foundation
import SwiftData

@Model
final class Badge {
    var id: String
    var key: String
    var name: String
    var badgeDescription: String
    var iconName: String
    var category: String
    var requirement: String
    var earnedDate: Date?

    var isEarned: Bool {
        earnedDate != nil
    }

    init(
        key: String,
        name: String,
        badgeDescription: String,
        iconName: String,
        category: String,
        requirement: String,
        earnedDate: Date? = nil
    ) {
        self.id = UUID().uuidString
        self.key = key
        self.name = name
        self.badgeDescription = badgeDescription
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.earnedDate = earnedDate
    }
}
