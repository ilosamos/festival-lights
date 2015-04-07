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
import StoreKit

class ViewController: UIViewController , UIPageViewControllerDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    //Page View Controller for Navigation
    var pageViewController : UIPageViewController?
    var views : Int = 4
    var currentIndex : Int = 0
    
    //Mixpanel for info tracking
    var mixpanel : Mixpanel = Mixpanel(token: "c4862b902fa8c5c28b3240a505012ecd", andFlushInterval: 1)
    
    //Only true when app starts
    var isStart : Bool = true
    
    //Secret Algorithm Object
    var secretAlgorithm : SecretAlgorithm = SecretAlgorithm()
    
    //TickTimers
    var tickTimer : NSTimer = NSTimer()
    
    //Audio Recorder Object
    var audioRecorder : AudioRecorder = AudioRecorder()
    
    //Store UUID
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //In App Purchase Product IDs
    let RastaLightID = "festival_lights_rastalight"
    var isRestoring : Bool = false
    
    //Interface Elements
    var startLabel : UILabel = UserInterface.getStartLabel()
    var stopLabel : UILabel = UserInterface.getStopLabel()
    var buyButton : UIButton = UserInterface.getBuyButton()
    var restoreButton : UIButton = UserInterface.getRestoreButton()
    var hideView : UIView = UserInterface.getHideView()
    var activityView : UIActivityIndicatorView = UserInterface.getActivityIndicator()
    
    //Colors
    var color1 : ColorCalculator = ColorCalculator(MinRed: 0, MinGreen: 0, MinBlue: 0, MaxRed: 255, MaxGreen: 255, MaxBlue: 255)
    var color2 : ColorCalculator = ColorCalculator(MinRed: 137, MinGreen: 27, MinBlue: 27, MaxRed: 252, MaxGreen: 255, MaxBlue: 13)
    var color3 : ColorCalculator = ColorCalculator(MinRed: 93, MinGreen: 200, MinBlue: 223, MaxRed: 255, MaxGreen: 0, MaxBlue: 234)
    //color4 = Purchased Rastacolor
    var color4 : ColorCalculator = TriColorCalculator(MinRed: 30, MinGreen: 150, MinBlue: 0, MidRed: 255, MidGreen: 242, MidBlue: 0, MaxRed: 245, MaxGreen: 19, MaxBlue: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "record:")
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        var doubletapGesture = UITapGestureRecognizer(target: self, action: "stopRecording:")
        doubletapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubletapGesture)

        //Configure PageViewController for navigation
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController: LightView = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        pageViewController?.navigationController?.automaticallyAdjustsScrollViewInsets = false
        pageViewController?.navigationController?.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        if defaults.stringForKey("UUID") == nil {
            defaults.setObject(NSUUID().UUIDString, forKey: "UUID")
        }
    
        //Add Labels to show on start
        self.view.addSubview(startLabel)
        self.view.addSubview(stopLabel)
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse){
        println("got the request from Apple")
        activityView.stopAnimating()
        self.view.addSubview(activityView)
        var count : Int = response.products.count
        if (count>0) {
            var validProducts = response.products
            var validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.RastaLightID) {
                println(validProduct.localizedTitle)
                println(validProduct.localizedDescription)
                println(validProduct.price)
                if !isRestoring {
                    buyProduct(validProduct)
                }
                else {
                    restoreProduct()
                }
            } else {
                println(validProduct.productIdentifier)
            }
        } else {
            println("nothing")
        }
    }
    
    func buyProduct(product: SKProduct){
        println("Sending the Payment Request to Apple");
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
    }
    
    func restoreProduct(){
        println("Sending the restore Payment Request to Apple");
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions();
    }
    
    func buyNonConsumable(){
        println("About to fetch the products");
        activityView.startAnimating()
        self.view.addSubview(activityView)
        buyButton.enabled = false
        println("buyButton disabled")
        // We check that we are allow to make the purchase.
        if (SKPaymentQueue.canMakePayments())
        {
            var productID:NSSet = NSSet(object: self.RastaLightID);
            var productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID);
            productsRequest.delegate = self;
            productsRequest.start();
            println("Fething Products");
        }else{
            println("can not make purchases");
        }
    }
    func restoreNonConsumable(){
        restoreButton.enabled = false
        println("restoreButton disabled")
        isRestoring = true
        buyNonConsumable()
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
        println("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased, .Restored:
                    println("Product Purchased");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    //mixpanel.track("Purchase successful (Rastalights)")
                    let error = Locksmith.saveData(["purchase": "rastalights"], forUserAccount: defaults.stringForKey("UUID")!)
                    let (dictionary, err) = Locksmith.loadDataForUserAccount(defaults.stringForKey("UUID")!)
                    var uuid = defaults.stringForKey("UUID")
                    println("Did save purchase for UUID: \(uuid) product: \(dictionary)")
                    hideView.removeFromSuperview()
                    buyButton.removeFromSuperview()
                    restoreButton.removeFromSuperview()
                    if trans.transactionState == .Restored{
                        var alert = UIAlertController(title: "Success", message: "Your product has been restored", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    }
                    break;
                case .Failed:
                    println("Purchased Failed");
                    var alert = UIAlertController(title: "Failed", message: "Product has not been purchased", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                    //mixpanel.track("Purchase error (Rastalights)")
                    break;
                default:
                    break;
                }
                buyButton.enabled = true
                restoreButton.enabled = true
                isRestoring = false
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as LightView).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as LightView).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == views) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> LightView?
    {
        if views == 0 || index >= views
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = LightView()
        
        println("INDEX: \(index)")
        
        pageContentViewController.pageIndex = index
        switch(index){
        case 0:
            pageContentViewController.view.backgroundColor = color1.getUIColor(Percentage: 0)
        case 1:
            pageContentViewController.view.backgroundColor = color2.getUIColor(Percentage: 0)
        case 2:
            pageContentViewController.view.backgroundColor = color3.getUIColor(Percentage: 0)
        case 3:
            pageContentViewController.view.backgroundColor = color4.getUIColor(Percentage: 0)
            let uuid = defaults.stringForKey("UUID")
            let (dictionary, error) = Locksmith.loadDataForUserAccount(uuid!)
            if dictionary == nil {
                buyButton.addTarget(self, action: "buyNonConsumable", forControlEvents: UIControlEvents.TouchUpInside)
                restoreButton.addTarget(self, action: "restoreNonConsumable", forControlEvents: UIControlEvents.TouchUpInside)
                pageContentViewController.view.addSubview(hideView)
                pageContentViewController.view.addSubview(buyButton)
                pageContentViewController.view.addSubview(restoreButton)
            }
            else if dictionary?.valueForKey("purchase") as String != "rastalights" {
                buyButton.addTarget(self, action: "buyNonConsumable", forControlEvents: UIControlEvents.TouchUpInside)
                pageContentViewController.view.addSubview(hideView)
                pageContentViewController.view.addSubview(buyButton)
                pageContentViewController.view.addSubview(restoreButton)
            }
        default:
            break
        }
        currentIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return views
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }

    //Start recording after tap
    @IBAction func record(sender: UIGestureRecognizer) {
        
        if audioRecorder.recorder == nil {
            println("recording. recorder nil")
            isStart = false
            startLabel.hidden = true
            stopLabel.hidden = true
            println("LightView: \(pageViewController?.viewControllers[0].count)")
            recordWithPermission(true)
            return
        }
    }
    
    @IBAction func stopRecording(sender: UIGestureRecognizer)
    {
        if audioRecorder.recorder != nil && audioRecorder.recorder.recording {
            println("stopping")
            audioRecorder.recorder.stop()
            audioRecorder.stop()
            audioRecorder.deleteAllRecordings()
            startLabel.hidden = false
            stopLabel.hidden = false
            
        }
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("Permission to record granted")
                    self.audioRecorder.setSessionPlayAndRecord()
                    if setup {
                        self.audioRecorder.setupRecorder()
                    }
                    self.audioRecorder.recorder.record()
                    self.audioRecorder.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.01,
                        target: self,
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
    
    func updateAudioMeter(timer:NSTimer) {
        
        var p : CGFloat = secretAlgorithm.doTheSecretAlgorithm(AudioRecorder: audioRecorder)
        
        switch((pageViewController?.viewControllers[0] as LightView).pageIndex){
        case 0:
            (pageViewController?.viewControllers[0] as LightView).changeColor(color1.getUIColor(Percentage: p))
        case 1:
            (pageViewController?.viewControllers[0] as LightView).changeColor(color2.getUIColor(Percentage: p))
        case 2:
            (pageViewController?.viewControllers[0] as LightView).changeColor(color3.getUIColor(Percentage: p))
        case 3:
            (pageViewController?.viewControllers[0] as LightView).changeColor(color4.getUIColor(Percentage: p))

        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


