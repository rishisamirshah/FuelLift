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

    func analyzeDescription() async {
        guard !foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isAnalyzing = true
        errorMessage = nil

        do {
            let nutrition = try await ClaudeService.shared.analyzeFoodDescription(foodDescription)
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
            let nutrition = try await ClaudeService.shared.analyzeFoodPhoto(image)
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

    func reset() {
        capturedImage = nil
        scannedNutrition = nil
        isAnalyzing = false
        errorMessage = nil
    }
}
