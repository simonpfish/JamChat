//
//  Track.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse
import AudioKit

class Track: NSObject {
    
    
    private(set) var author: User!
    
    private var player: AKAudioPlayer?
    private var exportedPath: String?
    private var file: PFFile!
    
    init(object: PFObject) {
        file = object["media"] as! PFFile
        let parseUser = object["author"] as! PFUser
        author = User(user: parseUser)
    }
    
    
    /**
     Uploads track to parse
     */
    func upload(completion: PFBooleanResultBlock?) {
        // Create Parse object
        let object = PFObject(className: "Track")
        
        // Add relevant fields to the object
        object["media"] = PFFile(name: "audio.m4a", data: NSData(contentsOfFile: exportedPath!)!)
        object["author"] = author.parseUser // Pointer column type that points to PFUser
        
        object.saveInBackgroundWithBlock(completion)
    }
}
