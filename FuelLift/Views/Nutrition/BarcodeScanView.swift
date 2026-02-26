import SwiftUI
import AVFoundation

struct BarcodeScanView: View {
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @StateObject private var scanVM = FoodScanViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var scannedCode: String?

    var body: some View {
        NavigationStack {
            VStack {
                if let nutrition = scanVM.scannedNutrition {
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
                                source: "barcode"
                            )
                            entry.barcode = scannedCode
                            nutritionViewModel.addFoodEntry(entry, context: modelContext)
                            dismiss()
                        }
                    )
                    .padding()
                } else if scanVM.isAnalyzing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Looking up product...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    BarcodeScannerView { code in
                        scannedCode = code
                        Task { await scanVM.lookupBarcode(code) }
                    }
                    .overlay(alignment: .bottom) {
                        Text("Point camera at a barcode")
                            .font(.subheadline)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: $scanVM.showError) {
                Button("OK") { scanVM.reset() }
            } message: {
                Text(scanVM.errorMessage ?? "Unknown error")
            }
        }
    }
}

// MARK: - Barcode Scanner UIKit Wrapper

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let vc = BarcodeScannerViewController()
        vc.onCodeScanned = onCodeScanned
        return vc
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?
    private var captureSession: AVCaptureSession?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let session = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else { return }

        session.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession = session

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }

        hasScanned = true
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        captureSession?.stopRunning()
        onCodeScanned?(stringValue)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}
