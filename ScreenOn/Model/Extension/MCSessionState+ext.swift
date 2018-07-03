//
//  MCSessionState+ext.swift
//  ScreenOn
//
//  Created by Aaron Lee on 4/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import MultipeerConnectivity

extension MCSessionState {
    
    var description: String {
        switch self {
            case .connected: return "Connected"
            case .notConnected: return "NotConnected"
            case .connecting: return "Connecting"
        }
    }
    
}
