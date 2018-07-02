//
//  UIViewController+ext.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIViewController {
    
    public func addChild(viewController: UIViewController, inRect rect: CGRect) {
        self.addChildViewController(viewController)
        viewController.view.frame = rect
        self.view.addSubview(viewController.view)
        self.view.bringSubview(toFront: viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    public func removeChild(viewControllerId: String) {
        guard let target = self.childViewControllers.filter ({ (vc) -> Bool in
            return vc.restorationIdentifier == viewControllerId
        }).first else { return }
        target.willMove(toParentViewController: nil)
        target.view.removeFromSuperview()
        target.removeFromParentViewController()
    }
    
    public func showGADInterstitial(adUnitID: String) -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: adUnitID)
        interstitial.load(GADRequest())
        return interstitial
    }
    
}
