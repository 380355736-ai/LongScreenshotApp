import SwiftUI

/// 拼接结果预览页面
struct ResultView: View {
    let image: UIImage
    let onBack: () -> Void

    @State private var showSavedAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Button(action: onBack) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("长图预览")
                    .font(.headline)

                Spacer()

                Button(action: share) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()

            // 图片预览（可缩放滚动）
            ScrollView([.vertical, .horizontal]) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(Color.white)
            }
            .background(Color(.systemGroupedBackground))

            // 底部操作栏
            HStack(spacing: 40) {
                Button(action: backToHome) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                        Text("返回")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                Button(action: saveToPhotos) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.title3)
                        Text("保存")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }

                Button(action: share) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title3)
                        Text("分享")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(.regularMaterial)
        }
        .alert("已保存", isPresented: $showSavedAlert) {
            Button("好", role: .cancel) {}
        } message: {
            Text("长图已保存到相册")
        }
    }

    private func saveToPhotos() {
        ImageSaver.save(image: image) { success in
            if success {
                showSavedAlert = true
            }
        }
    }

    private func share() {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }

    private func backToHome() {
        onBack()
    }
}
