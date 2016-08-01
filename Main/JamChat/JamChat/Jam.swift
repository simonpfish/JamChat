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
import NVActivityIndicatorView

class Jam: NSObject {
    
    private(set) var isPlaying = false
    var tracks: [Track] = []
    var users: [User] = []
    private(set) var updatedAt: NSDate!
    let duration: Double!
    var title: String = ""
    static var currentUserJams: [Jam] = []
    static var usersInCurreentUserJams: [User] = []
    var tempo: Int?
    var numMeasures: Int?
    var id: String {
        get {
            return object.objectId!
        }
    }
    
    var playthroughProgress: Double {
        get {
            return (tracks.last?.playbackTime)! / duration
        }
    }
    
    private var trackObjects: [PFObject] = []
    private var trackIDs: [String] = []
    private(set) var userIDs: [String] = []
    private var object: PFObject!
    
    /**
     Loads jam from an exisiting PFObject.
     */
    init(object: PFObject) {
        
        self.object = object
        
        duration = object["messageDuration"] as! Double
        
        trackObjects = object["tracks"] as! [PFObject]
        for object in trackObjects {
            tracks.append(Track(object: object))
        }
        
        userIDs = object["users"] as! [String]
        title = object["title"] as? String ?? ""
        tempo = object["tempo"] as? Int
        numMeasures = object["numMeasures"] as? Int
        updatedAt = object.updatedAt
        
        super.init()
    }
    
    /**
     Creates a new jam with a given message duration and name
     */
    init(messageDuration: Double, users: [User], title: String) {
        object = PFObject(className: "Jam")
        self.duration = messageDuration
        self.title = title
        self.updatedAt = NSDate()
        
        super.init()
        
        for user in users {
            add(user)
        }
        add(User.currentUser!)
    }
    
    func loadUsers(completion: () -> ()) {
        print("Loading jam \(title) users")
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
    
    func loadTracks(completion: () -> ()) {
        print("Loading jam \(title) tracks")
        
        var loadedCount = 0
        
        if tracks.count == 0 {
            completion()
            return
        }
        
        for track in tracks {
            track.loadMedia({ 
                loadedCount += 1
                if loadedCount == self.tracks.count {
                    print("Successfully loaded jam \(self.title) tracks")
                    completion()
                }
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
            })
        }
    }
    
    init(messageDuration: Double, userIDs: [String], title: String, tempo: Int, numMeasures: Int) {
        object = PFObject(className: "Jam")
        self.duration = messageDuration
        self.userIDs = userIDs
        self.userIDs.append(User.currentUser!.facebookID)
        self.title = title
        self.tempo = tempo
        self.numMeasures = numMeasures
    }
    
    /**
     Records a track from a certain audio node for the set track duration, adds it to a message and sends it immediately.
     */
    func recordSend(instrument: Instrument, success: () -> (), failure: (NSError) -> ()) {
        let track = Track()
        track.recordInstrument(instrument, duration: duration) {
            track.upload({ (_: Bool, error: NSError?) in
                if let error = error {
                    failure(error)
                } else {
                    self.tracks.append(track)
                    self.trackObjects.append(track.object)
                    self.push({ (_: Bool, error: NSError?) in
                        if let error = error {
                            failure(error)
                        } else {
                            PubNubHandler.notifyNewMessage(self)
                            success()
                        }
                    })
                }
            })
        }
    }
    
    // Utilities to make sure arrays are updated accordingly:
    
    private func add(user: User) {
        if let id = user.parseUser.objectId {
            users.append(user)
            userIDs.append(id)
        }
    }
    
    /**
     Fetches a particular track from the server and adds it to the jam
     */
    func fetchTrack(id: String, completion: () -> ()) {
        let query = PFQuery(className: "Track")
        query.whereKey("id", equalTo: id)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if let object = objects?.first {
                self.trackObjects.append(object)
                self.tracks.append(Track(object: object))
                completion()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /**
     Push the updates to the jam back to the server
     */
    func push(completion: PFBooleanResultBlock?) {
        print("Pushing jam \(title)")
        
        object["messageDuration"] = duration
        object["users"] = userIDs
        object["tracks"] = trackObjects
        object["title"] = title
        object["tempo"] = tempo
        object["numMeasures"] = numMeasures
        
        object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            print("Finished pushing jam \(self.title)")
            if self.tracks.count == 0 {
                PubNubHandler.notifyNewJam(self)
            }
            completion?(success, error)
        })
    }
    
    
    func play(startedPlaying: (() -> ())?) {
        print("Playing jam \(title)")
        for track in tracks {
            track.playLooping()
        }
        isPlaying = true
        startedPlaying?()
    }
    
    func stop() {
        print("Stopping jam \(title)")
        for track in tracks {
            track.stopLooping()
        }
        isPlaying = false
    }
}
