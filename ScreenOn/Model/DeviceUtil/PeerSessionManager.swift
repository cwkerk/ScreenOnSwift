//
//  PeerSessionManager.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 2/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import CoreLocation
import MultipeerConnectivity

protocol PeerSessionManagerDelegate {
    func updatePeerState(state: MCSessionState, for peer: MCPeerID, in location: CLLocation?)
}

class PeerSessionManager: NSObject {
    
    private let locKey = "myLocation"
    private let myinfoKey = "updateMyInfo"
    
    private var serviceType = ""
    
    private lazy var serviceAdvertiser: MCNearbyServiceAdvertiser = {
        let info = [String: String]()
        // TODO: pass user details to "info" for p2p session invitation purpose
        let advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: info, serviceType: self.serviceType)
        advertiser.delegate = self
        return advertiser
    }()
    
    private lazy var serviceBrowser: MCNearbyServiceBrowser = {
        let browser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: self.serviceType)
        browser.delegate = self
        return browser
    }()
    
    lazy var serviceSession: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        return session
    }()
    
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    var delegate: PeerSessionManagerDelegate?

    init(serviceType: String) {
        super.init()
        self.serviceType = serviceType
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
        CoreLocationManager.shared.location?.addObserver(self, forKeyPath: self.locKey, options: [.new], context: nil)
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        CoreLocationManager.shared.location?.removeObserver(self, forKeyPath: self.locKey)
    }
    
    private func notifyMyLocation() {
        if let loc = CoreLocationManager.shared.location {
            let locInfo = [loc.coordinate.latitude, loc.coordinate.longitude]
            guard let locData = try? JSONSerialization.data(withJSONObject: locInfo, options: .prettyPrinted) else { return }
            self.send(data: locData, to: self.serviceSession.connectedPeers)
        }
    }
    
    func send(data: Data, to peers: [MCPeerID]) {
        do {
            try self.serviceSession.send(data, toPeers: peers, with: .reliable)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }
        switch key {
            case self.locKey, self.myinfoKey: self.notifyMyLocation()
            default: break
        }
    }
    
}

extension PeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            if let vc = UIApplication.getCurrentViewController() {
                let alert = UIAlertController(title: "Invitation from \(peerID.displayName)", message: "Would you like to join his/her session?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    invitationHandler(true, self.serviceSession)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
    
}

extension PeerSessionManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: self.serviceSession, withContext: nil, timeout: 30.0)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.serviceSession.cancelConnectPeer(peerID)
        DispatchQueue.main.async {
            self.delegate?.updatePeerState(state: .notConnected, for: peerID, in: nil)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}
    
}

extension PeerSessionManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.delegate?.updatePeerState(state: state, for: peerID, in: nil)
            if state == .connected {
                self.notifyMyLocation()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let locInfo = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
            if let locArr = locInfo as? [CLLocationDegrees] {
                let loc = CLLocation(latitude: locArr[0], longitude: locArr[1])
                DispatchQueue.main.async {
                    self.delegate?.updatePeerState(state: .connected, for: peerID, in: loc)
                }
            }
        }
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
        certificateHandler(true)
    }
    
}
