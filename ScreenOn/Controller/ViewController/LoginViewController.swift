//
//  LoginViewController.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import PinterestSDK

class LoginViewController: UIViewController {
    
    private let nextDestinationSegueID = "startApp"
    
    @IBOutlet weak var appLogoView: UIImageView!
    @IBOutlet weak var loginBlurView: UIVisualEffectView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var pinterestLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appLogoView.layer.cornerRadius = 10.0
        self.loginBlurView.layer.cornerRadius = 20.0
        GIDSignIn.sharedInstance().uiDelegate = self
        self.fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        self.fbLoginButton.layer.shadowColor = UIColor.darkGray.cgColor
        self.fbLoginButton.constraints.forEach { (c) in
            if c.firstAttribute == .height && c.constant == 28 {
                self.fbLoginButton.removeConstraint(c)
            }
        }
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["email", "public_profile"]
        self.pinterestLoginButton.contentHorizontalAlignment = .left
        self.pinterestLoginButton.layer.cornerRadius = 3.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
            self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: self)
        } else if FBSDKAccessToken.currentAccessTokenIsActive() {
            self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: self)
        } else {
            PDKClient.sharedInstance().silentlyAuthenticatefromViewController(self, withSuccess: { (response) in
                let user = response?.user()
                print("The pinterest user is \(user?.biography ?? "from unknown background")")
            }) { (error) in
                if let err = error {
                    print("Failed to get authentication from Pinterest due to: \(err.localizedDescription)")
                } else {
                    self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: self)
                }
            }
        }
    }
    
    @IBAction func pinterestLogin(_ sender: UIButton) {
        let permissions = [PDKClientReadPublicPermissions, PDKClientWritePublicPermissions, PDKClientReadRelationshipsPermissions, PDKClientWriteRelationshipsPermissions]
        PDKClient.sharedInstance().authenticate(withPermissions: permissions, from: self, withSuccess: { (response) in
            let user = response?.user()
            print("The pinterest user is \(user?.biography ?? "from unknown background")")
        }) { (error) in
            if let err = error {
                print("Failed to get authentication from Pinterest due to: \(err.localizedDescription)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.peerSessionManager = PeerSessionManager(serviceType: "link")
        }
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

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
}
