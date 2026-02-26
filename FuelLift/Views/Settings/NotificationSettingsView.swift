import SwiftUI

struct NotificationSettingsView: View {
    @State private var breakfastReminder = true
    @State private var lunchReminder = true
    @State private var dinnerReminder = true
    @State private var workoutReminder = true
    @State private var breakfastTime = dateFrom(hour: 8, minute: 0)
    @State private var lunchTime = dateFrom(hour: 12, minute: 0)
    @State private var dinnerTime = dateFrom(hour: 18, minute: 30)
    @State private var workoutTime = dateFrom(hour: 17, minute: 0)

    var body: some View {
        Form {
            Section("Meal Reminders") {
                Toggle("Breakfast", isOn: $breakfastReminder)
                if breakfastReminder {
                    DatePicker("Time", selection: $breakfastTime, displayedComponents: .hourAndMinute)
                }

                Toggle("Lunch", isOn: $lunchReminder)
                if lunchReminder {
                    DatePicker("Time", selection: $lunchTime, displayedComponents: .hourAndMinute)
                }

                Toggle("Dinner", isOn: $dinnerReminder)
                if dinnerReminder {
                    DatePicker("Time", selection: $dinnerTime, displayedComponents: .hourAndMinute)
                }
            }

            Section("Workout Reminders") {
                Toggle("Workout Reminder", isOn: $workoutReminder)
                if workoutReminder {
                    DatePicker("Time", selection: $workoutTime, displayedComponents: .hourAndMinute)
                }
            }

            Section {
                Button("Save Reminders") {
                    saveReminders()
                }
                .frame(maxWidth: .infinity)
                .bold()
            }
        }
        .navigationTitle("Notifications")
    }

    private func saveReminders() {
        NotificationService.shared.removeAllReminders()

        let cal = Calendar.current

        if breakfastReminder {
            NotificationService.shared.scheduleMealReminder(
                mealType: "breakfast",
                hour: cal.component(.hour, from: breakfastTime),
                minute: cal.component(.minute, from: breakfastTime)
            )
        }
        if lunchReminder {
            NotificationService.shared.scheduleMealReminder(
                mealType: "lunch",
                hour: cal.component(.hour, from: lunchTime),
                minute: cal.component(.minute, from: lunchTime)
            )
        }
        if dinnerReminder {
            NotificationService.shared.scheduleMealReminder(
                mealType: "dinner",
                hour: cal.component(.hour, from: dinnerTime),
                minute: cal.component(.minute, from: dinnerTime)
            )
        }
        if workoutReminder {
            NotificationService.shared.scheduleWorkoutReminder(
                days: [2, 3, 4, 5, 6], // Mon-Fri
                hour: cal.component(.hour, from: workoutTime),
                minute: cal.component(.minute, from: workoutTime)
            )
        }
    }

    private static func dateFrom(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }
}
