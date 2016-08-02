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
    
    static func notifyNewMessage(jam: Jam, trackID: String) {
        for userID in jam.userIDs {
            let payload = ["aps" : ["alert" : "\(User.currentUser!.name!) -> \(jam.title)", "trackID": trackID, "userID": User.currentUser!.facebookID, "jamID": jam.id]]
            client.publish("new_message", toChannel: userID, mobilePushPayload: payload) { (status: PNPublishStatus) in
//                print(status.debugDescription)
            }
        }
    }
    
    static func notifyNewJam(jam: Jam) {
        for userID in jam.userIDs {
            let payload = ["aps" : ["alert" : "\(User.currentUser!.name!) created jam \(jam.title)!", "userID": User.currentUser!.facebookID]]
            client.publish("new_message", toChannel: userID, mobilePushPayload: payload) { (status: PNPublishStatus) in
//                print(status.debugDescription)
            }
        }
    }
    
    static func subscribeToUserNotifications(user: User) {
        client.subscribeToChannels([user.facebookID], withPresence: true)
        let userToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as! NSData
        client.addPushNotificationsOnChannels([user.facebookID], withDevicePushToken: userToken) { (status: PNAcknowledgmentStatus) in
            print(status.debugDescription)
        }
    }
    
    static func removePushNotifications() {
        let userToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as! NSData
        client.removeAllPushNotificationsFromDeviceWithPushToken(userToken) { (status: PNAcknowledgmentStatus) in
            print(status.debugDescription)
        }
    }
    
}
