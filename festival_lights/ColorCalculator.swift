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
    //Color Properties
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

class SecretAlgorithm{
    //Calculation Properties
    let arrayLength : Int
    var arrayPointer : Int
    var apcValues : Array<Double>
    var peakValues : Array<Double>
    var intervalMinimum : Double
    
    init(){
        arrayLength = 50
        arrayPointer = 0
        apcValues = Array(count: 50, repeatedValue:Double())
        peakValues = Array(count: 50, repeatedValue:Double())
        intervalMinimum = 30
    }
    
    //This is where the magic happens
    func doTheSecretAlgorithm(AudioRecorder audioRecorder:AudioRecorder) -> CGFloat{
        let dFormat = "%02d"
        let min:Int = Int(audioRecorder.recorder.currentTime / 60)
        let sec:Int = Int(audioRecorder.recorder.currentTime % 60)
        let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
        audioRecorder.recorder.updateMeters()
        var apc0 = audioRecorder.recorder.averagePowerForChannel(0)
        var peak0 = audioRecorder.recorder.peakPowerForChannel(0)
        
        if(arrayPointer == arrayLength){
            arrayPointer = 0
        }
        
        peakValues[arrayPointer]=Double(peak0)
        apcValues[arrayPointer]=Double(apc0)
        
        var peakSum = 0.0
        for peak in peakValues {
            peakSum += peak;
        }
        var peakAverage = peakSum/(Double(peakValues.endIndex) - Double(peakValues.startIndex))
        
        var apcSum = 0.0
        for apc in apcValues {
            apcSum += apc
        }
        var apcAverage = apcSum/(Double(apcValues.endIndex) - Double(apcValues.startIndex))
        var currentVolume = Double(apc0)
        
        var minVolume : Double = 0
        
        for i in 0...apcValues.count-1 {
            if (apcValues[i] < minVolume){minVolume = apcValues[i]}
        }
        
        var minLimit : Double = apcAverage - abs(apcAverage - peakAverage);
        var maxLimit : Double = apcAverage + abs(apcAverage - peakAverage);
        
        // Intervall should never be under intervalMinimum
        
        if(maxLimit - minLimit < intervalMinimum) {
            var tmpFactor : Double = intervalMinimum/(maxLimit - minLimit)
            maxLimit = maxLimit*tmpFactor
            minLimit = minLimit*tmpFactor
            currentVolume = currentVolume*tmpFactor
        }
        
        if currentVolume < minLimit {
            currentVolume = minLimit
        } else if currentVolume > maxLimit {
            currentVolume = maxLimit
        }
        
        var r = CGFloat(abs(maxLimit-currentVolume)/abs(maxLimit-minLimit))
        
        arrayPointer++
        
        //Loudness Percentage
        var p = abs(1-r)
        
        return p
    }

}
