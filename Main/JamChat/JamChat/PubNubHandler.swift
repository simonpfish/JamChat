//
//  PubNubHandler.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/25/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import PubNub

class PubNubHandler: NSObject {
    
    static var client : PubNub {
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        return appDelegate.client
    }
    
    static func notifyNewMessage(jam: Jam) {
        let payload = ["aps" : ["alert" : "\(User.currentUser!.name!) -> \(jam.title)"]]
        client.publish("new_message", toChannel: jam.id, mobilePushPayload: payload) { (status: PNPublishStatus) in
            print(status.debugDescription)
        }
    }
    
    static func notifyNewJam(jam: Jam) {
        let payload = ["aps" : ["alert" : "\(User.currentUser!.name!) created jam \(jam.title)!"]]
        client.publish("new_message", toChannel: jam.id, mobilePushPayload: payload) { (status: PNPublishStatus) in
            print(status.debugDescription)
        }
    }
    
}
