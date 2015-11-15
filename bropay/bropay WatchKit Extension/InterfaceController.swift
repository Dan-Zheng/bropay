//
//  InterfaceController.swift
//  bropay WatchKit Extension
//
//  Created by Adam Loeb on 11/14/15.
//  Copyright © 2015 Bro. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

extension CMSensorDataList: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    // Session to communicate with phone
    var session : WCSession!
    
    // Cache to hold accelerometer data before sending to phone
    var data = Array<Array<Double>>()
    var recordData = Array<Array<Double>>()
    
    // Manager to get accelerometer data, used while app is open.
    let motionManager = CMMotionManager()
    
    // Recorder for accelerometer data, used while app is not open.
    let sensorRecorder = CMSensorRecorder()
    
    var lastStart = NSDate()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        /*NSLog("Should start recording");
        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            lastStart = NSDate()
            
            sensorRecorder.recordAccelerometerForDuration(20 * 60)  // Record for 20 minutes
            NSLog("started recording");
        }*/
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Setup session so we can send stuff to the phone
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        /*NSLog("Will Activate called");
        
        NSLog("lastStart: " + String(lastStart) + " now: " + String(NSDate()));
        if let accelData = sensorRecorder.accelerometerDataFromDate(lastStart, toDate: NSDate()) {
        //if (accelData != nil) {
            NSLog("Found sensorrecorder data");
            for element in accelData {
                let lastElement = element as! CMRecordedAccelerometerData
                self.recordData.append([lastElement.acceleration.x, lastElement.acceleration.y, lastElement.acceleration.z])
            }
            
            // Log to make sure we are doing stuff
            if (self.recordData.count % 50 == 0) { NSLog(String(self.recordData.count)) }
            
            // Send stuff to phone once we have a bunch of data
            if (self.recordData.count > 400) {
                self.sendToPhone("data", message: self.recordData)
                self.recordData = []
                lastStart = NSDate()
            }
            
            /*
            for (index, data) in sensorData.enumerate() {
                print(index, data)
            }
            */
        } else {
            NSLog("accelData is nil");
        }*/
        
        // Start accelerometer for collecting data while app is open using motionManager.
        if (motionManager.accelerometerAvailable) {
            // Set the interval to get data
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { accelerometerData, error in
                // Store data from the accelerometer
                self.data.append([accelerometerData!.acceleration.x, accelerometerData!.acceleration.y, accelerometerData!.acceleration.z])
                
                // Log to make sure we are doing stuff
                if (self.data.count % 50 == 0) { NSLog(String(self.data.count)) }
                
                // Send stuff to phone once we have a bunch of data
                if (self.data.count > 400) {
                    self.sendToPhone("data", message: self.data)
                    self.data = []
                }
            }
        }
    }

    override func didDeactivate() {
        // Turn off acelerometer when we go into background
        if (motionManager.accelerometerAvailable) {
            motionManager.stopAccelerometerUpdates()
            NSLog("stopped accelerometer")
        }
        NSLog("Deactivated");
        
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func sendToPhone(key: String, message: AnyObject) {
        NSLog("Sending to phone")
        // Grab our phone session we activated earlier
        if let ses = session {
            // If we can reach the phone
            if (WCSession.defaultSession().reachable) {
                // Make a key value pair with our cached data.
                let applicationData = [key:message]
                // Send it to the phone
                ses.sendMessage(applicationData, replyHandler: {(replyMessage: [String : AnyObject]) -> Void in
                        // Grab a from the phone right here.
                        NSLog("Got reply" + (replyMessage["reply"] as! String))
                    }, errorHandler: {(error ) -> Void in
                        // In case we get an error from the phone
                        NSLog("Error :( " + error.localizedDescription)
                })
            } else {
                NSLog("Well, we couldn't reach the iPhone");
            }
            NSLog("Sent to phone")
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        NSLog("Got something on watch: " + (message["something"] as! String))
    }

}
