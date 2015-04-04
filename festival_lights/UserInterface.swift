//
//  File.swift
//  festival_lights
//
//  Created by Daniel Berger on 03/04/15.
//  Copyright (c) 2015 Daniel Berger. All rights reserved.
//

import Foundation
import UIKit

class UserInterface
{
    class func getStartLabel() -> UILabel {
        var startLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
        startLabel.center = CGPointMake(160, 220)
        startLabel.textAlignment = NSTextAlignment.Center
        startLabel.font = UIFont (name: "Helvetica Neue", size: 25)
        startLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        startLabel.text = "Tap to start"
        return startLabel
    }
    class func getStopLabel() -> UILabel {
        var stopLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
        stopLabel.center = CGPointMake(160, 250)
        stopLabel.textAlignment = NSTextAlignment.Center
        stopLabel.font = UIFont (name: "Helvetica Neue", size: 18)
        stopLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        stopLabel.text = "(Double-tap to stop)"
        return stopLabel
    }
    class func getBuyButton() -> UIButton {
        let buyButton = UIButton(frame: CGRectMake(57, 280, 210, 40))
        buyButton.setTitle("Buy \"Rastalights\"", forState: UIControlState.Normal);
        buyButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        return buyButton
    }
    class func getRestoreButton() -> UIButton {
        let restoreButton = UIButton(frame: CGRectMake(82, 470, 160, 30))
        restoreButton.setTitle("Restore Purchase", forState: UIControlState.Normal);
        restoreButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        return restoreButton
    }
    class func getHideView() -> UIView {
        let hideView = UIView(frame: CGRect(x: 10, y: 10, width: 300, height: 510))
        hideView.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        return hideView
    }
}