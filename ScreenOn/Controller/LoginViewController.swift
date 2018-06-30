//
//  LoginViewController.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginBlurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBlurView.layer.cornerRadius = 20.0
        GIDSignIn.sharedInstance().uiDelegate = self
    }

}

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // TODO: get user profile here
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // TODO: remove user profile here
    }
    
}

extension LoginViewController: GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
    }
    
}
