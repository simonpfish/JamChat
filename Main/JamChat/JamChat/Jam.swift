//
//  Jam.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse
import AudioKit
import PubNub

class Jam: NSObject {
    
    var messages: [Message] = []
    var users: [User] = []
    private(set) var updatedAt: NSDate!
    let messageDuration: Double!
    var title: String = ""
    static var currentUserJams: [Jam] = []
    static var usersInCurreentUserJams: [User] = []
    var tempo: Int?
    var id: String {
        get {
            return object.objectId!
        }
    }
    
    private var messageIDs: [String] = []
    private var userIDs: [String] = []
    private var object: PFObject!
    
    
    /**
     Loads jam from an exisiting PFObject.
     */
    init(object: PFObject) {
        
        self.object = object
        
        messageDuration = object["messageDuration"] as! Double
        messageIDs = object["messages"] as! [String]
        userIDs = object["users"] as! [String]
        title = object["title"] as? String ?? ""
        tempo = object["tempo"] as? Int
        updatedAt = object.updatedAt
        
        super.init()
    }
    
    func loadData(completion: () -> ()) {
        loadUsers {
            self.loadMessages({
                completion()
            })
        }
    }
    
    /**
     Creates a new jam with a given message duration and name
     */
    init(messageDuration: Double, users: [User], title: String) {
        object = PFObject(className: "Jam")
        self.messageDuration = messageDuration
        self.title = title
        self.updatedAt = NSDate()
        
        super.init()
        
        for user in users {
            add(user)
        }
        add(User.currentUser!)
    }
    
    private func loadUsers(completion: () -> ()) {
        print("Loading jam \(self.object.objectId ?? "NEW") users")
        let query = PFQuery(className: "_User")
        query.whereKey("facebookID", containedIn: userIDs)
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.users = []
                for object in objects! {
                    self.users.append(User(user: object as! PFUser))
                }
                
                var loadedCount = 0
                for user in self.users {
                    user.loadData({
                        loadedCount += 1
                        if loadedCount == self.users.count {
                            print("Successfully loaded jam \(self.object.objectId ?? "NEW") users")
                            completion()
                        }
                    })
                }
            }
        })
    }
    
    private func loadMessages(completion: () -> ()) {
        print("Loading jam \(self.object.objectId!) messages")
        let query = PFQuery(className: "Message")
        query.orderByAscending("createdAt")
        query.whereKey("objectId", containedIn: messageIDs)
        query.includeKey("author")
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects?.count == 0 {
                    completion()
                } else {
                    for object in objects! {
                        self.messages.append(Message(object: object))
                    }
                    print("Successfully loaded jam \(self.object.objectId ?? "NEW") messages")
                    completion()
                }
            }
        }
    }
    
    init(messageDuration: Double, userIDs: [String], title: String, tempo: Int) {
        object = PFObject(className: "Jam")
        self.messageDuration = messageDuration
        self.userIDs = userIDs
        self.userIDs.append(User.currentUser!.facebookID)
        self.title = title
        self.tempo = tempo
    }
    
    /**
     Records a track from a certain audio node for the set track duration, adds it to a message and sends it immediately.
     */
    func recordSend(instrument: Instrument, success: () -> (), failure: (NSError) -> ()) {
        let message: Message
        if messages.count > 0 {
            message = Message(previousMessage: messages[messages.count-1])
        } else {
            message = Message(previousMessage: nil)
        }
        
        let track = Track()
        track.recordInstrument(instrument, duration: messageDuration) {
            message.add(track)
            message.send({ (_: Bool, error: NSError?) in
                if let error = error {
                    failure(error)
                } else {
                    self.add(message)
                    self.push({ (_: Bool, error: NSError?) in
                        if let error = error {
                            failure(error)
                        } else {
                            self.sendNotification()
                            success()
                        }
                    })
                }
            })
        }
    }
    
    // Utilities to make sure arrays are updated accordingly:
    
    private func add(message: Message) {
        if let id = message.id {
            messages.append(message)
            messageIDs.append(id)
        }
    }
    
    private func add(user: User) {
        if let id = user.parseUser.objectId {
            users.append(user)
            userIDs.append(id)
        }
    }
    
    /**
     Updates the jam from the server if it is necessary
     */
    func fetch(success: () -> (), failure: (NSError) -> ()) {
        print("Fetching jam \(self.object.objectId ?? "NEW") users")
        
        object.fetchIfNeededInBackgroundWithBlock() { (object: PFObject?, error: NSError?) in
            if let object = object {
                
                let serverMessageIDs = Set(object["messages"] as! [String])
                
                let newMessageIDs = serverMessageIDs.subtract(self.messageIDs)
                
                let query = PFQuery(className: "Message")
                query.whereKey("objectId", containedIn: Array(newMessageIDs))
                
                query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
                    if let error = error {
                        failure(error)
                    } else {
                        for object in objects! {
                            self.messages.append(Message(object: object))
                        }
                        success()
                    }
                }
                
                
            } else {
                failure(error!)
            }
        }
    }
    
    /**
     Push the updates to the jam back to the server
     */
    func push(completion: PFBooleanResultBlock?) {
        print("Pushing jam \(self.object.objectId ?? "NEW")")
        
        object["messageDuration"] = messageDuration
        object["users"] = userIDs
        object["messages"] = messageIDs
        object["title"] = title
        object["tempo"] = tempo
        
        object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            print("Finished pushing jam \(self.object.objectId ?? "NEW")")
            completion?(success, error)
        })
    }
    
    func sendNotification() {
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.client.publish("New+Message", toChannel: object.objectId!) { (status: PNPublishStatus) in
            print(status.debugDescription)
        }
    }
    
    class func downloadCurrentUserJams(success: ([Jam]) -> (), failure: (NSError) -> ()) {
        print("Downloading jams for active user")
        
        let query = PFQuery(className: "Jam")
        
        query.whereKey("users", containsString: User.currentUser!.facebookID)
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if let error = error {
                failure(error)
            } else {
                var jams: [Jam] = []
                var loadedCount = 0
                for object in objects ?? [] {
                    jams.append(Jam(object: object))
                    //currentUserJams = jams
                    jams.last?.loadData({
                        loadedCount += 1
                        if loadedCount == objects!.count {
                            print("Succesfully downloaded jams for active user")
                            currentUserJams = jams
                            success(jams)
                        }
                    })
                }
            }
        }
    }
}
