//
//  Peer.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 4/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation
import CoreLocation
import MultipeerConnectivity

struct Peer {
    
    var name: String!
    var state: MCSessionState!
    var date: Date!
    var location: CLLocation?
    
    init(name: String, state: MCSessionState, location: CLLocation?) {
        self.name = name
        self.state = state
        self.location = location
        self.date = Date()
    }
    
}
