import UIKit
import Photos

/// 图片保存到相册
enum ImageSaver {

    /// 保存 UIImage 到相册
    /// - Parameters:
    ///   - image: 要保存的图片
    ///   - completion: 完成回调，success 表示是否成功
    static func save(image: UIImage, completion: @escaping (Bool) -> Void) {
        // 请求相册权限
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            UIImageWriteToSavedPhotosAlbum(
                image,
                nil,
                nil,
                nil
            )
            DispatchQueue.main.async { completion(true) }
        }
    }
}
