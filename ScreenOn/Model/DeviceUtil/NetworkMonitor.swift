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
            currVC?.removeChild(viewControllerId: "NoInternetViewController")
        }
        self.reachability?.whenUnreachable = { _ in
            guard let currVC = UIApplication.getCurrentViewController() else { return }
            let child = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoInternetViewController")
            let rect = CGRect(x: 0, y: currVC.view.layoutMargins.top, width: currVC.view.bounds.size.width, height: 30)
            currVC.addChild(viewController: child, inRect: rect)
        }
    }
    
}
