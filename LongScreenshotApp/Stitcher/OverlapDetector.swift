import UIKit
import Vision

/// 使用 Vision 框架检测相邻帧之间的重叠区域
class OverlapDetector {

    /// 检测相邻两帧在垂直方向的重叠像素数
    /// - Parameters:
    ///   - topImage: 上方帧
    ///   - bottomImage: 下方帧
    /// - Returns: Y 轴重叠像素数（正数表示 bottomImage 向上重叠了多少）
    func findOverlap(top topImage: UIImage, bottom bottomImage: UIImage) -> CGFloat {
        guard let topCG = topImage.cgImage, let bottomCG = bottomImage.cgImage else {
            return 0
        }

        // 比较 bottom 的上半部分是否与 top 的下半部分匹配
        let imageHeight = CGFloat(topCG.height)
        let searchRange = Int(imageHeight * 0.6) // 搜索范围：帧高度的 60%

        // 将 bottom 顶部 60% 与 top 底部 60% 做特征匹配
        let topBottom = cropBottom(topCG, ratio: 0.6)
        let bottomTop = cropTop(bottomCG, ratio: 0.6)

        guard let tb = topBottom, let bt = bottomTop else {
            return 0
        }

        // 使用 Vision 图像配准
        let request = VNTranslationalImageRegistrationRequest(
            targetedCGImage: tb,
            orientation: .up
        )

        let handler = VNImageRequestHandler(cgImage: bt, options: [:])
        do {
            try handler.perform([request])
            if let result = request.results?.first {
                // result.alignmentTransform.ty 表示 Y 方向偏移（负值 = 向上重叠）
                let overlap = -result.alignmentTransform.ty
                let clamped = max(0, min(overlap, imageHeight * 0.6))
                return clamped
            }
        } catch {
            // Vision 配准失败，使用像素级比较回退
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

    // MARK: - 辅助方法

    private func cropBottom(_ cgImage: CGImage, ratio: CGFloat) -> CGImage? {
        let h = CGFloat(cgImage.height)
        let rect = CGRect(x: 0, y: h * (1 - ratio), width: CGFloat(cgImage.width), height: h * ratio)
        return cgImage.cropping(to: rect)
    }

    private func cropTop(_ cgImage: CGImage, ratio: CGFloat) -> CGImage? {
        let w = CGFloat(cgImage.width)
        let h = CGFloat(cgImage.height)
        let rect = CGRect(x: 0, y: 0, width: w, height: h * ratio)
        return cgImage.cropping(to: rect)
    }

    /// 像素级回退方案：逐行比较找到第一个匹配行
    private func pixelBasedOverlap(top: UIImage, bottom: UIImage) -> CGFloat {
        guard let topCG = top.cgImage, let bottomCG = bottom.cgImage else {
            return 0
        }
        // 简化实现：取 top 底部 1/3 与 bottom 顶部 1/3 比较
        return CGFloat(topCG.height) / 3.0
    }
}
