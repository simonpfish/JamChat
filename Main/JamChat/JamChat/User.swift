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
        facebookID = user["facebookID"] as! String
        name = user["name"] as! String
        firstName = user["firstName"] as! String
        lastName = user["lastName"] as! String
        middleName = user["middleName"] as! String
        profileImageURL = NSURL(string: user["profileImageURL"] as! String)!
        
        parseUser = user
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
        if PFUser.currentUser() != nil && currentUser != nil {
            return PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)
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
    
    
}

// Delegate used for the login view success and failure cases
class LoginDelegate: NSObject, PFLogInViewControllerDelegate {
    
    var loginSuccess: (() -> ())? = nil
    var loginFailure: ((NSError?) -> ())? = nil
    var controller: UIViewController?
    
    // Called when user is logged in succesfully, dismissing the login view
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
       
        FBSDKProfile.loadCurrentProfileWithCompletion({ (profile: FBSDKProfile!, error: NSError!) in
            User.currentUser?.parseUser["facebookID"] = profile.userID
            User.currentUser?.parseUser["name"] = profile.name
            User.currentUser?.parseUser["firstName"] = profile.firstName
            User.currentUser?.parseUser["lastName"] = profile.lastName
            User.currentUser?.parseUser["middleName"] = profile.middleName
            User.currentUser?.parseUser["profileImageURL"] = profile.imageURLForPictureMode(.Square, size: CGSize(width: 500, height: 500))
            User.currentUser?.parseUser.saveInBackgroundWithBlock({ (success: Bool, failure: NSError?) in
                if let error = error {
                    self.loginFailure?(error)
                }
                User.currentUser = User(user: PFUser.currentUser()!)
                
                self.controller!.dismissViewControllerAnimated(true, completion: nil)
                if let success = self.loginSuccess {
                    success()
                }
            })
        })
    }
    
    // Called when the login fails
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        loginFailure?(error)
    }
}
