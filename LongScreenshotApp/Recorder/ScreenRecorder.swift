import ReplayKit
import AVFoundation

/// 屏幕录制管理器，使用 startCapture + AVAssetWriter 直接写入临时文件
class ScreenRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var errorMessage: String?

    private let recorder = RPScreenRecorder.shared()
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var outputURL: URL?
    private var recordingStartTime: CMTime?

    var isAvailable: Bool { recorder.isAvailable }

    // MARK: - 录制

    func startRecording() {
        guard recorder.isAvailable else {
            errorMessage = "设备不支持屏幕录制"
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("recording_\(Int(Date().timeIntervalSince1970)).mp4")
        outputURL = url

        guard let writer = try? AVAssetWriter(outputURL: url, fileType: .mp4) else {
            errorMessage = "无法创建视频写入器"
            return
        }
        assetWriter = writer

        // 视频输入设置（H.264 压缩）
        let scale = UIScreen.main.scale
        let size = UIScreen.main.bounds.size
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(size.width * scale),
            AVVideoHeightKey: Int(size.height * scale)
        ]

        let vInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        vInput.expectsMediaDataInRealTime = true
        videoInput = vInput

        guard writer.canAdd(vInput) else {
            errorMessage = "无法添加视频输入流"
            return
        }
        writer.add(vInput)

        // 音频输入（仅在麦克风启用时）
        recorder.isMicrophoneEnabled = false
        if recorder.isMicrophoneEnabled {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 128000
            ]
            let aInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            aInput.expectsMediaDataInRealTime = true
            audioInput = aInput
            if writer.canAdd(aInput) {
                writer.add(aInput)
            }
        }

        writer.startWriting()
        recordingStartTime = nil

        recorder.startCapture { [weak self] sampleBuffer, bufferType, error in
            guard let self = self, error == nil else { return }

            switch bufferType {
            case .video:
                if self.recordingStartTime == nil {
                    let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    self.recordingStartTime = pts
                    self.assetWriter?.startSession(atSourceTime: pts)
                }

                if let input = self.videoInput, input.isReadyForMoreMediaData {
                    input.append(sampleBuffer)
                }

            case .audio:
                if let input = self.audioInput, input.isReadyForMoreMediaData {
                    input.append(sampleBuffer)
                }

            @unknown default:
                break
            }
        } completionHandler: { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "录制出错: \(error.localizedDescription)"
                }
            }
        }

        DispatchQueue.main.async {
            self.isRecording = true
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        let url = outputURL

        recorder.stopCapture { [weak self] error in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            if let error = error {
                print("[ScreenRecorder] 停止录制失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isRecording = false
                    completion(nil)
                }
                return
            }

            self.videoInput?.markAsFinished()
            self.audioInput?.markAsFinished()

            self.assetWriter?.finishWriting {
                DispatchQueue.main.async {
                    self.isRecording = false
                    if self.assetWriter?.status == .completed {
                        print("[ScreenRecorder] 录制完成: \(url?.path ?? "")")
                        completion(url)
                    } else {
                        print("[ScreenRecorder] 视频写入失败: status=\(self.assetWriter?.status.rawValue ?? -1)")
                        completion(nil)
                    }
                }
            }
        }
    }
}
