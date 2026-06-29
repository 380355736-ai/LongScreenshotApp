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
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            // UIImageWriteToSavedPhotosAlbum 需要 target-action 回调
            let saver = ImageSaverProxy()
            saver.completion = completion
            UIImageWriteToSavedPhotosAlbum(
                image,
                saver,
                #selector(ImageSaverProxy.image(_:didFinishSavingWithError:contextInfo:)),
                nil
            )
        }
    }
}

/// UIImageWriteToSavedPhotosAlbum 的代理对象
private class ImageSaverProxy: NSObject {
    var completion: ((Bool) -> Void)?

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        DispatchQueue.main.async {
            self.completion?(error == nil)
            self.completion = nil
        }
    }
}
