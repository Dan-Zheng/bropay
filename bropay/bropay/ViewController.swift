//
//  ViewController.swift
//  bropay
//
//  Created by Adam Loeb on 11/14/15.
//  Copyright © 2015 Bro. All rights reserved.
//

import UIKit
import WatchConnectivity
import MessageUI

class ViewController: UIViewController, WCSessionDelegate {
    
    var session: WCSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up communication with watch.
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
        }
        
        Venmo.sharedInstance().defaultTransactionMethod = VENTransactionMethod.API
        if (!Venmo.sharedInstance().isSessionValid()) {
            Venmo.sharedInstance().requestPermissions(["make_payments", "access_profile"], withCompletionHandler: { (Bool success, NSError error) -> Void in
                if (success) {
                    NSLog("got permission")
                }
                else {
                    NSLog("Didn't get permission")
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // For when we get a message from the phone
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        NSLog("Got something on phone!")
        let data = (message["data"] as! NSArray) as Array
        NSLog("Size: " + String(data.count));
        var dat = ""
        for a in data {
            dat = dat + String(a[0]) + "," + String(a[1]) + "," + String(a[2]) + "\n";
            NSLog("x: " + String(a[0]))
        }
        let file = "bropay_data.txt" // This is the file for writing
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            NSLog(path)
            
            // Write to file
            do {
                try dat.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
            
            // Read from file
            /*
            do {
                let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}*/
        }
        //NSLog("Got something on phone: " + (message["something"] as! String))
        //replyHandler(["reply": "123456789"])
    }
    
    func sendPayment() {
        let recipient: String = "Jamindude22@mac.com"
        let amt: UInt = 1
        let message: String = "yo"
        Venmo.sharedInstance().sendRequestTo(recipient, amount: amt, note: message, audience: VENTransactionAudience.Private, completionHandler: { (VENTransaction transaction, Bool success, NSError error) -> Void in
            
            if (success) {
                NSLog("sent request for " + String(amt) + " to " + recipient)
            }
            else {
                NSLog(error.localizedDescription)
            }
        })
    }
}

