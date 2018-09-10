#if os(iOS) || os(tvOS)
import UIKit

#if !COCOAPODS
import URLMatcher
#endif

@objc open class Navigator: NSObject, NavigatorType {
   public static let shared: Navigator = Navigator()
    
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
    
    /// 打开一个指定的url，会判断要用push还是present，如果参数里面有isPresent 则用present, 如果没有，则用push
    ///
    /// - Parameters:
    ///   - url: 要打开的url
    ///   - context: 上下文，可以传delegate,闭包等等
    /// - Returns: 成功处理返回true,未处理返回false
    public func openURL(_ url: URLConvertible, context: Any?) -> Bool {
        /// 先判断是不是handler的形式
        if let handler = self.handler(for: url, context: context) {
            return handler()
        }
        
        /// 如果不是handler类型，判断viewController类型
        if let viewController = self.viewController(for: url, context: context) {
            let urlPatterns = Array(self.viewControllerFactories.keys)
            if let match = self.matcher.match(url, from: urlPatterns) {
                if let _ = match.values["isPresent"] as? Bool {
                    self.presentViewController(viewController, wrap: nil, from: nil, animated: true, completion: nil)
                }
            }
            
            self.pushViewController(viewController)
        }
        
        return false
    }
}

extension Navigator {
    public class func open(_ url: URLConvertible, context: Any? = nil) -> Bool {
        return Navigator.shared.openURL(url, context:context)
    }
    
    @objc public class func open(_ url: String, context: Any?) -> Bool {
        return Navigator.shared.openURL(url, context:context)
    }
    
    @objc public class func open(_ url: String) -> Bool {
        return Navigator.shared.openURL(url, context:nil)
    }
}

#endif
