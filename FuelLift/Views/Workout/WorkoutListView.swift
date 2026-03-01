import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BadgeViewModel.self) private var badgeViewModel: BadgeViewModel?
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Query(sort: \WorkoutRoutine.lastUsedAt, order: .reverse) private var routines: [WorkoutRoutine]
    @Query private var profiles: [UserProfile]
    @StateObject private var workoutVM = WorkoutViewModel()
    @State private var showActiveWorkout = false
    @State private var showRoutineEditor = false
    @State private var showExercisePicker = false
    @State private var showCalendar = false
    @State private var showWorkoutPlanner = false
    @State private var routineToEdit: WorkoutRoutine?
    @State private var routineToDelete: WorkoutRoutine?
    @State private var showDeleteRoutineConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXXL) {
                    // Quick Start
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Quick Start")
                            .font(.system(size: Theme.bodySize, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)

                        Button {
                            workoutVM.startWorkout(name: "Quick Workout")
                            showActiveWorkout = true
                        } label: {
                            Text("Start an Empty Workout")
                                .primaryButtonStyle()
                        }
                    }

                    // Templates
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        HStack {
                            Text("Templates")
                                .sectionHeaderStyle()

                            Spacer()

                            Button {
                                showWorkoutPlanner = true
                            } label: {
                                HStack(spacing: Theme.spacingXS) {
                                    Image("icon_wand_stars")
                                        .pixelArt()
                                        .frame(width: 24, height: 24)
                                    Text("AI Plan")
                                }
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                            }

                            Button {
                                showRoutineEditor = true
                            } label: {
                                HStack(spacing: Theme.spacingXS) {
                                    Image(systemName: "plus")
                                    Text("Template")
                                }
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                            }
                        }

                        if routines.isEmpty {
                            Text("Create a template to quickly start workouts.")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                                .padding(.vertical, Theme.spacingMD)
                        } else {
                            HStack {
                                Text("My Templates (\(routines.count))")
                                    .font(.system(size: Theme.bodySize, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer()
                            }

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: Theme.spacingMD),
                                GridItem(.flexible(), spacing: Theme.spacingMD)
                            ], spacing: Theme.spacingMD) {
                                ForEach(routines, id: \.id) { routine in
                                    templateCard(routine)
                                }
                            }
                        }
                    }

                    // History
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        HStack {
                            Text("History")
                                .sectionHeaderStyle()

                            Spacer()

                            Button {
                                showCalendar = true
                            } label: {
                                Text("Calendar")
                                    .font(.system(size: Theme.captionSize, weight: .semibold))
                                    .foregroundStyle(Color.appAccent)
                            }
                        }

                        if workouts.isEmpty {
                            Text("No workouts yet. Start your first one!")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                                .padding(.vertical, Theme.spacingXL)
                        } else {
                            ForEach(workouts, id: \.id) { workout in
                                WorkoutHistoryCard(workout: workout)
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.top, Theme.spacingSM)
                .padding(.bottom, Theme.spacingHuge)
            }
            .screenBackground()
            .onAppear {
                workoutVM.badgeViewModel = badgeViewModel
            }
            .navigationTitle("Start Workout")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showRoutineEditor = true } label: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
            }
            .fullScreenCover(isPresented: $showActiveWorkout) {
                ActiveWorkoutView(viewModel: workoutVM)
            }
            .sheet(isPresented: $showRoutineEditor) {
                RoutineEditorView()
            }
            .sheet(isPresented: $showCalendar) {
                WorkoutCalendarView(workoutDates: Set(workouts.map { $0.date.startOfDay }))
            }
            .sheet(item: $routineToEdit) { routine in
                RoutineEditorView(existingRoutine: routine)
            }
            .sheet(isPresented: $showWorkoutPlanner) {
                WorkoutPlannerView(
                    userHeight: profiles.first?.heightCM,
                    userWeight: profiles.first?.weightKG,
                    userAge: profiles.first?.age
                )
            }
            .alert("Delete Template?", isPresented: $showDeleteRoutineConfirm) {
                Button("Delete", role: .destructive) {
                    if let routine = routineToDelete {
                        modelContext.delete(routine)
                        try? modelContext.save()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete \"\(routineToDelete?.name ?? "")\".")
            }
        }
    }

    // MARK: - Template Card

    private func templateCard(_ routine: WorkoutRoutine) -> some View {
        Button {
            workoutVM.startWorkout(name: routine.name, from: routine)
            routine.lastUsedAt = Date()
            showActiveWorkout = true
        } label: {
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                HStack(alignment: .top) {
                    Text(routine.name)
                        .font(.system(size: Theme.bodySize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)

                    Spacer(minLength: Theme.spacingXS)

                    Menu {
                        Button("Edit", systemImage: "pencil") {
                            routineToEdit = routine
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            routineToDelete = routine
                            showDeleteRoutineConfirm = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                Text(routine.exerciseNames.joined(separator: ", "))
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if let lastUsed = routine.lastUsedAt {
                    HStack(spacing: Theme.spacingXS) {
                        Circle()
                            .fill(Color.appWorkoutGreen)
                            .frame(width: 8, height: 8)
                        Text(lastUsed.relativeFormatted)
                            .font(.system(size: Theme.miniSize))
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        }
        .buttonStyle(.plain)
        .cardStyle()
    }
}
