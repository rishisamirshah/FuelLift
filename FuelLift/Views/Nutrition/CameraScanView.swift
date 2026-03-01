import SwiftUI

struct CameraScanView: View {
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @StateObject private var scanVM = FoodScanViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingXL) {
                if let image = scanVM.capturedImage {
                    // Show captured image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                        .padding(.horizontal, Theme.spacingLG)

                    if scanVM.isAnalyzing {
                        VStack(spacing: Theme.spacingMD) {
                            ProgressView()
                                .controlSize(.large)
                                .tint(Color.appAccent)
                            Text("Analyzing your food...")
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(Theme.spacingLG)
                    } else if let nutrition = scanVM.scannedNutrition {
                        FoodDetailView(
                            nutrition: nutrition,
                            mealType: $scanVM.selectedMealType,
                            onSave: { finalNutrition, mealType in
                                let entry = FoodEntry(
                                    name: finalNutrition.name,
                                    calories: finalNutrition.calories,
                                    proteinG: finalNutrition.proteinG,
                                    carbsG: finalNutrition.carbsG,
                                    fatG: finalNutrition.fatG,
                                    servingSize: finalNutrition.servingSize,
                                    mealType: mealType.rawValue,
                                    source: "ai_scan"
                                )
                                if let imgData = image.jpegData(compressionQuality: 0.5) {
                                    entry.imageData = imgData
                                }
                                if let ingredients = finalNutrition.ingredients,
                                   let data = try? JSONEncoder().encode(ingredients) {
                                    entry.ingredientsJSON = String(data: data, encoding: .utf8)
                                }
                                nutritionViewModel.addFoodEntry(entry, context: modelContext)
                                dismiss()
                            }
                        )
                    }

                    if !scanVM.isAnalyzing && scanVM.scannedNutrition == nil {
                        VStack(spacing: Theme.spacingMD) {
                            Button("Analyze Photo") {
                                Task { await scanVM.analyzePhoto() }
                            }
                            .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingLG)
                            .background(Color.appAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                            .padding(.horizontal, Theme.spacingXL)

                            Button("Retake") {
                                scanVM.reset()
                            }
                            .font(.system(size: Theme.bodySize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                } else {
                    // No image yet — prompt
                    Spacer()

                    VStack(spacing: Theme.spacingLG) {
                        Image("icon_camera").pixelArt()
                            .frame(width: 48, height: 48)
                            .opacity(0.5)

                        Text("Take a photo of your food")
                            .font(.system(size: Theme.headlineSize, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Our AI will estimate calories, protein, carbs, and fat.")
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.spacingHuge)

                        // Instant Add button
                        Button {
                            showCamera = true
                        } label: {
                            Label {
                                Text("Open Camera")
                                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            } icon: {
                                Image("icon_camera").pixelArt().frame(width: 24, height: 24)
                            }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingLG)
                                .background(Color.appAccent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        }
                        .padding(.horizontal, Theme.spacingHuge)

                        PhotoLibraryPicker(selectedImage: $scanVM.capturedImage)
                    }

                    Spacer()
                }
            }
            .screenBackground()
            .navigationTitle("Scan Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraImagePicker(image: $scanVM.capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: scanVM.capturedImage) { _, newImage in
                if newImage != nil {
                    // Create pending entry immediately and dismiss
                    if let pendingEntry = scanVM.createPendingEntry() {
                        modelContext.insert(pendingEntry)
                        try? modelContext.save()

                        // Dismiss camera so user sees shimmer card on dashboard
                        dismiss()

                        // Continue analysis in background
                        let image = newImage!
                        Task {
                            do {
                                let nutrition = try await GeminiService.shared.analyzeFoodPhoto(image)
                                // Update the pending entry with real data
                                pendingEntry.name = nutrition.name
                                pendingEntry.calories = nutrition.calories
                                pendingEntry.proteinG = nutrition.proteinG
                                pendingEntry.carbsG = nutrition.carbsG
                                pendingEntry.fatG = nutrition.fatG
                                pendingEntry.servingSize = nutrition.servingSize
                                pendingEntry.analysisStatus = "completed"
                                if let ingredients = nutrition.ingredients,
                                   let data = try? JSONEncoder().encode(ingredients) {
                                    pendingEntry.ingredientsJSON = String(data: data, encoding: .utf8)
                                }
                                try? modelContext.save()
                            } catch {
                                pendingEntry.analysisStatus = "failed"
                                pendingEntry.name = "Analysis failed"
                                try? modelContext.save()
                            }
                        }
                    }
                }
            }
            .alert("Error", isPresented: $scanVM.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(scanVM.errorMessage ?? "Unknown error")
            }
        }
    }
}
