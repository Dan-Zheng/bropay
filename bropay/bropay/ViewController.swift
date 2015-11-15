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

class ViewController: UIViewController, WCSessionDelegate, MFMailComposeViewControllerDelegate {
    
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
        /*
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
        */
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
            var fileSize : UInt64 = 0
            do {
                let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
                if let _attr = attr {
                    fileSize = _attr.fileSize();
                }
                
                /*if let outputStream = NSOutputStream(toFileAtPath: path, append: true) {
                    outputStream.open()
                    outputStream.write(dat)
                    outputStream.close()
                } else {
                    NSLog("Unable to open file")
                }*/
                
                try dat.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                replyHandler(["reply" : String(fileSize)])
                if fileSize > 30000 {
                    sendEmail(path)
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                }
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
    
    func sendEmail(path: String) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Bropay Data")
            mailComposer.setMessageBody("Test message.", isHTML: false)
            
            if let fileData = NSData(contentsOfFile: path) {
                mailComposer.addAttachmentData(fileData, mimeType: "text/plain", fileName: "bropay_data.txt")
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
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

