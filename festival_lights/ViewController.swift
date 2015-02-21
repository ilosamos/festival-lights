//
//  ViewController.swift
//  festival_lights
//
//  Created by Daniel Berger on 17/02/15.
//  Copyright (c) 2015 Daniel Berger. All rights reserved.
//

import UIKit
import AVFoundation
import Darwin

class ViewController: UIViewController {
    
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var peakLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    
    //TickTimers
    var syncTimer : NSTimer = NSTimer()
    var tickTimer : NSTimer = NSTimer()
    
    //Audio Recording Properties
    var recorder: AVAudioRecorder!
    var meterTimer:NSTimer!
    var soundFileURL:NSURL?
    
    var arrayLength = 100
    var arrayPointer = 0
    var apcValues = Array(count: 100, repeatedValue:Double())
    var peakValues = Array(count:100, repeatedValue:Double())
    var scale = 0.8
    var decrementAverageSkalar = 0.10

    override func viewDidLoad() {
        super.viewDidLoad()
        stateButton.setTitle("RECORD", forState: UIControlState.Normal)
        // Do any additional setup after loading the view, typically from a nib.
        
        /*BlinkSystem
        let syncSelector : Selector = "syncTime"
        
        var t = NSDate().timeIntervalSince1970;
        var waitTime = 1 - (t - floor(t))
        println(waitTime)
        
        syncTimer = NSTimer.scheduledTimerWithTimeInterval(waitTime, target: self, selector: syncSelector, userInfo: nil, repeats: false)*/
        
        /*AudioRecordingSystem*/
        
    }
    
    
    @IBAction func stateButtonPressed(sender: AnyObject) {
    }
    
    func updateAudioMeter(timer:NSTimer) {
        
        if recorder.recording {
            let dFormat = "%02d"
            let min:Int = Int(recorder.currentTime / 60)
            let sec:Int = Int(recorder.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            recorder.updateMeters()
            var apc0 = recorder.averagePowerForChannel(0)
            var peak0 = recorder.peakPowerForChannel(0)
            
            if(arrayPointer == arrayLength){
                arrayPointer = 0
            }
            println("\(arrayPointer)")
            println("peakValues: \(peakValues)")
            println("apcValues: \(apcValues)")
            //println("apc: \(apc0)")

            peakValues[arrayPointer]=Double(peak0)
            apcValues[arrayPointer]=Double(apc0)

            
            //println("peakValues: \(peakValues)")
            //println("peakValues: \(apcValues)")
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
            
            //apcAverage + peakAverage - größte Wert
            //apcAverage - peakAverage - kleinste Wert
            
            var currentVolume = Double(apc0)
            
            println("currentVolume: \(currentVolume)")
            println("apcAverage: \(apcAverage)")
            println("peakAverage: \(peakAverage)")

            
            if currentVolume <  (peakAverage - abs(apcAverage - peakAverage)*scale) {
                currentVolume = (peakAverage - abs(apcAverage - peakAverage)*scale)
            } else if currentVolume > (peakAverage + abs(apcAverage - peakAverage)*scale) {
                currentVolume = (peakAverage + abs(apcAverage - peakAverage)*scale)
            }
            
            println("Untere Grenze: \(peakAverage - abs(apcAverage - peakAverage))")
            println("Obere Grenze: \(peakAverage + abs(apcAverage - peakAverage))")
            
            var r = CGFloat((abs((peakAverage + abs(apcAverage - peakAverage)*scale) - currentVolume))/(abs((peakAverage + abs(apcAverage - peakAverage)*scale) - (peakAverage - abs(apcAverage - peakAverage)*scale))))
            arrayPointer++
            println("Color r: \(r)")
            volLabel!.text = "Volume: \(apc0)"
            peakLabel!.text = "Peak: \(peak0)"
            
            //var r = CGFloat(pow(10,peak0/10))
            var b = abs(1-r)
            
            //silent:blue - loud:green
            //self.view.backgroundColor = UIColor(red: 0, green: r, blue: abs(1-r), alpha: 1)
            //silent:pink - loud:yellow
            //self.view.backgroundColor = UIColor(red: 1, green: r, blue: abs(1-r), alpha: 1)
            //silent:blue - loud:red
            self.view.backgroundColor = UIColor(red: abs(1-r), green: 0, blue: r, alpha: 1)
            //silent:green - loud:yellow
            //self.view.backgroundColor = UIColor(red: r, green: 1, blue: abs(1-r), alpha: 1)
            //silent:green - loud:red
            //self.view.backgroundColor = UIColor(red: r, green: abs(1-r), blue: 0, alpha: 1)
            //silent:helbblau - loud:magenta
            //self.view.backgroundColor = UIColor(red: r, green: abs(1-r), blue: 1, alpha: 1)
            
            for i in (0...peakValues.count-1) {
                peakValues[i]=peakValues[i] - decrementAverageSkalar
                apcValues[i]=apcValues[i] - decrementAverageSkalar
            }
        }
    }

    @IBAction func record(sender: UIButton) {
        
        if recorder == nil {
            println("recording. recorder nil")
            stateButton.setTitle("Stop", forState:.Normal)
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.recording {
            println("stopping")
            recorder.stop()
            stop()
            deleteAllRecordings()
            stateButton.setTitle("Start", forState:.Normal)
            
        } else {
            println("recording")
            stateButton.setTitle("Pause", forState:.Normal)
            recordWithPermission(false)
        }
    }

    func stop() {
        println("stop")
        recorder.stop()
        meterTimer.invalidate()
        
        stateButton.setTitle("Record", forState:.Normal)
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setActive(false, error: &error) {
            println("could not make session inactive")
            if let e = error {
                println(e.localizedDescription)
                return
            }
        }
        stateButton.enabled = true
        recorder = nil
    }

    func setupRecorder() {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.001,
                        target:self,
                        selector:"updateAudioMeter:",
                        userInfo:nil,
                        repeats:true)
                } else {
                    println("Permission to record not granted")
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }

    
    func syncTime()
    {
        let tickSelector : Selector = "tick"
        
        tickTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: tickSelector, userInfo: nil, repeats: true)
        
    }
    
    func tick()
    {
        var t = NSDate().timeIntervalSince1970
        println(floor(t)%2)
        
        switch floor(t)%2
        {
            case 1.0:
                self.view.backgroundColor = UIColor.whiteColor()
            case 0.0:
                self.view.backgroundColor = UIColor.blackColor()
            default: break
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func deleteAllRecordings() {
        var docsDir =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var fileManager = NSFileManager.defaultManager()
        var error: NSError?
        var files = fileManager.contentsOfDirectoryAtPath(docsDir, error: &error) as [String]
        if let e = error {
            println(e.localizedDescription)
        }
        var recordings = files.filter( { (name: String) -> Bool in
            return name.hasSuffix("m4a")
        })
        for var i = 0; i < recordings.count; i++ {
            var path = docsDir + "/" + recordings[i]
            
            println("removing \(path)")
            if !fileManager.removeItemAtPath(path, error: &error) {
                NSLog("could not remove \(path)")
            }
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }

}
// MARK: AVAudioRecorderDelegate
extension ViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            /*println("finished recording \(flag)")
            recordButton.setTitle("Record", forState:.Normal)
            
            // iOS8 and later
            var alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
                println("keep was tapped")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
                println("delete was tapped")
                self.recorder.deleteRecording()
            }))
            self.presentViewController(alert, animated:true, completion:nil)*/
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
}

// MARK: AVAudioPlayerDelegate
extension ViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished playing \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
}


