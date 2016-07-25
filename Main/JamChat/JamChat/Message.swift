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
    
    var tracks: [Track] = []
    private var newTracks: [Track] = []
    private(set) var id: String?
    private var object: PFObject!
    private var tracksAreLoaded = false
    
    /**
     Initializes a new message based on a parse object
     */
    init(object: PFObject) {
        super.init()
        
        self.object = object
        id = object.objectId
    }
    
    func loadTracks(completion: () -> ()) {
        print("Loading tracks for message \(self.id ?? "NEW")")
        if tracksAreLoaded {
            print("Tracks are already loaded for message \(self.id ?? "NEW")")
            completion()
        } else {
            tracks = []
            object.fetchIfNeededInBackgroundWithBlock { (_: PFObject?, error: NSError?) in
                let trackIDs = self.object["tracks"] as! [String]
                
                let query = PFQuery(className: "Track")
                query.orderByAscending("createdAt")
                query.whereKey("identifier", containedIn: trackIDs)
                
                query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
                    for object in objects! {
                        let track = Track(object: object)
                        self.tracks.append(track)
                    }
                    
                    var loadedCount = 0
                    for track in self.tracks {
                        track.loadMedia({
                            loadedCount += 1
                            if loadedCount == self.tracks.count {
                                print("Succesfully loaded tracks for message \(self.id ?? "NEW")")
                                self.tracksAreLoaded = true
                                completion()
                            }
                            }, failure: { (error: NSError) in
                                print(error.localizedDescription)
                        })
                    }
                }
            }
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
    func play(startedPlaying: (() -> ())?) {
        print("Playing message \(self.id ?? "NEW")")
        for track in tracks {
            track.play()
        }
        startedPlaying?()
    }
    
    func stop() {
        print("Playing message \(self.id ?? "NEW")")
        for track in tracks {
            track.stopLooping()
        }
    }
    
    /**
     Adds a new track to the message
     */
    func add(track: Track) {
        print("Added track \(track.identifier) to message")

        tracks.append(track)
        newTracks.append(track)
    }
    
    /**
     Uploads message to parse, creating a new one in the server. Will not upload anything if no new tracks were added.
     */
    func send(completion: PFBooleanResultBlock?) {
        object = PFObject(className: "Message")
        
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
                        self.object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            self.id = self.object.objectId
                            print("Sent message \(self.id!)")
                            completion!(success, error)
                        })
                    }
                }
            })
        }
    }
    
}
