import SwiftUI

struct ExercisePickerView: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedBodyPart: String?
    @State private var selectedCategory: String?
    @State private var sortOption = "Name"

    private let exercises = ExerciseDefinition.loadAll()
    private let sortOptions = ["Name", "Frequency", "Last Performed"]

    var filteredExercises: [ExerciseDefinition] {
        var result = exercises

        if let group = selectedBodyPart {
            result = result.filter { $0.muscleGroup == group }
        }

        if let category = selectedCategory {
            result = result.filter { $0.equipment == category }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.muscleGroup.localizedCaseInsensitiveContains(searchText) ||
                $0.equipment.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.name < $1.name }
    }

    var groupedExercises: [(letter: String, items: [ExerciseDefinition])] {
        Dictionary(grouping: filteredExercises) { exercise in
            String(exercise.name.prefix(1)).uppercased()
        }
        .sorted { $0.key < $1.key }
        .map { (letter: $0.key, items: $0.value) }
    }

    var sectionLetters: [String] {
        groupedExercises.map(\.letter)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter row
                HStack(spacing: Theme.spacingSM) {
                    Menu {
                        Button("Any Body Part") { selectedBodyPart = nil }
                        ForEach(ExerciseDefinition.muscleGroups, id: \.self) { group in
                            Button(group) { selectedBodyPart = group }
                        }
                    } label: {
                        filterPill(title: selectedBodyPart ?? "Any Body Part")
                    }

                    Menu {
                        Button("Any Category") { selectedCategory = nil }
                        ForEach(ExerciseDefinition.equipmentTypes, id: \.self) { type in
                            Button(type) { selectedCategory = type }
                        }
                    } label: {
                        filterPill(title: selectedCategory ?? "Any Category")
                    }

                    Spacer()

                    Menu {
                        ForEach(sortOptions, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.vertical, Theme.spacingSM)

                // Exercise list with section index
                ScrollViewReader { proxy in
                    List {
                        ForEach(groupedExercises, id: \.letter) { letter, items in
                            Section {
                                ForEach(items) { exercise in
                                    Button {
                                        onSelect(exercise.name)
                                        dismiss()
                                    } label: {
                                        exerciseRow(exercise)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } header: {
                                Text(letter)
                                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                            .id(letter)
                        }
                    }
                    .listStyle(.plain)
                    .overlay(alignment: .trailing) {
                        VStack(spacing: 1) {
                            ForEach(sectionLetters, id: \.self) { letter in
                                Button {
                                    withAnimation {
                                        proxy.scrollTo(letter, anchor: .top)
                                    }
                                } label: {
                                    Text(letter)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Color.appAccent)
                                }
                            }
                        }
                        .padding(.trailing, Theme.spacingXS)
                    }
                }
            }
            .screenBackground()
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Components

    private func filterPill(title: String) -> some View {
        Text(title)
            .font(.system(size: Theme.captionSize, weight: .medium))
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, Theme.spacingMD)
            .padding(.vertical, Theme.spacingSM)
            .background(Color.appCardBackground)
            .clipShape(Capsule())
    }

    private func exerciseRow(_ exercise: ExerciseDefinition) -> some View {
        HStack(spacing: Theme.spacingMD) {
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(exercise.name)
                    .font(.system(size: Theme.bodySize, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(exercise.muscleGroup)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Text(exercise.equipment)
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextTertiary)
        }
    }
}
