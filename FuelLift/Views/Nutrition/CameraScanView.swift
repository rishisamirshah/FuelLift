import SwiftUI

struct CameraScanView: View {
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @StateObject private var scanVM = FoodScanViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = scanVM.capturedImage {
                    // Show captured image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                    if scanVM.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Analyzing your food...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else if let nutrition = scanVM.scannedNutrition {
                        // Show results
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
                                nutritionViewModel.addFoodEntry(entry, context: modelContext)
                                dismiss()
                            }
                        )
                    }

                    if !scanVM.isAnalyzing && scanVM.scannedNutrition == nil {
                        Button("Analyze Photo") {
                            Task { await scanVM.analyzePhoto() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)

                        Button("Retake") {
                            scanVM.reset()
                        }
                        .foregroundStyle(.secondary)
                    }
                } else {
                    // No image yet
                    VStack(spacing: 16) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 80))
                            .foregroundStyle(.orange.opacity(0.5))

                        Text("Take a photo of your food")
                            .font(.headline)

                        Text("Our AI will estimate calories, protein, carbs, and fat.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button {
                            showCamera = true
                        } label: {
                            Label("Open Camera", systemImage: "camera.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.orange)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 40)

                        PhotoLibraryPicker(selectedImage: $scanVM.capturedImage)
                    }
                    .padding(.top, 40)
                }

                Spacer()
            }
            .navigationTitle("Scan Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraImagePicker(image: $scanVM.capturedImage)
                    .ignoresSafeArea()
            }
            .onChange(of: scanVM.capturedImage) { _, newImage in
                if newImage != nil {
                    Task { await scanVM.analyzePhoto() }
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
