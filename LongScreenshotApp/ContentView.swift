import SwiftUI

struct ContentView: View {
    @EnvironmentObject var recorder: ScreenRecorder
    @State private var isProcessing = false
    @State private var resultImage: UIImage?

    var body: some View {
        NavigationStack {
            Group {
                if isProcessing {
                    ProcessingView()
                } else if let image = resultImage {
                    ResultView(image: image) {
                        resultImage = nil
                    }
                } else {
                    HomeView(
                        isRecording: recorder.isRecording,
                        onStart: { recorder.startRecording() },
                        onStop: {
                            recorder.stopRecording { videoURL in
                                guard let url = videoURL else { return }
                                isProcessing = true
                                processVideo(url: url)
                            }
                        }
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func processVideo(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let frames = FrameExtractor.extract(from: url, fps: 10)
            let detector = OverlapDetector()
            let overlaps = detector.findAllOverlaps(in: frames)
            let stitcher = ImageStitcher()
            let result = stitcher.stitch(frames: frames, overlaps: overlaps)

            DispatchQueue.main.async {
                isProcessing = false
                resultImage = result
            }
        }
    }
}
