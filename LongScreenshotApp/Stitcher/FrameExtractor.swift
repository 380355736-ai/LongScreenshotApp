import AVFoundation
import UIKit

/// 从录制视频中提取关键帧
enum FrameExtractor {

    /// 从视频中按指定帧率提取 UIImage 数组
    /// - Parameters:
    ///   - url: 视频文件 URL
    ///   - fps: 每秒提取帧数，默认 10
    /// - Returns: 帧图像数组
    static func extract(from url: URL, fps: Int = 10) -> [UIImage] {
        let asset = AVAsset(url: url)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("[FrameExtractor] 无法读取视频轨道")
            return []
        }

        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        guard durationSeconds > 0 else { return [] }

        let totalFrames = Int(durationSeconds * Double(fps))
        let interval = CMTimeMake(value: Int64(1000 / fps), timescale: 1000)

        var frames: [UIImage] = []
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        // 分批提取以控制内存
        var times: [NSValue] = []
        for i in 0..<totalFrames {
            let time = CMTimeMake(
                value: Int64(i) * interval.value,
                timescale: interval.timescale
            )
            times.append(NSValue(time: time))
        }

        let semaphore = DispatchSemaphore(value: 0)
        var errorOccurred = false

        generator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, result, error in
            if result == .succeeded, let cgImage = cgImage {
                frames.append(UIImage(cgImage: cgImage))
            } else if result == .failed {
                errorOccurred = true
            }

            if frames.count == totalFrames || errorOccurred {
                semaphore.signal()
            }
        }

        semaphore.wait()

        print("[FrameExtractor] 提取完成: \(frames.count) 帧 / 目标 \(totalFrames) 帧")
        return frames
    }
}
