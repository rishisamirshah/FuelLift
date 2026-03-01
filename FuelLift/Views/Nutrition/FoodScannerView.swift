import SwiftUI
import AVFoundation
import PhotosUI
import AudioToolbox

// MARK: - Scan Mode

enum ScanMode: String, CaseIterable {
    case scanFood = "Scan Food"
    case barcode = "Barcode"
    case foodLabel = "Food label"

    var iconName: String {
        switch self {
        case .scanFood: return "viewfinder"
        case .barcode: return "barcode"
        case .foodLabel: return "doc.text"
        }
    }
}

// MARK: - Food Scanner View (CalAI-style)

struct FoodScannerView: View {
    @Binding var capturedImage: UIImage?
    var onBarcodeScan: ((String) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraManager()
    @State private var selectedMode: ScanMode = .scanFood
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var flashOn = false
    @State private var shutterScale: CGFloat = 1.0
    @State private var zoomLevel: CGFloat = 1.0
    @State private var cornerPulse = false

    var body: some View {
        ZStack {
            // 1. Live camera preview — full screen
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            // 2. Corner bracket overlay
            scanOverlay

            // 3. Top bar: close + help
            VStack {
                topBar
                Spacer()
            }

            // 4. Bottom controls: zoom + mode tabs + shutter row
            VStack {
                Spacer()
                bottomControls
            }
        }
        .background(Color.black)
        .statusBarHidden()
        .onAppear {
            camera.configure(mode: selectedMode)
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                cornerPulse = true
            }
        }
        .onDisappear {
            camera.stop()
        }
        .onChange(of: selectedMode) { _, newMode in
            camera.switchMode(newMode)
        }
        .onChange(of: camera.capturedPhoto) { _, photo in
            guard let photo else { return }
            capturedImage = photo
            dismiss()
        }
        .onChange(of: camera.scannedBarcode) { _, code in
            guard let code else { return }
            onBarcodeScan?(code)
            dismiss()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                    dismiss()
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Spacer()

            // Help button
            Button {} label: {
                Image(systemName: "questionmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 58)
    }

    // MARK: - Scan Overlay with Corner Brackets

    private var scanOverlay: some View {
        GeometryReader { geo in
            let scanWidth = geo.size.width - 40
            let scanHeight = geo.size.height * 0.50
            let centerX = geo.size.width / 2
            let centerY = geo.size.height * 0.38

            // Corner brackets (white, large)
            cornerBrackets(width: scanWidth, height: scanHeight)
                .position(x: centerX, y: centerY)
                .opacity(cornerPulse ? 1.0 : 0.6)
        }
    }

    private func cornerBrackets(width: CGFloat, height: CGFloat) -> some View {
        let bracketLength: CGFloat = 40
        let lineWidth: CGFloat = 3.5
        let halfW = width / 2
        let halfH = height / 2

        return ZStack {
            // Top-left
            CornerBracket(bracketLength: bracketLength, lineWidth: lineWidth)
                .offset(x: -halfW, y: -halfH)

            // Top-right
            CornerBracket(bracketLength: bracketLength, lineWidth: lineWidth)
                .rotationEffect(.degrees(90))
                .offset(x: halfW, y: -halfH)

            // Bottom-right
            CornerBracket(bracketLength: bracketLength, lineWidth: lineWidth)
                .rotationEffect(.degrees(180))
                .offset(x: halfW, y: halfH)

            // Bottom-left
            CornerBracket(bracketLength: bracketLength, lineWidth: lineWidth)
                .rotationEffect(.degrees(270))
                .offset(x: -halfW, y: halfH)
        }
        .foregroundStyle(.white)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Zoom toggle (.5x / 1x)
            HStack(spacing: 2) {
                zoomButton(label: ".5x", level: 0.5)
                zoomButton(label: "1x", level: 1.0)
            }
            .padding(3)
            .background(Color.black.opacity(0.5))
            .clipShape(Capsule())

            // Mode tabs with icons
            HStack(spacing: 8) {
                ForEach(ScanMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedMode = mode
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 16))
                            Text(mode.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(selectedMode == mode ? .black : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedMode == mode
                            ? Color.white
                            : Color.white.opacity(0.12)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 20)

            // Shutter row: flash | shutter | gallery
            HStack {
                // Flash toggle
                Button {
                    flashOn.toggle()
                    camera.toggleFlash(flashOn)
                } label: {
                    Image(systemName: flashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(flashOn ? Color.appCarbsColor : .white)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }

                Spacer()

                // Shutter button
                Button {
                    shutterScale = 0.85
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                        shutterScale = 1.0
                    }
                    camera.capturePhoto()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 5)
                            .frame(width: 76, height: 76)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                    }
                    .scaleEffect(shutterScale)
                }

                Spacer()

                // Photo library picker
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 36)
        }
        .padding(.top, 16)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private func zoomButton(label: String, level: CGFloat) -> some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                zoomLevel = level
                camera.setZoom(level)
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(zoomLevel == level ? .black : .white.opacity(0.7))
                .frame(width: 42, height: 30)
                .background(zoomLevel == level ? Color.white : Color.clear)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Corner Bracket Shape

private struct CornerBracket: View {
    let bracketLength: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: bracketLength))
            path.addLine(to: CGPoint(x: 0, y: 8))
            path.addQuadCurve(
                to: CGPoint(x: 8, y: 0),
                control: CGPoint(x: 0, y: 0)
            )
            path.addLine(to: CGPoint(x: bracketLength, y: 0))
        }
        .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}

// MARK: - Camera Preview UIKit Wrapper

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private class CameraPreviewUIView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

// MARK: - Camera Manager

@MainActor
final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let metadataOutput = AVCaptureMetadataOutput()
    private var currentDevice: AVCaptureDevice?
    @Published var capturedPhoto: UIImage?
    @Published var scannedBarcode: String?
    private var isConfigured = false
    private var currentMode: ScanMode = .scanFood

    func configure(mode: ScanMode) {
        guard !isConfigured else { return }
        isConfigured = true
        currentMode = mode

        session.beginConfiguration()
        session.sessionPreset = .photo

        // Camera input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        currentDevice = device

        // Photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        // Metadata output for barcodes
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39, .qr]
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func switchMode(_ mode: ScanMode) {
        currentMode = mode
    }

    func setZoom(_ factor: CGFloat) {
        guard let device = currentDevice else { return }
        let clamped = max(device.minAvailableVideoZoomFactor, min(factor, device.maxAvailableVideoZoomFactor))
        try? device.lockForConfiguration()
        device.videoZoomFactor = clamped
        device.unlockForConfiguration()
    }

    func toggleFlash(_ on: Bool) {
        guard let device = currentDevice, device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if let device = currentDevice, device.hasTorch {
            settings.flashMode = device.torchMode == .on ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - Photo Capture Delegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        Task { @MainActor in
            self.capturedPhoto = image
        }
    }
}

// MARK: - Barcode Delegate

extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        Task { @MainActor in
            guard self.currentMode == .barcode else { return }
            guard let metadataObject = metadataObjects.first,
                  let readable = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let value = readable.stringValue,
                  self.scannedBarcode == nil else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.scannedBarcode = value
        }
    }
}
