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
        client.publish("new_message", toChannel: jam.id, mobilePushPayload: ["aps" : ["alert" : "\(User.currentUser!.name!) jammed on \(jam.title)"]]) { (status: PNPublishStatus) in
            print(status.debugDescription)
        }
    }
    
}
