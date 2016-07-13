//
//  Message.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse

class Message: NSObject {
    
    private var tracks: [Track] = []
    private var newTracks: [Track] = []
    private(set) var id: String?
    private var object: PFObject!
    
    /**
     Initializes a new message based on a parse object
     */
    init(object: PFObject) {
        super.init()
        
        self.object = object
        id = object.objectId
    }
    
    func loadTracks(completion: () -> ()) {
        let trackIDs = object["tracks"] as! [String]
        
        let query = PFQuery(className: "Track")
        query.orderByDescending("createdAt")
        query.whereKey("identifier", containedIn: trackIDs)
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
            for object in objects! {
                let track = Track(object: object)
                self.tracks.append(track)
            }
        }
        
        var loadedCount = 0
        for track in tracks {
            track.loadMedia({ 
                loadedCount += 1
                if loadedCount == self.tracks.count {
                    completion()
                }
            }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
    }
    
    /**
     Initializes a new message that builds on top of an older one
     */
    init(previousMessage: Message?) {
        super.init()
        
        tracks = previousMessage?.tracks ?? []
    }
    
    /**
     Plays the message to the main audio output
     */
    func play() {
        for track in tracks {
            track.play()
        }
    }
    
    /**
     Adds a new track to the message
     */
    func add(track: Track) {
        tracks.append(track)
        newTracks.append(track)
    }
    
    /**
     Uploads message to parse, creating a new one in the server. Will not upload anything if no new tracks were added.
     */
    func send(completion: PFBooleanResultBlock?) {
        let object = PFObject(className: "Message")
        
        var trackIDs: [String] = []
        
        for track in tracks {
            trackIDs.append(track.identifier)
        }
        
        object["tracks"] = trackIDs

        var uploadedCount = 0
        for track in newTracks {
            track.upload({ (success: Bool, error: NSError?) in
                if let error = error {
                    completion?(false, error)
                } else {
                    uploadedCount += 1
                    if uploadedCount == self.newTracks.count {
                        object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            self.id = object.objectId
                            completion!(success, error)
                        })
                    }
                }
            })
        }
    }
    
}
