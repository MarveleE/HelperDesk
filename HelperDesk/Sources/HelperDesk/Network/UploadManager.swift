
import UIKit
import Moya
import Alamofire

class UploadManager: NSObject {

    static let shard = UploadManager()

    static func uploadImage(_ image: UIImage) -> String {
        IdahProgressHUD.show(style: .loading)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            IdahProgressHUD.dismiss()
        }
        return "https://picsum.photos/\(Int.random(in: 200...400))"
    }
}

extension UploadManager {
    func compressImage(_ image: UIImage, to maxSizeInKB: Int) -> Data? {
        var scaledImage = image
        var imageData = image.pngData() // 初始 PNG 数据

        while (imageData?.count ?? 0) > maxSizeInKB {
            let compressionRatio: CGFloat = 0.9 // 缩放比例
            let newWidth = scaledImage.size.width * compressionRatio
            let newHeight = scaledImage.size.height * compressionRatio
            let newSize = CGSize(width: newWidth, height: newHeight)

            // 将图片尺寸调整为新大小
            UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
            scaledImage.draw(in: CGRect(origin: .zero, size: newSize))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? scaledImage
            UIGraphicsEndImageContext()

            // 更新 PNG 数据
            imageData = scaledImage.pngData()
        }

        return imageData
    }
}
