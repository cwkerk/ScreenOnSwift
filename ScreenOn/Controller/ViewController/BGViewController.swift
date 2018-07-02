//
//  BGViewController.swift
//  ScreenOn
//
//  Created by Aaron Lee on 2/7/18.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit

class BGViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.view.center.y - 50))
        path.addLine(to: CGPoint(x: self.view.bounds.size.width, y: self.view.center.y + 50))
        path.addLine(to: CGPoint(x: self.view.bounds.size.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        let maskLayer = CAShapeLayer(layer: self.view.layer)
        maskLayer.fillColor = UIColor.purple.cgColor
        maskLayer.path = path.cgPath
        self.view.layer.insertSublayer(maskLayer, at: 0)
    }

}
