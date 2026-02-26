import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func scheduleMealReminder(mealType: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to log \(mealType)!"
        content.body = "Don't forget to track your \(mealType) in FuelLift."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "meal-reminder-\(mealType)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleWorkoutReminder(days: [Int], hour: Int, minute: Int) {
        for day in days {
            let content = UNMutableNotificationContent()
            content.title = "Workout time!"
            content.body = "Your scheduled workout is waiting. Let's crush it."
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = day  // 1=Sunday, 7=Saturday
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "workout-reminder-\(day)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
