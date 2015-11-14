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
            //NSLog("x: " + String(a[0]))
        }
        //NSLog("Got something on phone: " + (message["something"] as! String))
        //replyHandler(["reply": "123456789"])
    }
}

