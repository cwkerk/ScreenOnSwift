//
//  PeerSessionManager.swift
//  ScreenOn
//
//  Created by Aaron Lee on 2/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeerSessionManager: NSObject {
    
    private let devicePeerID = MCPeerID(displayName: UIDevice.current.name)
    
    private var serviceType = ""
    
    private lazy var serviceAdvertiser: MCNearbyServiceAdvertiser = {
        let info = [String: String]()
        // TODO: pass user details to "info" for p2p session invitation purpose
        let advertiser = MCNearbyServiceAdvertiser(peer: self.devicePeerID, discoveryInfo: info, serviceType: self.serviceType)
        advertiser.delegate = self
        return advertiser
    }()
    
    private lazy var serviceBrowser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: self.devicePeerID, serviceType: self.serviceType)
        return browser
    }()
    
    lazy var serviceSession: MCSession = {
        let securityIDs = [Any]()
        // pass security ID to "securityIDs" for security purpose
        let session = MCSession(peer: self.devicePeerID, securityIdentity: securityIDs, encryptionPreference: .optional)
        return session
    }()

    init(serviceType: String) {
        super.init()
        self.serviceType = serviceType
    }
    
}

extension PeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // TODO: to handle invitation here
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    }
    
}

extension PeerSessionManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // TODO: to send invitation here
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }
    
}

extension PeerSessionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // TODO: peers' state handling here
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // TODO: data transfer starts here
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // TODO: data streaming goes here
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // TODO: file transfer starts here
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // TODO: file transfer ends here
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        // TODO: SSL pinning goes here
    }
    
}
