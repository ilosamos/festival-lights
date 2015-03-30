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

class TriColorCalculator : ColorCalculator
{
    //Mid Colors for 3rd color
    var midr, midg, midb : Int
    
    //Override standard init
    override init(){
        midr = 127; midg = 127; midb = 127
        super.init()
    }
    //Override init with 3 colors
    init(MinRed minr : Int,MinGreen ming : Int,MinBlue minb : Int, MidRed midr : Int,MidGreen midg : Int, MidBlue midb : Int, MaxRed maxr : Int,MaxGreen maxg : Int,MaxBlue maxb : Int){
        
        self.midr = midr; self.midg = midg; self.midb = midb
        super.init(MinRed: minr, MinGreen: ming, MinBlue: minb, MaxRed: maxr, MaxGreen: maxg, MaxBlue: maxb)
    }
    override func getUIColor(Percentage p: CGFloat) -> UIColor {
        var p2 : CGFloat = 0
        var currentr : CGFloat = 0
        var currentg : CGFloat = 0
        var currentb : CGFloat = 0
        
        
        if p <= 0.5 {
            p2 = p * 2
            deltar = midr-minr; deltag = midg-ming; deltab = midb-minb
            currentr = CGFloat(minr) + CGFloat(deltar) * p2
            currentg = CGFloat(ming) + CGFloat(deltag) * p2
            currentb = CGFloat(minb) + CGFloat(deltab) * p2
        }
        else {
            p2 = (p - 0.5) * 2
            deltar = maxr-midr; deltag = maxg-midg; deltab = maxb-midb
            currentr = CGFloat(midr) + CGFloat(deltar) * p2
            currentg = CGFloat(midg) + CGFloat(deltag) * p2
            currentb = CGFloat(midb) + CGFloat(deltab) * p2
        }

        return UIColor(red: percent(ColorValue: currentr), green: percent(ColorValue: currentg), blue: percent(ColorValue: currentb), alpha: 1)
    }
}
