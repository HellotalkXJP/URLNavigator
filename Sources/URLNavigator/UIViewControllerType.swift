#if os(iOS) || os(tvOS)
import UIKit

@objc public protocol UINavigationControllerType {
  func pushViewController(_ viewController: UIViewController, animated: Bool)
}

@objc public protocol UIViewControllerType {
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension UINavigationController: UINavigationControllerType {}
extension UIViewController: UIViewControllerType {}
#endif
