//
//  TakePhoto.swift
//  PMM-iOS
//
//  Created by keyu on 2023/7/1.
//

import ZLPhotoBrowser
import UIKit

class PhotosHelper {
    static func takePhoto(fromViewController viewController: UIViewController? = UIViewController.rootViewController, completion: @escaping (UIImage?) -> Void) {
        guard let viewController else {
            assertionFailure("没找到root view controller")
            return
        }

        let config = ZLPhotoConfiguration.default()
        config.allowEditImage = false
        config.cameraConfiguration.allowRecordVideo(false).allowSwitchCamera(true)
        let camera = ZLCustomCamera()
        camera.takeDoneBlock = { image, _ in
            completion(image)
        }

        viewController.showDetailViewController(camera, sender: nil)
    }

    static func previewPhotos(fromViewController viewController: UIViewController? = UIViewController.rootViewController, photos: [Any], from index: Int) {
        guard let viewController else {
            assertionFailure("没找到root view controller")
            return
        }

        let previewVC = ZLImagePreviewController(datas: photos, index: index, showSelectBtn: false, showBottomView: false, urlImageLoader:  { url, imageView, _, complete in
//            imageView.sd_setImage(with: url) { _, _, _, _ in
//                complete()
//            }
        })
        previewVC.modalPresentationStyle = .fullScreen
        viewController.showDetailViewController(previewVC, sender: nil)
    }
}
