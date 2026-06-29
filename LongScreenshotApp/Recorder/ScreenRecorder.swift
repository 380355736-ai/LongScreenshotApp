import ReplayKit
import AVFoundation

/// 屏幕录制管理器，封装 ReplayKit RPScreenRecorder
class ScreenRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var isPermissionGranted = false

    private let recorder = RPScreenRecorder.shared()
    private var outputURL: URL?

    init() {
        checkPermission()
    }

    // MARK: - 权限

    func checkPermission() {
        // ReplayKit 在 startRecording 时会自动弹出权限请求
        isPermissionGranted = recorder.isAvailable
    }

    // MARK: - 录制

    func startRecording() {
        guard recorder.isAvailable else {
            print("[ScreenRecorder] 设备不支持屏幕录制")
            return
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(Date().timeIntervalSince1970).mp4"
        let url = tempDir.appendingPathComponent(fileName)
        outputURL = url

        recorder.startRecording { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[ScreenRecorder] 录制启动失败: \(error.localizedDescription)")
                    return
                }
                self?.isRecording = true
                print("[ScreenRecorder] 录制已开始")
            }
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
            completion(nil)
            return
        }

        guard let url = outputURL else {
            completion(nil)
            return
        }

        recorder.stopRecording { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isRecording = false
                if let error = error {
                    print("[ScreenRecorder] 录制停止失败: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                print("[ScreenRecorder] 录制完成: \(url.path)")
                completion(url)
            }
        }
    }
}
