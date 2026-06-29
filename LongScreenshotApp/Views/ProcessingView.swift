import SwiftUI

/// 处理中的进度页面（由外部驱动真实进度）
struct ProcessingView: View {
    let progress: Double
    let errorMessage: String?

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 动画图标
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)

                Image(systemName: errorMessage != nil ? "exclamationmark.triangle" : "scissors")
                    .font(.title)
                    .foregroundColor(errorMessage != nil ? .orange : .blue)
            }

            if let error = errorMessage {
                Text("处理失败")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            } else {
                Text("正在处理中...")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(stepText(for: progress))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // 进度条
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal, 60)
            }

            Spacer()
        }
    }

    private func stepText(for progress: Double) -> String {
        switch progress {
        case ..<0.25: return "提取视频帧..."
        case ..<0.50: return "检测图像重叠..."
        case ..<0.75: return "拼接长图中..."
        case ..<1.0:  return "裁剪优化中..."
        default:      return "完成"
        }
    }
}
