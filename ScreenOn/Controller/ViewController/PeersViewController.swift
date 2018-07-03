//
//  PeersViewController.swift
//  ScreenOn
//
//  Created by Aaron Lee on 2/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import AVFoundation

class PeersViewController: UIViewController {
    
    private var peerList = [Peer]()
    private var peerSessionManager: PeerSessionManager? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.peerSessionManager
        } else {
            return nil
        }
    }
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var peersTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setBackgroundStyle1(with: UIColor.purple)
        self.infoView.layer.cornerRadius = 3.0
        self.infoView.layer.backgroundColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        self.peersTableView.layer.cornerRadius = 3.0
        self.peersTableView.layer.backgroundColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        
    }

}

extension PeersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Active Peers"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                let peerName = self.peerList[indexPath.row].name!
                let alert = UIAlertController(title: "Delete peer \(peerName)", message: "Reminder: This action cannot be undo", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    if let session = self.peerSessionManager?.serviceSession,
                    let peer = session.connectedPeers.filter({ return $0.displayName == peerName }).first {
                        session.cancelConnectPeer(peer)
                        self.peerList.remove(at: indexPath.row)
                        self.peersTableView.reloadData()
                    }
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                AudioServicesPlayAlertSound(SystemSoundID(1322))
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourcePeer = self.peerList[sourceIndexPath.row]
        let destinationPeer = self.peerList[destinationIndexPath.row]
        self.peerList[destinationIndexPath.row] = sourcePeer
        self.peerList[sourceIndexPath.row] = destinationPeer
        self.peersTableView.reloadData()
    }
    
}
