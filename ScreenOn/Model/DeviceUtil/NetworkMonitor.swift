//
//  NetworkMonitor.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation
import Reachability

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    public let reachability = Reachability()
    
    private init() {
        self.reachability?.whenReachable = { (rch) in
            let currVC = UIApplication.getCurrentViewController()
            guard let target = currVC?.childViewControllers.filter({ (vc) -> Bool in
                return vc.restorationIdentifier == "NoInternetViewController"
            }).first else { return }
            target.willMove(toParentViewController: nil)
            target.view.removeFromSuperview()
            target.removeFromParentViewController()
        }
        self.reachability?.whenUnreachable = { _ in
            let currVC = UIApplication.getCurrentViewController()
            let child = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoInternetViewController")
            let rect = CGRect(x: 0, y: currVC?.view.layoutMargins.top ?? 0, width: currVC?.view.bounds.size.width ?? 0, height: 50)
            currVC?.addChild(viewController: child, inRect: rect)
        }
    }
    
}
