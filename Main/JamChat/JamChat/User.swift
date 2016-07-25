//
//  User.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/7/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4
import FBSDKCoreKit

class User: NSObject {
    
    static private(set) var currentUser: User? = nil
    
    static let loginDelegate = LoginDelegate()
    
    private(set) var parseUser: PFUser!
    
    var facebookID: String!
    var name: String!
    var firstName: String!
    var lastName: String!
    var middleName: String!
    var profileImageURL: NSURL!
    var email: String?
    
    var friends: [User] = []
        
    var users: [User] = []
    
    var tracks: [Track] = []
    
    // should store and retrieve this
    var instrumentCount: [Instrument : Int] = [Instrument.acousticBass:0, Instrument.choir:0, Instrument.electricBass:0, Instrument.electricGuitar:0, Instrument.piano:0, Instrument.saxophone:0]
    
    /**
     Initializes user object based on a Parse User.
     */
    init(user: PFUser) {
        parseUser = user
    }
    
    func loadData(success: (() -> ())?) {
        parseUser.fetchIfNeededInBackgroundWithBlock() { (_: PFObject?, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.facebookID = self.parseUser["facebookID"] as! String
                self.name = self.parseUser["name"] as! String
                self.firstName = self.parseUser["firstName"] as! String
                self.lastName = self.parseUser["lastName"] as! String
                self.middleName = self.parseUser["middleName"] as! String
                self.profileImageURL = NSURL(string: self.parseUser["profileImageURL"] as! String)!
                print("Loaded \(self.name)'s data")
                success?()
            }
        }
    }
    
