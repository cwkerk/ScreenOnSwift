//
//  PeersViewController.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 2/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import MultipeerConnectivity

class PeersViewController: UIViewController {
    
    private let cellId = "peer"
    
    private var peerList = [Peer]()
    private var peerSessionManager: PeerSessionManager? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.peerSessionManager
        } else {
            return nil
        }
    }
    private var selectedPeer: Peer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var peersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setBackgroundStyle1(with: UIColor.purple)
        self.infoView.layer.cornerRadius = 3.0
        self.infoView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.hostNameLabel.text = self.peerSessionManager?.serviceSession.myPeerID.displayName
        self.peerList = self.peerSessionManager?.serviceSession.connectedPeers.compactMap({ (peer) -> Peer? in
            return Peer(name: peer.displayName, state: .connected, location: nil)
        }) ?? [Peer]()
        self.peersTableView.layer.cornerRadius = 3.0
        self.peersTableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.peerSessionManager?.delegate = self
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GADBannerViewController") as? AdmobBannerViewController {
            vc.adUnitId = "ca-app-pub-3940256099942544/2934735716"
            self.addChild(viewController: vc, inRect: CGRect(x: 0, y: self.view.layoutMargins.bottom - 50, width: self.view.bounds.size.width, height: 50))
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.peersTableView.setEditing(editing, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PeerInfoViewController {
            dest.peer = self.selectedPeer
        }
    }
    
}

extension PeersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)
        let color = UIColor(red: 148/255, green: 33/255, blue: 146/255, alpha: 1)
        cell.textLabel?.textColor = color
        cell.textLabel?.text = self.peerList[indexPath.row].name
        cell.imageView?.image = UIImage(named: self.peerList[indexPath.row].state.description)?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = color
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
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
                    self.setEditing(false, animated: true)
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
        self.peersTableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
}

extension PeersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = Bundle.main.loadNibNamed("PeerTableHeaderView", owner: self, options: nil)?.first as? PeerTableHeaderView {
            header.headerLabel.text = "Active Peers"
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPeer = self.peerList[indexPath.row]
        self.performSegue(withIdentifier: "details", sender: nil)
    }
    
}

extension PeersViewController: PeerSessionManagerDelegate {
    
    func peerSession(receive data: Data, from peer: MCPeerID) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            if let locInfo = json as? [CLLocationDegrees], locInfo.count == 2 {
                guard let peerIndex = self.peerList.index(where: { return $0.name == peer.displayName }) else { return }
                self.peerList[peerIndex.distance(to: self.peerList.startIndex)].location = CLLocation(latitude: locInfo[0], longitude: locInfo[1])
                self.peersTableView.reloadData()
            } else {
                // TODO: process other data
            }
        }
    }
    
    func peerSession(remove peer: MCPeerID) {
        self.peerList = self.peerList.filter { return $0.name != peer.displayName }
        self.peersTableView.reloadData()
    }
    
    func peerSession(update state: MCSessionState, for peer: MCPeerID) {
        if let peerIndex = self.peerList.index(where: { return $0.name == peer.displayName }) {
            self.peerList[peerIndex.distance(to: self.peerList.startIndex)].state = state
        } else {
            self.peerList.insert(Peer(name: peer.displayName, state: state, location: nil), at: 0)
        }
        self.peersTableView.reloadData()
    }
    
}
