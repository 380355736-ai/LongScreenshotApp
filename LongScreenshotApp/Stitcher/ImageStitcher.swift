import UIKit

/// 将多帧图像按重叠量拼接成一张长图
class ImageStitcher {

    /// 拼接帧序列
    /// - Parameters:
    ///   - frames: 按从上到下顺序排列的帧图像
    ///   - overlaps: 相邻帧之间的 Y 轴重叠量（数量 = frames.count - 1）
    /// - Returns: 拼接完成的长图
    func stitch(frames: [UIImage], overlaps: [CGFloat]) -> UIImage? {
        guard !frames.isEmpty else { return nil }

        if frames.count == 1 {
            return frames[0]
        }

        // 计算总画布高度
        let width = frames[0].size.width
        var totalHeight: CGFloat = frames[0].size.height
        for i in 0..<(frames.count - 1) {
            let overlap = i < overlaps.count ? overlaps[i] : 0
            totalHeight += frames[i + 1].size.height - overlap
        }

        let canvasSize = CGSize(width: width, height: totalHeight)

        // 开始绘制
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        var currentY: CGFloat = 0

        for i in 0..<frames.count {
            let frame = frames[i]
            let frameHeight = frame.size.height

            // 绘制当前帧
            frame.draw(in: CGRect(x: 0, y: currentY, width: width, height: frameHeight))

            // 计算下一帧的起始位置
            if i < frames.count - 1 {
                let overlap = i < overlaps.count ? overlaps[i] : 0
                currentY += frameHeight - overlap
            }
        }

        let result = UIGraphicsGetImageFromCurrentImageContext()

        // 裁剪左右黑边
        return trimBlackBorders(result)
    }

    /// 裁剪图片左右黑边
    private func trimBlackBorders(_ image: UIImage?) -> UIImage? {
        guard let image = image, let cgImage = image.cgImage else {
            return image
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // 简单裁剪：左右各去掉 2%（通常是状态栏区域）
        let trimRatio: CGFloat = 0.02
        let trimX = width * trimRatio
        let trimWidth = width * (1 - 2 * trimRatio)

        let cropRect = CGRect(x: trimX, y: 0, width: trimWidth, height: height)
        guard let cropped = cgImage.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cropped)
    }
}