    func loadFriends(completion: (() -> ())?) {
        print("Loading \(name)'s frieds")
        
        // Create request for user's Facebook data
        let request = FBSDKGraphRequest(graphPath: facebookID, parameters:["fields" : "friends"])
        
        // Send request to Facebook
        request.startWithCompletionHandler {
            
            (connection, result, error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
            else if let userData = result as? [String:AnyObject] {
                let friendDict = userData["friends"] as! NSDictionary
                let friendData = friendDict["data"] as! [[String : String]]
                
                var friendIDs: [String] = []
                
                for friend in friendData {
                    friendIDs.append(friend["id"]!)
                }
                
                let query = PFQuery(className: "_User")
                query.whereKey("facebookID", containedIn: friendIDs)
    
                query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
                    
                    if let users = objects as? [PFUser] {
                        for user in users {
                            self.friends.append(User(user: user))
                        }
                        print("Succesfully loaded \(self.name)'s friends: \(self.friends)")
                        completion?()
                    }

                })
            }
        }
    }
    
    /**
     Checks if an user is already logged in
     */
    class func isLoggedIn() -> Bool {
        if let user = PFUser.currentUser() {
            User.currentUser = User(user: user)
            return PFFacebookUtils.isLinkedWithUser(user)
        }
        
        return false
    }
    
    /**
     Logs out the current user, it is recommended to call login() immediately after.
     */
    class func logout() {
        PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser()!)
        PFUser.logOut()
        currentUser = nil
        FBSDKLoginManager().logOut()
    }
    
    /**
     Attempts to log in an user, presenting a login subview in the given view.
     
     - parameters:
        - controller: view controller on which to present the login subview
        - success: block that will be called when the user is logged in succesfully
        - failure: block that will be called when there's an error
    */
    class func login(controller: UIViewController, success: (() -> ())?, failure: ((NSError?) -> ())?) {
        loginDelegate.loginSuccess = success
        loginDelegate.loginFailure = failure
        loginDelegate.controller = controller
        
        // Initialize login view
        let loginViewController = PFLogInViewController()
        loginViewController.delegate = loginDelegate
        
        // Configure custom login
        loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .Facebook]
        loginViewController.facebookPermissions = ["email", "public_profile", "user_friends"]
        loginViewController.emailAsUsername = true
        
        // Present view
        controller.presentViewController(loginViewController, animated: false, completion: nil)
    }
    
    func updateDataFromProfile (profile: FBSDKProfile!) {
        
        facebookID = profile.userID
        name = profile.name
        firstName = profile.firstName
        lastName = profile.lastName
        middleName = profile.middleName
        profileImageURL = profile.imageURLForPictureMode(.Square, size: CGSize(width: 500, height: 500))
        
        parseUser["facebookID"] = facebookID
        parseUser["name"] = name
        parseUser["firstName"] = firstName
        parseUser["lastName"] = lastName
        parseUser["middleName"] = middleName ?? ""
        parseUser["profileImageURL"] = profileImageURL.absoluteString
        parseUser.saveInBackground()
        
        print("Updated \(name)'s data")
    }
    
    /**
     Returns the number of jams the current user is part of.
     */
    func getNumberOfJams(completion: (Int) -> ()) {
        let query = PFQuery(className: "Jam")
        query.whereKey("users", containsString: facebookID)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion(Int(count))
            }
        }
    }
    
    /**
     Returns the number of tracks the current user has created.
     */
    func getNumberOfTracks(completion: (Int) -> ()) {
        
        let query = PFQuery(className: "Track")
        query.whereKey("author", containsString: parseUser.objectId)
        query.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion(Int(count))
            }
        }
    }
    
    /**
     Updates an array with the tracks the current user has created.
     */
    func getUserTracks(completion: () -> ()) {
        
        User.currentUser!.getNumberOfTracks({ (count: Int) in
            let numTracks = count
            
            // if the user has not created any tracks, do not create a query
            if(numTracks != 0) {
                let query = PFQuery(className: "Track")
                query.whereKey("author", containsString: self.parseUser.objectId)
                query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
                    for object in objects! {
                        let track = Track(object: object)
                        self.tracks.append(track)
                    }
                }
            }

        })
        

    }
    
    /**
     Returns an array of Users, that represents the current user's top three friends.
     */
    func getTopFriends() -> [User] {

        var numUserOccurrences: [String: Int] = [:] // maps each facebookID to a number of occurrences
        var numUserObjOccurrences: [User: Int] = [:] // maps each user Object to a number of occurrences
        var topIDs: [String] = [] // an array of the facebookIDs of the user's top friends
        var topFriends: [User] = [] // and array of the user's top friends
        
        var friendIDs: [String] = []
        for friend in friends {
            friendIDs.append(friend.facebookID)
        }
        
        for jam in Jam.currentUserJams {
            for user in jam.users {
                if(friendIDs.contains(user.facebookID)) { // ensures that a 'top friend' is a friend of the current user
                    if(user.facebookID != self.facebookID) {
                        if (!numUserOccurrences.keys.contains(user.facebookID)) {
                            numUserOccurrences[user.facebookID] = 1
                            numUserObjOccurrences[user] = 1
                        } else {
                            var curNum = numUserOccurrences[user.facebookID]
                            curNum = curNum! + 1 // update the number of occurrences
                            numUserOccurrences[user.facebookID] = curNum
                            numUserObjOccurrences[user] = curNum
                        }
                    }
                }
            }
        }
        
        // sort the dictionaries by number of occurrences, from highest to lowest
        topIDs = numUserOccurrences.keysSortedByValue(>)
        topFriends = numUserObjOccurrences.keysSortedByValue(>)
        

        let arrayUsers = getUserFromID(topFriends, arrayOfIDs: topIDs)
        
        return arrayUsers
        
    }
    
    /**
     Given an array of FacebookIDs, returns an array of Users containing the current user's top three friends.
     */
    func getUserFromID(arrayOfUsers: [User], arrayOfIDs: [String]) -> [User] {
        var newArrayUsers = [User]()
        
        var index = 0
        while (index < arrayOfIDs.count) {
            for user in arrayOfUsers {
                if user.facebookID == arrayOfIDs[index] {
                    newArrayUsers.append(user)
                    index += 1
                    break;
                }
            }
        }
        
        return newArrayUsers
    }
    
    func getTopFriendNumbers() -> [Int] {
        var friendCountArray: [Int] = []
        
        var numUserOccurrences: [String: Int] = [:] // maps each facebookID to a number of occurrences
        var numUserObjOccurrences: [User: Int] = [:] // maps each user Object to a number of occurrences
        
        for jam in Jam.currentUserJams {
            for user in jam.users {
                if(user.facebookID != User.currentUser?.facebookID) {
                    if (!numUserOccurrences.keys.contains(user.facebookID)) {
                        numUserOccurrences[user.facebookID] = 1
                        numUserObjOccurrences[user] = 1
                    } else {
                        var curNum = numUserOccurrences[user.facebookID]
                        curNum = curNum! + 1 // update the number of occurrences
                        numUserOccurrences[user.facebookID] = curNum
                        numUserObjOccurrences[user] = curNum
                    }
                }
            }
        }
        
        for number in numUserOccurrences.values {
            friendCountArray.append(number)
        }
        
        return friendCountArray
    }
    
    /**
     Updates the number of times a user has used a particular instrument.
     */
    func incrementInstrument(instrumentUsed: Instrument) {
        for instrument in instrumentCount.keys {
            if(instrument.name == instrumentUsed.name) {
                var curNum = instrumentCount[instrument]
                curNum = curNum! + 1
                instrumentCount[instrument] = curNum
            }
        }
    }

}

// Delegate used for the login view success and failure cases
class LoginDelegate: NSObject, PFLogInViewControllerDelegate {
    
    var loginSuccess: (() -> ())? = nil
    var loginFailure: ((NSError?) -> ())? = nil
    var controller: UIViewController?
    
    // Called when user is logged in succesfully, dismissing the login view
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
       
        FBSDKProfile.loadCurrentProfileWithCompletion({ (profile: FBSDKProfile!, error: NSError!) in
            
            if let error = error {
                self.loginFailure?(error)
            } else {
                User.currentUser = User(user: user)
                User.currentUser?.updateDataFromProfile(profile)
                self.controller!.dismissViewControllerAnimated(true, completion: nil)
                self.loginSuccess?()
                print("Logged in \(User.currentUser!.name)")
            }
            
        })
    }
    
    // Called when the login fails
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        loginFailure?(error)
    }
    
}

extension Dictionary {
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sort(isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory (this is equivalent to Pascals answer in an generic extension)
    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
    
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sort() {
                let (_, lv) = $0
                let (_, rv) = $1
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, _) = $0
                return k
        }
    }
}
