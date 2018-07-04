//
//  LoginViewController.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleSignIn
import FBSDKLoginKit
import PinterestSDK

class LoginViewController: UIViewController {
    
    private let nextDestinationSegueID = "startApp"
    private let pinterestKey = "pinterest"
    
    @IBOutlet weak var appLogoView: UIImageView!
    @IBOutlet weak var loginBlurView: UIVisualEffectView!
    @IBOutlet weak var gidSigninButton: GIDSignInButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var pinterestLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appLogoView.layer.cornerRadius = 10.0
        self.loginBlurView.layer.cornerRadius = 20.0
        GIDSignIn.sharedInstance().uiDelegate = self
        self.gidSigninButton.style = .wide
        self.fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        self.fbLoginButton.backgroundColor = UIColor.clear
        self.fbLoginButton.layer.shadowColor = UIColor.darkGray.cgColor
        self.fbLoginButton.layer.shadowRadius = 1.0
        self.fbLoginButton.layer.shadowOpacity = 1.0
        self.fbLoginButton.layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        self.fbLoginButton.constraints.forEach { (c) in
            if c.firstAttribute == .height && c.constant != 50 {
                self.fbLoginButton.removeConstraint(c)
            }
        }
        self.fbLoginButton.delegate = self
        self.fbLoginButton.readPermissions = ["email", "public_profile"]
        self.pinterestLoginButton.contentHorizontalAlignment = .left
        self.pinterestLoginButton.layer.cornerRadius = 3.0
        self.pinterestLoginButton.layer.shadowColor = UIColor.darkGray.cgColor
        self.pinterestLoginButton.layer.shadowRadius = 1.0
        self.pinterestLoginButton.layer.shadowOpacity = 1.0
        self.pinterestLoginButton.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.updatePinterestButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePinterestButton()
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            guard let user = GIDSignIn.sharedInstance().currentUser else { return }
            let id = user.profile.name ?? user.profile.email
            let alert = UIAlertController(title: "Google Sign In", message: "Sign in as \(id!)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                GIDSignIn.sharedInstance().signInSilently()
                self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            AudioServicesPlayAlertSound(SystemSoundID(1322))
        } else if FBSDKAccessToken.currentAccessTokenIsActive() {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "name, email"]).start { (conn, res, err) in
                if let response = res as? [String: Any], err == nil {
                    let name = response["name"] as? String
                    let email = response["email"] as? String
                    let alert = UIAlertController(title: "Facebook Login", message: "Login as \(name ?? (email ?? "***"))?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                        self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    AudioServicesPlayAlertSound(SystemSoundID(1322))
                } else {
                    print("Facebook graph requeste error: \(err?.localizedDescription ?? "")")
                }
            }
        } else if let usernameData = KeychainManager.shared.retrieveKeyChain(forService: self.pinterestKey) {
            let username = String(data: usernameData, encoding: .utf8) ?? "*****"
            let alert = UIAlertController(title: "Pinterest Login", message: "Login as \(username)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                PDKClient.sharedInstance().silentlyAuthenticatefromViewController(self, withSuccess: { (response) in
                    let user = response?.user()
                    print("The pinterest user is \(user?.firstName ?? "") \(user?.lastName ?? "")")
                }) { (error) in
                    if let err = error {
                        print("Failed to get authentication from Pinterest due to: \(err.localizedDescription)")
                    } else {
                        self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            AudioServicesPlayAlertSound(SystemSoundID(1322))
        }
    }
    
    @IBAction func pinterestLogin(_ sender: UIButton) {
        if KeychainManager.shared.retrieveKeyChain(forService: self.pinterestKey) == nil {
            let permissions = [PDKClientReadPublicPermissions, PDKClientWritePublicPermissions, PDKClientReadRelationshipsPermissions, PDKClientWriteRelationshipsPermissions]
            PDKClient.sharedInstance().authenticate(withPermissions: permissions, from: self, withSuccess: { (response) in
                guard let user = response?.user(),
                    let usernameData = "\(user.firstName) \(user.lastName)".data(using: .utf8)
                    else { return }
                print("The pinterest user is \(user.firstName ?? "") \(user.lastName ?? "")")
                KeychainManager.shared.createKeyChain(forService: self.pinterestKey, forData: usernameData)
            }) { (error) in
                if let err = error {
                    let alert = UIAlertController(title: "Pinterest login failed", message: "Please try other login approaches", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    AudioServicesPlayAlertSound(SystemSoundID(1322))
                    print("Failed to get authentication from Pinterest due to: \(err.localizedDescription)")
                }
            }
        } else {
            PDKClient.clearAuthorizedUser()
            KeychainManager.shared.deleteKeyChain(forService: self.pinterestKey)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.peerSessionManager = PeerSessionManager(serviceType: "link")
        }
    }
    
    private func updatePinterestButton() {
        if KeychainManager.shared.retrieveKeyChain(forService: self.pinterestKey) == nil {
            self.pinterestLoginButton.setTitle("Continue with Pinterest", for: .normal)
        } else {
            self.pinterestLoginButton.setTitle("Log out", for: .normal)
        }
    }
    
}

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            
        } else {
            self.performSegue(withIdentifier: self.nextDestinationSegueID, sender: nil)
        }
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
