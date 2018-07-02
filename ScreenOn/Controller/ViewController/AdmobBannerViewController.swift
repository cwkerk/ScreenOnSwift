//
//  AdmobBannerViewController.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 01/07/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdmobBannerViewController: UIViewController {
    
    private var bannerView: GADBannerView {
        return self.view as! GADBannerView
    }
    
    var adUnitId = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bannerView.delegate = self
        self.bannerView.rootViewController = self
        self.bannerView.adUnitID = self.adUnitId
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        if UIApplication.shared.statusBarOrientation.isPortrait {
            self.bannerView.adSize = kGADAdSizeSmartBannerPortrait
        } else if UIApplication.shared.statusBarOrientation.isLandscape {
            self.bannerView.adSize = kGADAdSizeSmartBannerLandscape
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bannerView.load(GADRequest())
    }

}

extension AdmobBannerViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Admob banner view is receiving ad for unit ID \(self.adUnitId)")
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Admob banner view failed to receive ad for unit ID \(self.adUnitId) due to: \(error.localizedDescription)")
    }
    
}
