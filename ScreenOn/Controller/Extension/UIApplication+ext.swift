//
//  UIApplication+ext.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func getCurrentViewController(from: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = from as? UINavigationController {
            return self.getCurrentViewController(from: nav.visibleViewController)
        } else if let tab = from as? UITabBarController, let selectedVC = tab.selectedViewController {
            return self.getCurrentViewController(from: selectedVC)
        } else if let presentedVC = from?.presentedViewController {
            return self.getCurrentViewController(from: presentedVC)
        } else {
            return from
        }
    }
    
}
