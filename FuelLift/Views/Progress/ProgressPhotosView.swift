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

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Upload CTA card
                VStack(alignment: .leading, spacing: Theme.spacingMD) {
                    Text("Progress Photos")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: Theme.spacingMD) {
                        Image(systemName: "person.crop.rectangle.badge.plus")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.appTextTertiary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Want to add a photo to track your progress?")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)

                            Button {
                                showCamera = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("Upload a Photo")
                                        .font(.system(size: Theme.captionSize, weight: .semibold))
                                }
                                .foregroundStyle(Color.appTextPrimary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .cardStyle()
                .padding(.horizontal, Theme.spacingLG)

                if photosMetrics.isEmpty {
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.appTextTertiary)
                        Text("No progress photos yet")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.top, Theme.spacingHuge)
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
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                        .padding(4)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                            }
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
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
