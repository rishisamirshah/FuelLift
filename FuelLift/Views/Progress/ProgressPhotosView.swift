import SwiftUI
import SwiftData

struct ProgressPhotosView: View {
    @Query(
        filter: #Predicate<BodyMetric> { $0.photoData != nil },
        sort: \BodyMetric.date,
        order: .reverse
    ) private var photosMetrics: [BodyMetric]
    @Environment(\.modelContext) private var modelContext
    @State private var showCamera = false
    @State private var selectedImage: UIImage?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button {
                    showCamera = true
                } label: {
                    Label("Take Progress Photo", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                if photosMetrics.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text("No progress photos yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(photosMetrics, id: \.id) { metric in
                            if let data = metric.photoData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .bottomLeading) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minHeight: 120)
                                        .clipped()

                                    Text(metric.date.shortFormatted)
                                        .font(.caption2.bold())
                                        .padding(4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Progress Photos")
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(image: $selectedImage)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage, let data = image.jpegData(compressionQuality: 0.7) {
                let metric = BodyMetric()
                metric.photoData = data
                modelContext.insert(metric)
                try? modelContext.save()
                selectedImage = nil
            }
        }
    }
}
