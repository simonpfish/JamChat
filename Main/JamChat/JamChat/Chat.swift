//
//  Chat.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse
import AudioKit

class Chat: NSObject {
    
    var messages: [Message] = []
    var users: [User] = []
    let messageDuration: Double!
    
    private var messageIDs: [String] = []
    private var userIDs: [String] = []
    private var object: PFObject!
    
    /**
     Loads chat from an exisiting PFObject.
     */
    init(object: PFObject, completion: () -> ()) {
        
        self.object = object
        
        messageDuration = object["messageDuration"] as! Double
        messageIDs = object["messages"] as! [String]
        userIDs = object["users"] as! [String]
        
        super.init()
        
        for userID in userIDs {
            let query = PFQuery(className: "User")
            query.whereKey("objectID", equalTo: userID)
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    for object in objects! {
                        self.users.append(User(user: object as! PFUser))
                    }
                }
            })
        }
        
        let query = PFQuery(className: "Message")
        query.orderByDescending("createdAt")
        query.whereKey("objectID", containedIn: messageIDs)
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for object in objects! {
                    self.messages.append(Message(object: object, completion: { 
                        if self.messages.count == objects?.count {
                            completion()
                        }
                    }))
                }
            }
        }
    }
    
    /**
     Creates a new chat with a given message duration
     */
    init(messageDuration: Double, users: [User]) {
        object = PFObject(className: "Chat")
        self.messageDuration = messageDuration
        
        super.init()

        for user in users {
            add(user)
        }
    }
    
    /**
     Records a track from a certain audio node for the set track duration, adds it to a message and sends it immediately.
     */
    func recordSend(instrument: AKNode, success: () -> (), failure: (NSError) -> ()) {
        let message = Message(previousMessage: messages[messages.count-1])
        let track = Track()
        track.record(instrument, duration: messageDuration) {
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
     Updates the chat from the server if it is necessary
     */
    func fetch(success: () -> (), failure: (NSError) -> ()) {
        object.fetchIfNeededInBackgroundWithBlock() { (object: PFObject?, error: NSError?) in
            if let object = object {
                
                let serverMessageIDs = Set(object["messages"] as! [String])
                
                let newMessageIDs = serverMessageIDs.subtract(self.messageIDs)
                
                let query = PFQuery(className: "Message")
                query.whereKey("objectID", containedIn: Array(newMessageIDs))
                
                query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
                    if let error = error {
                        failure(error)
                    } else {
                        for object in objects! {
                            self.messages.append(Message(object: object, completion: {
                                if self.messages.count == objects?.count {
                                    success()
                                }
                            }))
                        }
                    }
                }
                
                
            } else {
                failure(error!)
            }
        }
    }
    
    /**
     Push the updates to the chat back to the server
     */
    func push(completion: PFBooleanResultBlock?) {
        
        object["users"] = userIDs
        object["messages"] = messageIDs

        object.saveInBackgroundWithBlock(completion)
    }
}
