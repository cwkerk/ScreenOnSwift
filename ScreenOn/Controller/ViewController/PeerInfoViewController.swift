//
//  PeerInfoViewController.swift
//  ScreenOn
//
//  Created by Kerk Chin Wee on 4/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import MultipeerConnectivity

class PeerInfoViewController: UIViewController {
    
    private var peerSessionManager: PeerSessionManager? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.peerSessionManager
        } else {
            return nil
        }
    }
    
    var peer: Peer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var peerNameLabel: UILabel!
    @IBOutlet weak var connectStatusLabel: UILabel!
    @IBOutlet weak var lastJoinedDateLabel: UILabel!
    @IBOutlet weak var peerLocationMapView: MKMapView!
    @IBOutlet weak var connectPeerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setBackgroundStyle1(with: UIColor.purple)
        self.infoView.layer.cornerRadius = 3.0
        self.peerLocationMapView.layer.cornerRadius = 3.0
        self.peerLocationMapView.delegate = self
        self.peerLocationMapView.showsUserLocation = true
        self.connectPeerButton.layer.cornerRadius = 5.0
        if let peer = self.peer {
            self.peerNameLabel.text = peer.name
            self.connectStatusLabel.text = peer.state.description.lowercased()
            self.lastJoinedDateLabel.text = peer.date.toString(format: "dd-MM-yyyy hh:mm:ss a")
            if let loc = peer.location {
                self.peerLocationMapView.centerCoordinate = loc.coordinate
            } else if let loc = CoreLocationManager.shared.location {
                self.peerLocationMapView.centerCoordinate = loc.coordinate
            } else {
                self.peerLocationMapView.bounds = CGRect.zero
            }
            if peer.state == .connected {
                self.connectPeerButton.removeFromSuperview()
                let c = NSLayoutConstraint(item: self.peerLocationMapView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottomMargin, multiplier: 1, constant: -20)
                self.view.addConstraint(c)
            }
        } else {
            let alert = UIAlertController(title: "Unknown peer", message: "No information about this peer is available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            AudioServicesPlayAlertSound(SystemSoundID(1322))
        }
    }
    
    @IBAction func connectPeer(_ sender: UIButton) {
        if let peer = self.peer {
            let locInfo = [peer.location?.coordinate.latitude, peer.location?.coordinate.longitude]
            let data = try? JSONSerialization.data(withJSONObject: locInfo, options: .prettyPrinted)
            self.peerSessionManager?.send(invitation: data, to: MCPeerID(displayName: peer.name))
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension PeerInfoViewController: MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if let peer = self.peer, let loc = peer.location {
            let annotation = MKPointAnnotation()
            annotation.coordinate = loc.coordinate
            annotation.title = peer.name
            mapView.addAnnotation(annotation)
        }
    }
    
}
