import SwiftUI

struct HomeView: View {
    let isRecording: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // 图标
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
            }

            // 标题
            VStack(spacing: 8) {
                Text("截长图")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(isRecording
                     ? "正在录制屏幕，请切换到目标 App 滚动浏览"
                     : "点击按钮开始屏幕录制")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // 录制按钮
            Button(action: {
                if isRecording {
                    onStop()
                } else {
                    onStart()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isRecording ? "stop.fill" : "record.circle")
                        .font(.title2)
                    Text(isRecording ? "停止录制" : "开始录制")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(isRecording ? Color.red : Color.blue)
                .clipShape(Capsule())
                .shadow(color: (isRecording ? Color.red : Color.blue).opacity(0.4),
                        radius: 10, y: 5)
            }

            if isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .modifier(PulseAnimation())

                    Text("录制中")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            // 使用说明
            VStack(spacing: 4) {
                Text("使用方法")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text("点击录制 → 切换到任意 App → 慢慢滚动 → 返回点击停止")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 30)
        }
    }
}

/// 录制中脉冲动画
struct PulseAnimation: ViewModifier {
    @State private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(scale)
            .animation(.easeInOut(duration: 0.8).repeatForever(), value: scale)
            .onAppear { scale = 0.3 }
    }
}
