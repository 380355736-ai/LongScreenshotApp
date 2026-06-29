import UIKit
import Vision

/// 使用 Vision 框架检测相邻帧之间的重叠区域
class OverlapDetector {

    /// 检测相邻两帧在垂直方向的重叠像素数
    func findOverlap(top topImage: UIImage, bottom bottomImage: UIImage) -> CGFloat {
        guard let topCG = topImage.cgImage, let bottomCG = bottomImage.cgImage else {
            return 0
        }

        // 截取 top 底部 60% 和 bottom 顶部 60% 做特征匹配
        guard let topBottom = cropBottom(topCG, ratio: 0.6),
              let bottomTop = cropTop(bottomCG, ratio: 0.6) else {
            return pixelBasedOverlap(top: topImage, bottom: bottomImage)
        }

        let request = VNTranslationalImageRegistrationRequest(
            targetedCGImage: topBottom,
            orientation: .up
        )

        let handler = VNImageRequestHandler(cgImage: bottomTop, options: [:])
        do {
            try handler.perform([request])
            if let result = request.results?.first {
                let overlap = -result.alignmentTransform.ty
                return max(0, min(overlap, CGFloat(topCG.height) * 0.6))
            }
        } catch {
            return pixelBasedOverlap(top: topImage, bottom: bottomImage)
        }

        return 0
    }

    /// 对全部帧序列计算重叠量
    func findAllOverlaps(in frames: [UIImage]) -> [CGFloat] {
        guard frames.count > 1 else { return [] }

        var overlaps: [CGFloat] = []
        for i in 0..<(frames.count - 1) {
            let overlap = findOverlap(top: frames[i], bottom: frames[i + 1])
            overlaps.append(overlap)
        }
        return overlaps
    }

    // MARK: - 辅助

    private func cropBottom(_ cgImage: CGImage, ratio: CGFloat) -> CGImage? {
        let h = CGFloat(cgImage.height)
        let rect = CGRect(x: 0, y: h * (1 - ratio), width: CGFloat(cgImage.width), height: h * ratio)
        return cgImage.cropping(to: rect)
    }

    private func cropTop(_ cgImage: CGImage, ratio: CGFloat) -> CGImage? {
        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)
        return cgImage.cropping(to: CGRect(x: 0, y: 0, width: w, height: h * ratio))
    }

    /// 像素级回退
    private func pixelBasedOverlap(top: UIImage, bottom: UIImage) -> CGFloat {
        guard let topCG = top.cgImage else { return 0 }
        return CGFloat(topCG.height) / 3.0
    }
}
