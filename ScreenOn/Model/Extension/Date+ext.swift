//
//  Date+ext.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 4/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import Foundation

extension Date {
    
    func toString(format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
