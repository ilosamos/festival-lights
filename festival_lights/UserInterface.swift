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
    class func getStartLabel() -> UILabel{
        var startLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
        startLabel.center = CGPointMake(160, 250)
        startLabel.textAlignment = NSTextAlignment.Center
        startLabel.font = UIFont (name: "Helvetica Neue", size: 25)
        startLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        startLabel.text = "Tap to start"
        return startLabel
    }
    class func getStopLabel() -> UILabel{
        var stopLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
        stopLabel.center = CGPointMake(160, 280)
        stopLabel.textAlignment = NSTextAlignment.Center
        stopLabel.font = UIFont (name: "Helvetica Neue", size: 18)
        stopLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        stopLabel.text = "(Double-tap to stop)"
        return stopLabel
    }
}