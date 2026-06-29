import UIKit

/// 将多帧图像按重叠量拼接成一张长图
class ImageStitcher {

    func stitch(frames: [UIImage], overlaps: [CGFloat]) -> UIImage? {
        guard !frames.isEmpty else { return nil }
        if frames.count == 1 { return frames[0] }

        // 计算总画布高度
        let width = frames[0].size.width
        var totalHeight: CGFloat = frames[0].size.height
        for i in 0..<(frames.count - 1) {
            let overlap = i < overlaps.count ? overlaps[i] : 0
            totalHeight += frames[i + 1].size.height - overlap
        }

        // 逐帧绘制
        let format = UIGraphicsImageRendererFormat()
        format.scale = frames[0].scale
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: width, height: totalHeight),
            format: format
        )

        let result = renderer.image { _ in
            var currentY: CGFloat = 0
            for i in 0..<frames.count {
                let frame = frames[i]
                let frameHeight = frame.size.height
                frame.draw(in: CGRect(x: 0, y: currentY, width: width, height: frameHeight))
                if i < frames.count - 1 {
                    let overlap = i < overlaps.count ? overlaps[i] : 0
                    currentY += frameHeight - overlap
                }
            }
        }

        return trimBlackBorders(result)
    }

    private func trimBlackBorders(_ image: UIImage?) -> UIImage? {
        guard let image = image, let cgImage = image.cgImage else {
            return image
        }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let trimX = width * 0.02
        let trimWidth = width * 0.96
        guard let cropped = cgImage.cropping(
            to: CGRect(x: trimX, y: 0, width: trimWidth, height: height)
        ) else {
            return image
        }
        return UIImage(cgImage: cropped)
    }
}
