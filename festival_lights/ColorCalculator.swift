//
//  ColorCalculator.swift
//  festival_lights
//
//  Created by Daniel Berger on 18/03/15.
//  Copyright (c) 2015 Daniel Berger. All rights reserved.
//

import Foundation
import UIKit

class ColorCalculator
{
    var minr, ming, minb : Int
    var maxr, maxg, maxb : Int
    
    private var deltar, deltag, deltab : Int
    
    init(){
        minr = 0; ming = 0; minb = 0
        maxr = 255; maxg = 255; maxb = 255
        deltar = maxr-minr; deltag = maxg-ming; deltab = maxb-minb
    }
    init(MinRed minr : Int,MinGreen ming : Int,MinBlue minb : Int,MaxRed maxr : Int,MaxGreen maxg : Int,MaxBlue maxb : Int){
        self.minr = minr; self.ming = ming; self.minb = minb
        self.maxr = maxr; self.maxg = maxg; self.maxb = maxb
        deltar = maxr-minr; deltag = maxg-ming; deltab = maxb-minb
    }
    //Percentage is a value between 0 and 1
    func getUIColor(Percentage p : CGFloat) -> UIColor{
        var currentr = CGFloat(minr) + CGFloat(deltar) * p
        var currentg = CGFloat(ming) + CGFloat(deltag) * p
        var currentb = CGFloat(minb) + CGFloat(deltab) * p
        
        return UIColor(red: percent(ColorValue: currentr), green: percent(ColorValue: currentg), blue: percent(ColorValue: currentb), alpha: 1)
    }
    //Returns percentage value between 0 and 1
    private func percent(ColorValue c : CGFloat) -> CGFloat{
        return c / 255
    }
}
