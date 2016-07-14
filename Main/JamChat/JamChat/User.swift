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
    
    func loadFacebookData(completion: (() -> ())?) {
        // Create request for user's Facebook data
        let request = FBSDKGraphRequest(graphPath: facebookID, parameters:["fields" : "email,name,friends"])
        
        // Send request to Facebook
        request.startWithCompletionHandler {
            
            (connection, result, error) in
            
            if error != nil {
                // Some error checking here
            }
            else if let userData = result as? [String:AnyObject] {
                self.email = userData["email"] as? String
                print(self.name)
                if let completion = completion {
                    completion()
                }
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
