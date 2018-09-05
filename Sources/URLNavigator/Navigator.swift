#if os(iOS) || os(tvOS)
import UIKit

#if !COCOAPODS
import URLMatcher
#endif

@objc open class Navigator: NSObject, NavigatorType {
    static let shared: Navigator = Navigator()
    
  open let matcher = URLMatcher()
  open weak var delegate: NavigatorDelegate?

  private var viewControllerFactories = [URLPattern: ViewControllerFactory]()
  private var handlerFactories = [URLPattern: URLOpenHandlerFactory]()

    public override init() {
    // ⛵ I'm a Navigator!
  }

  open func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory) {
    self.viewControllerFactories[pattern] = factory
  }

  open func handle(_ pattern: URLPattern, _ factory: @escaping URLOpenHandlerFactory) {
    self.handlerFactories[pattern] = factory
  }

  open func viewController(for url: URLConvertible, context: Any? = nil) -> UIViewController? {
    let urlPatterns = Array(self.viewControllerFactories.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
    guard let factory = self.viewControllerFactories[match.pattern] else { return nil }
    return factory(url, match.values, context)
  }

  open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
    let urlPatterns = Array(self.handlerFactories.keys)
    guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
    guard let handler = self.handlerFactories[match.pattern] else { return nil }
    return { handler(url, match.values, context) }
  }
}

extension Navigator {
    @discardableResult
    @objc public class func push(_ url: String, context: Any? = nil, from: UINavigationController? = nil, animated: Bool = true) -> UIViewController? {
        return Navigator.shared.pushURL(url, context: context, from: from, animated: animated)
    }
    
    @discardableResult
    @objc public class func push(_ viewController: UIViewController, from: UINavigationController? = nil, animated: Bool = true) -> UIViewController? {
        return Navigator.shared.pushViewController(viewController, from: from, animated: animated)
    }
    
    @discardableResult
    @objc public class func present(_ url: String, context: Any? = nil, wrap: UINavigationController.Type? = nil, from: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> UIViewController? {
        return Navigator.shared.presentURL(url, context: context, wrap: wrap, from: from, animated: animated, completion: completion)
    }
    
    @discardableResult
    @objc public class func present(_ viewController: UIViewController, wrap: UINavigationController.Type? = nil, from: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> UIViewController? {
        return Navigator.shared.presentViewController(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
    }
    
    @discardableResult
    @objc public class func open(_ url: String, context: Any? = nil) -> Bool {
        return Navigator.shared.openURL(url, context: context)
    }
}

extension Navigator {
    @discardableResult
    public class func push(_ url: URLConvertible, context: Any? = nil, from: UINavigationControllerType? = nil, animated: Bool = true) -> UIViewController? {
        return Navigator.shared.pushURL(url, context: context, from: from, animated: animated)
    }
    
    @discardableResult
    public class func present(_ url: URLConvertible, context: Any? = nil, wrap: UINavigationController.Type? = nil, from: UIViewControllerType? = nil, animated: Bool = true, completion: (() -> Void)? = nil) -> UIViewController? {
        return Navigator.shared.presentURL(url, context: context, wrap: wrap, from: from, animated: animated, completion: completion)
    }
    
    @discardableResult
    public class func open(_ url: URLConvertible, context: Any? = nil) -> Bool {
        return Navigator.shared.openURL(url, context: context)
    }
}

#endif
