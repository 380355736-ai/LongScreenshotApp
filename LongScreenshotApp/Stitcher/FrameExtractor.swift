import AVFoundation
import UIKit

/// 从录制视频中提取关键帧
enum FrameExtractor {

    /// 从视频中按指定帧率提取 UIImage 数组
    static func extract(from url: URL, fps: Int = 10) -> [UIImage] {
        let asset = AVAsset(url: url)
        let durationSeconds: Double

        // 使用现代 API 获取时长
        let semaphore = DispatchSemaphore(value: 0)
        var loadedDuration: Double = 0
        Task {
            do {
                let dur = try await asset.load(.duration)
                loadedDuration = CMTimeGetSeconds(dur)
            } catch {
                loadedDuration = 0
            }
            semaphore.signal()
        }
        semaphore.wait()

        durationSeconds = loadedDuration
        guard durationSeconds > 0 else {
            print("[FrameExtractor] 无法获取视频时长")
            return []
        }

        let totalFrames = Int(durationSeconds * Double(fps))
        let interval = CMTime(value: Int64(1000 / fps), timescale: 1000)

        var frames: [UIImage] = []
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        var times: [NSValue] = []
        for i in 0..<totalFrames {
            times.append(NSValue(time: CMTime(
                value: Int64(i) * interval.value,
                timescale: interval.timescale
            )))
        }

        // 同步提取避免回调死锁
        for timeValue in times {
            do {
                let cgImage = try generator.copyCGImage(
                    at: timeValue.timeValue,
                    actualTime: nil
                )
                frames.append(UIImage(cgImage: cgImage))
            } catch {
                // 跳过无法提取的帧
            }
        }

        print("[FrameExtractor] 提取完成: \(frames.count) / \(totalFrames) 帧")
        return frames
    }
}
