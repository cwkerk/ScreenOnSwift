//
//  UIView+ext.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 2/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

extension UIView {
    
    func setBackgroundStyle1(with color: UIColor) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.center.y - 50))
        path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.center.y + 50))
        path.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        let maskLayer = CAShapeLayer(layer: self.layer)
        maskLayer.fillColor = color.cgColor
        maskLayer.path = path.cgPath
        self.layer.insertSublayer(maskLayer, at: 0)
    }
    
}
