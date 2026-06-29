import SwiftUI

/// 处理中的进度页面
struct ProcessingView: View {
    @State private var progress: Double = 0
    @State private var stepText = "提取视频帧..."

    private let steps = [
        "提取视频帧...",
        "检测图像重叠...",
        "拼接长图中...",
        "裁剪优化中..."
    ]

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
                    .animation(.easeInOut(duration: 0.5), value: progress)

                Image(systemName: "scissors")
                    .font(.title)
                    .foregroundColor(.blue)
            }

            Text("正在处理中...")
                .font(.title2)
                .fontWeight(.semibold)

            Text(stepText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 进度条
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal, 60)

            Spacer()
        }
        .onAppear {
            startSimulatedProgress()
        }
    }

    /// 模拟进度动画（实际进度由拼接过程驱动）
    private func startSimulatedProgress() {
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
            let stepIndex = min(Int(progress * 4), steps.count - 1)
            stepText = steps[stepIndex]

            if progress < 0.9 {
                progress += Double.random(in: 0.1...0.25)
            } else if progress >= 1.0 {
                timer.invalidate()
            }
        }
    }
}
