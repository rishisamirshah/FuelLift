import SwiftUI

struct FilterPills<T: Hashable & CustomStringConvertible>: View {
    let options: [T]
    @Binding var selected: T

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            ForEach(options, id: \.self) { option in
                PillButton(
                    title: option.description,
                    isSelected: selected == option
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = option
                    }
                }
            }
        }
    }
}

private struct PillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Theme.captionSize, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : Color.appTextSecondary)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(isSelected ? Color.appAccent : Color.appCardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Common Filter Types

enum TimeFilter: String, CaseIterable, CustomStringConvertible, Hashable {
    case ninetyDays = "90D"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "ALL"

    var description: String { rawValue }

    var days: Int {
        switch self {
        case .ninetyDays: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        case .all: return 9999
        }
    }
}

enum WeekFilter: String, CaseIterable, CustomStringConvertible, Hashable {
    case thisWeek = "This wk"
    case lastWeek = "Last wk"

    var description: String { rawValue }
}

#Preview {
    VStack(spacing: 20) {
        FilterPills(options: TimeFilter.allCases, selected: .constant(.ninetyDays))
        FilterPills(options: WeekFilter.allCases, selected: .constant(.thisWeek))
    }
    .padding()
    .background(Color.appBackground)
}
