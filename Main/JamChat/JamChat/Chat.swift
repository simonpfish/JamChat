//
//  Chat.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse

class Chat: NSObject {
    
    var messages: [Message] = []
    private var messageIDs: [String] = []
    var object: PFObject!
    
    init(object: PFObject, completion: () -> ()) {
        super.init()
        
        self.object = object
        
        messageIDs = object["messages"] as! [String]
        
        let query = PFQuery(className: "Message")
        query.orderByDescending("createdAt")
        query.whereKey("identifier", containedIn: messageIDs)
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
            for object in objects! {
                self.messages.append(Message(object: object, completion: { 
                    if self.messages.count == objects?.count {
                        completion()
                    }
                }))
            }
        }
    }
    
    override init() {
        object = PFObject(className: "Chat")
        super.init()
    }
    
    func update(success: () -> (), failure: (NSError) -> ()) {
        object.fetchIfNeededInBackgroundWithBlock() { (object: PFObject?, error: NSError?) in
            if let object = object {
                
                let serverMessageIDs = Set(object["messages"] as! [String])
                
                let newMessageIDs = serverMessageIDs.subtract(self.messageIDs)
                
                for newMessageID in newMessageIDs {
                    let query = PFQuery(className: "Message")
                    query.whereKey("objectID", equalTo: newMessageID)
                }
                
                success()
            } else {
                failure(error!)
            }
        }
    }
    
    func upload(completion: PFBooleanResultBlock?) {
        
        var messageIDs: [String] = []
        
        for message in messages {
            if let id = message.id {
                messageIDs.append(id)
            }
        }
        
        object["messages"] = messageIDs

        object.saveInBackgroundWithBlock(completion)
    }
}
