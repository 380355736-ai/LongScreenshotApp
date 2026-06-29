import SwiftUI

struct ContentView: View {
    @EnvironmentObject var recorder: ScreenRecorder
    @State private var isProcessing = false
    @State private var processingProgress: Double = 0
    @State private var processingError: String?
    @State private var resultImage: UIImage?
    @State private var showRecorderAlert = false
    @State private var recorderAlertMessage = ""

    var body: some View {
        NavigationStack {
            Group {
                if isProcessing {
                    ProcessingView(progress: processingProgress, errorMessage: processingError)
                        .onTapGesture {
                            if processingError != nil { resetToHome() }
                        }
                } else if let image = resultImage {
                    ResultView(image: image, onBack: resetToHome)
                } else {
                    HomeView(
                        isRecording: recorder.isRecording,
                        onStart: {
                            recorder.startRecording()
                            // 检查录制启动是否立即失败
                            if let err = recorder.errorMessage {
                                recorderAlertMessage = err
                                showRecorderAlert = true
                            }
                        },
                        onStop: {
                            recorder.stopRecording { videoURL in
                                guard let url = videoURL else {
                                    processingError = recorder.errorMessage ?? "录制失败，未获取到视频文件"
                                    isProcessing = true
                                    return
                                }
                                isProcessing = true
                                processingProgress = 0
                                processingError = nil
                                processVideo(url: url)
                            }
                        }
                    )
                }
            }
            .navigationBarHidden(true)
            .alert("录制失败", isPresented: $showRecorderAlert) {
                Button("确定", role: .cancel) {
                    recorder.errorMessage = nil
                }
            } message: {
                Text(recorderAlertMessage)
            }
        }
    }

    private func resetToHome() {
        isProcessing = false
        processingProgress = 0
        processingError = nil
        resultImage = nil
    }

    private func processVideo(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Step 1: 提取帧 (0% -> 25%)
            DispatchQueue.main.async { processingProgress = 0.05 }
            let frames = FrameExtractor.extract(from: url, fps: 10)
            guard !frames.isEmpty else {
                DispatchQueue.main.async {
                    processingError = "未能从录制的视频中提取到有效帧"
                }
                return
            }

            // Step 2: 检测重叠 (25% -> 50%)
            DispatchQueue.main.async { processingProgress = 0.3 }
            let detector = OverlapDetector()
            let overlaps = detector.findAllOverlaps(in: frames)

            // Step 3: 拼接 (50% -> 85%)
            DispatchQueue.main.async { processingProgress = 0.55 }
            let stitcher = ImageStitcher()
            let result = stitcher.stitch(frames: frames, overlaps: overlaps)

           // Step 4: 完成 (85% -> 100%)
           DispatchQueue.main.async { processingProgress = 0.9 }
           // 清理临时视频
           try? FileManager.default.removeItem(at: url)

           DispatchQueue.main.async {
                if let finalImage = result {
                    isProcessing = false
                    resultImage = finalImage
                } else {
                    processingError = "图像拼接失败"
                }
            }
        }
    }
}
