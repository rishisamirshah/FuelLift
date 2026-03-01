import SwiftUI
import UIKit

@MainActor
final class FoodScanViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var scannedNutrition: NutritionData?
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var selectedMealType: MealType = .snack
    @Published var foodDescription: String = ""

    /// Called when a pending entry is created so the dashboard can show a shimmer card immediately.
    var onPendingEntry: ((FoodEntry) -> Void)?

    func analyzeDescription() async {
        guard !foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isAnalyzing = true
        errorMessage = nil

        do {
            let nutrition = try await GeminiService.shared.analyzeFoodDescription(foodDescription)
            scannedNutrition = nutrition
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isAnalyzing = false
    }

    func analyzePhoto() async {
        guard let image = capturedImage else { return }

        isAnalyzing = true
        errorMessage = nil

        do {
            let nutrition = try await GeminiService.shared.analyzeFoodPhoto(image)
            scannedNutrition = nutrition
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isAnalyzing = false
    }

    func lookupBarcode(_ barcode: String) async {
        isAnalyzing = true
        errorMessage = nil

        do {
            let nutrition = try await BarcodeService.shared.lookupBarcode(barcode)
            scannedNutrition = nutrition
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isAnalyzing = false
    }

    func createFoodEntry() -> FoodEntry? {
        guard let nutrition = scannedNutrition else { return nil }

        let source: String
        if capturedImage != nil {
            source = "ai_scan"
        } else if !foodDescription.isEmpty {
            source = "ai_description"
        } else {
            source = "barcode"
        }

        return FoodEntry(
            name: nutrition.name,
            calories: nutrition.calories,
            proteinG: nutrition.proteinG,
            carbsG: nutrition.carbsG,
            fatG: nutrition.fatG,
            servingSize: nutrition.servingSize,
            mealType: selectedMealType.rawValue,
            source: source
        )
    }

    /// Creates a pending FoodEntry with placeholder data and the captured image,
    /// then fires the callback so the dashboard can show it immediately.
    func createPendingEntry() -> FoodEntry? {
        guard let image = capturedImage else { return nil }
        let entry = FoodEntry(
            name: "Analyzing...",
            calories: 0,
            proteinG: 0,
            carbsG: 0,
            fatG: 0,
            servingSize: "",
            mealType: selectedMealType.rawValue,
            source: "ai_scan"
        )
        entry.analysisStatus = "pending"
        if let imgData = image.jpegData(compressionQuality: 0.5) {
            entry.imageData = imgData
        }
        onPendingEntry?(entry)
        return entry
    }

    func reset() {
        capturedImage = nil
        scannedNutrition = nil
        isAnalyzing = false
        errorMessage = nil
    }
}
