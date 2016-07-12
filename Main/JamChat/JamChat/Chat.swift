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
        
        
        loadUsers { 
            self.loadMessages({ 
                completion()
            })
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
        add(User.currentUser!)
    }
    
    private func loadUsers(completion: () -> ()) {
            let query = PFQuery(className: "_User")
            query.whereKey("objectId", containedIn: userIDs)
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    var loadedCount = 0
                    for object in objects! {
                        self.users.append(User(user: object as! PFUser, completion: {
                            loadedCount += 1
                            print("done loading user \(loadedCount) \(objects!.count)")
                            if loadedCount == objects?.count {
                                print("done loading users")
                                completion()
                            }
                        }))
                    }
                }
            })
    }
    
    private func loadMessages(completion: () -> ()) {
        let query = PFQuery(className: "Message")
        query.orderByDescending("createdAt")
        query.whereKey("objectId", containedIn: messageIDs)
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects?.count == 0 {
                    completion()
                } else {
                    var loadedCount = 0
                    for object in objects! {
                        self.messages.append(Message(object: object, completion: {
                            loadedCount += 1
                            if loadedCount == objects?.count {
                                completion()
                            }
                        }))
                    }
                }
            }
        }
    }
    
    init(messageDuration: Double, userIDs: [String], completion: () -> ()) {
        object = PFObject(className: "Chat")
        self.messageDuration = messageDuration
        self.userIDs = userIDs

        super.init()
        
        loadUsers {
            self.add(User.currentUser!)
            completion()
        }
    }
    
    /**
     Records a track from a certain audio node for the set track duration, adds it to a message and sends it immediately.
     */
    func recordSend(instrument: AKNode, success: () -> (), failure: (NSError) -> ()) {
        let message: Message
        if messages.count > 0 {
            message = Message(previousMessage: messages[messages.count-1])
        } else {
            message = Message(previousMessage: nil)
        }
        
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
                query.whereKey("objectId", containedIn: Array(newMessageIDs))
                
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
        
        object["messageDuration"] = messageDuration
        object["users"] = userIDs
        object["messages"] = messageIDs

        object.saveInBackgroundWithBlock(completion)
    }
    
    class func downloadActiveUserChats(success: ([Chat]) -> (), failure: (NSError) -> ()) {
        let query = PFQuery(className: "Chat")
        
        query.whereKey("users", containsString: User.currentUser!.parseUser.objectId!)
        query.orderByDescending("modifiedAt")
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if let error = error {
                failure(error)
            } else {
                var chats: [Chat] = []
                var loadedCount = 0
                for object in objects ?? [] {
                    chats.append(Chat(object: object, completion: {
                        loadedCount += 1
                        if loadedCount == objects?.count {
                            success(chats)
                        }
                    }))
                }
            }
        }
    }
}
