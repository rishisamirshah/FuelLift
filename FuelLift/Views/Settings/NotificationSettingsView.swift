import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    @State private var breakfastReminder = true
    @State private var lunchReminder = true
    @State private var dinnerReminder = true
    @State private var workoutReminder = true
    @State private var breakfastTime = dateFrom(hour: 8, minute: 0)
    @State private var lunchTime = dateFrom(hour: 12, minute: 0)
    @State private var dinnerTime = dateFrom(hour: 18, minute: 30)
    @State private var workoutTime = dateFrom(hour: 17, minute: 0)

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Meal Reminders
                sectionHeader("Meal Reminders")

                VStack(spacing: 0) {
                    toggleRow("Breakfast", isOn: $breakfastReminder)
                    if breakfastReminder {
                        timePickerRow(selection: $breakfastTime)
                    }
                    divider

                    toggleRow("Lunch", isOn: $lunchReminder)
                    if lunchReminder {
                        timePickerRow(selection: $lunchTime)
                    }
                    divider

                    toggleRow("Dinner", isOn: $dinnerReminder)
                    if dinnerReminder {
                        timePickerRow(selection: $dinnerTime)
                    }
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // Workout Reminders
                sectionHeader("Workout Reminders")

                VStack(spacing: 0) {
                    toggleRow("Workout Reminder", isOn: $workoutReminder)
                    if workoutReminder {
                        timePickerRow(selection: $workoutTime)
                    }
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // Save button
                Button { saveReminders() } label: {
                    Text("Save Reminders")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingMD)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
                .padding(.horizontal, Theme.spacingLG)
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Notifications")
        .onAppear {
            if let profile {
                breakfastReminder = profile.breakfastReminderEnabled
                lunchReminder = profile.lunchReminderEnabled
                dinnerReminder = profile.dinnerReminderEnabled
                workoutReminder = profile.workoutReminderEnabled
                breakfastTime = Self.dateFrom(hour: profile.breakfastReminderHour, minute: profile.breakfastReminderMinute)
                lunchTime = Self.dateFrom(hour: profile.lunchReminderHour, minute: profile.lunchReminderMinute)
                dinnerTime = Self.dateFrom(hour: profile.dinnerReminderHour, minute: profile.dinnerReminderMinute)
                workoutTime = Self.dateFrom(hour: profile.workoutReminderHour, minute: profile.workoutReminderMinute)
            }
        }
    }

    // MARK: - Subviews

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: Theme.captionSize, weight: .semibold))
            .foregroundStyle(Color.appTextSecondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.spacingLG)
    }

    private func toggleRow(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.appAccent)
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
    }

    private func timePickerRow(selection: Binding<Date>) -> some View {
        DatePicker("Time", selection: selection, displayedComponents: .hourAndMinute)
            .font(.system(size: Theme.bodySize))
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, Theme.spacingLG)
            .padding(.bottom, Theme.spacingSM)
    }

    private var divider: some View {
        Divider()
            .overlay(Color.appTextTertiary.opacity(0.2))
            .padding(.leading, Theme.spacingLG)
    }

    // MARK: - Logic

    private func saveReminders() {
        let cal = Calendar.current

        // Persist preferences to UserProfile
        if let profile {
            profile.breakfastReminderEnabled = breakfastReminder
            profile.lunchReminderEnabled = lunchReminder
            profile.dinnerReminderEnabled = dinnerReminder
            profile.workoutReminderEnabled = workoutReminder
            profile.breakfastReminderHour = cal.component(.hour, from: breakfastTime)
            profile.breakfastReminderMinute = cal.component(.minute, from: breakfastTime)
            profile.lunchReminderHour = cal.component(.hour, from: lunchTime)
            profile.lunchReminderMinute = cal.component(.minute, from: lunchTime)
            profile.dinnerReminderHour = cal.component(.hour, from: dinnerTime)
            profile.dinnerReminderMinute = cal.component(.minute, from: dinnerTime)
            profile.workoutReminderHour = cal.component(.hour, from: workoutTime)
            profile.workoutReminderMinute = cal.component(.minute, from: workoutTime)
            try? modelContext.save()
        }

        // Schedule system notifications
        NotificationService.shared.removeAllReminders()

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
