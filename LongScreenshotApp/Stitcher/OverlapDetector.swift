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

        // 使用现代 Vision API (iOS 14+) 替换已废弃的 VNTranslationalImageRegistrationRequest
        let request = VNGenerateTranslationalImageRegistrationRequest(
            targeted: VNImageRequestTarget(cgImage: topBottom, orientation: .up)
        )

        let handler = VNImageRequestHandler(cgImage: bottomTop, options: [:])
        do {
            try handler.perform([request])
            if let result = request.results?.first {
                // alignmentTransform.ty 为目标图像相对于参考图像的 Y 轴偏移
                // 目标(topBottom)在参考(bottomTop)中向上偏移 => 负值, 取绝对值即为重叠量
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

    /// 像素级回退（取 1/3 高度作为预估重叠）
    private func pixelBasedOverlap(top: UIImage, bottom: UIImage) -> CGFloat {
        guard let topCG = top.cgImage else { return 0 }
        return CGFloat(topCG.height) / 3.0
    }
}
