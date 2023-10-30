import UIKit
import SnapKit
import MBProgressHUD

enum IdahProgressHUDStyle {
    case loading
    case save
    case tips
    case showMessage(String)
    case showError(String)
    case success(String)
    case fail(String)

    var title: String {
        switch self {
        case .loading:
            return "加载中"
        case .save:
            return "已保存"
        case .tips:
            return "网络繁忙，请稍后再试"
        case .showError(let message):
            return message
        case .showMessage(let message):
            return message
        case .success(let message):
            return message
        case .fail(let message):
            return message
        }
    }

    var width: CGFloat {
        switch self {
        case .loading, .tips, .showError, .showMessage, .success, .fail:
            return 136
        case .save:
            return 120
        }
    }

    var height: CGFloat {
        switch self {
        case .loading, .tips, .showError, .showMessage, .fail:
            return 136
        case .save, .success:
            return 52
        }
    }

    var image: UIImage? {
        switch self {
        case .loading, .showMessage:
            return UIImage(named: "ProgressHUD_loading")
        case .save, .success:
            return UIImage(named: "ProgressHUD_success")
        case .tips, .showError, .fail:
            return UIImage(named: "ProgressHUD_tips")
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .loading, .tips, .showError, .showMessage, .success, .fail:
            return UIColor(hex: "#4C4C4C")
        case .save:
            return UIColor.black.withAlphaComponent(0.6)
        }
    }
}

class IdahProgressHUD: NSObject {
    
    static let shared = IdahProgressHUD()
    static var hud: MBProgressHUD?
    
    // MARK: - Private
    class private func createHUD(size: CGSize, color: UIColor) -> MBProgressHUD? {
        guard let supview = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return nil }
        let hud = MBProgressHUD.showAdded(to: supview, animated: true)
        hud.isUserInteractionEnabled = true
        hud.animationType = .fade
        hud.minSize = size
        hud.layer.cornerRadius = 4
        hud.layer.masksToBounds = true
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = color
        hud.mode = MBProgressHUDMode.customView
        hud.removeFromSuperViewOnHide = true
        hud.show(animated: true)
        return hud
    }

    // MARK: - 加载提示
    class func show(style: IdahProgressHUDStyle = .loading) {

        if let _ = self.hud {
            self.hud?.removeFromSuperview()
            self.hud = nil
        }
        self.hud = createHUD(size: CGSize(width: style.width, height: style.height), color: style.backgroundColor)

        let imageView = UIImageView()
        imageView.image = style.image
        let label = UILabel()
        label.text = style.title
        label.numberOfLines = 2
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        self.hud?.bezelView.addSubview(imageView)
        self.hud?.bezelView.addSubview(label)
        switch style {
        case .loading, .showMessage:
            imageView.snp.makeConstraints {
                $0.top.equalToSuperview().inset(30)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(36)
            }
            label.snp.makeConstraints {
                $0.top.equalTo(imageView.snp.bottom).offset(16)
                $0.leading.trailing.equalToSuperview().inset(12)
            }
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.toValue = NSNumber(value: Double.pi * 2)
            animation.duration = 1
            animation.isCumulative = true
            animation.repeatCount = Float.infinity
            imageView.layer.add(animation, forKey: "transform.rotation.z")
        case .save, .success:
            imageView.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(24)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(24)
            }
            label.snp.makeConstraints {
                $0.leading.equalTo(imageView.snp.trailing).offset(8)
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(24)
            }
            self.hud?.hide(animated: true, afterDelay: 1)
        case .tips, .showError, .fail:
            imageView.snp.makeConstraints {
                $0.top.equalToSuperview().inset(28)
                $0.centerX.equalToSuperview()
                $0.size.equalTo(40)
            }
            label.snp.makeConstraints {
                $0.top.equalTo(imageView.snp.bottom).offset(16)
                $0.centerX.equalToSuperview()
                $0.width.greaterThanOrEqualTo(style.width - 24)
                $0.leading.trailing.equalToSuperview().inset(12)
            }
            self.hud?.hide(animated: true, afterDelay: 1.5)
        }
        self.hud?.mode = MBProgressHUDMode.customView
    }

    class func dismiss(_ time: TimeInterval = 0.0, style: IdahProgressHUDStyle? = nil) {
        guard let hud = self.hud else { return }
        hud.hide(animated: true, afterDelay: time)
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            if let style {
                self.show(style: style)
            } else {
                hud.removeFromSuperview()
                self.hud = nil
            }
        }
    }

    class func toastMessage(_ title: String? = nil, message: String?) {
        guard let superview = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        let hud = MBProgressHUD.showAdded(to: superview, animated: true)
        hud.mode = .text
        hud.label.text = title
        hud.detailsLabel.text = message
        hud.detailsLabel.numberOfLines = 0
        hud.isUserInteractionEnabled = false
        hud.hide(animated: true, afterDelay: 2)
    }
}

extension IdahProgressHUD {
    @discardableResult
    class func toastHUDOnWindow(_ message: String) -> MBProgressHUD? {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return nil }
        return toastHUD(message, superview: window)
    }

    @discardableResult
    class func toastHUD(_ message: String, superview: UIView) -> MBProgressHUD {
        let hud = IdahProgressHUD.defaultHUD(superview)
        hud.mode = .customView

        let container = UIView(frame: .zero)
        hud.customView = container

        let label = UILabel(frame: .zero)
        label.text = message
        label.textColor = .white
        label.numberOfLines = 0

        let icon = UIImageView(image: UIImage(named: "ProgressHUD_tips"))

        container.addSubview(icon)
        container.addSubview(label)
        icon.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(33)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: 1.5)
        return hud
    }

    class func showLoading(in superview: UIView) -> MBProgressHUD {
        let hud = IdahProgressHUD.defaultHUD(superview)
        hud.graceTime = 0.3
        hud.mode = .customView
        hud.bezelView.snp.makeConstraints { make in
            make.size.greaterThanOrEqualTo(136)
        }

        let container = UIView(frame: .zero)
        hud.customView = container

        let label = UILabel(frame: .zero)
        label.text = "加载中"
        label.textColor = .white
        label.numberOfLines = 0

        let icon = UIImageView(image: UIImage(named: "ProgressHUD_loading"))
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber(value: Double.pi * 2)
        animation.duration = 1
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        icon.layer.add(animation, forKey: "transform.rotation.z")

        container.addSubview(icon)
        container.addSubview(label)
        icon.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(31)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        hud.show(animated: true)
        return hud
    }

    private class func defaultHUD(_ superview: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD(view: superview)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .gray
        hud.removeFromSuperViewOnHide = true
        superview.addSubview(hud)
        return hud
    }
}
