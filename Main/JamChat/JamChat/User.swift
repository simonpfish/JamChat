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
    var pictureURL: NSURL!
    var email: String!
    
    
    // Initializes user based on a facebookID, pulling all the user data from the Facebook API. Used only internally.
    private init(userId: String, completion: (() -> ())?) {
        super.init()
        
        // Create request for user's Facebook data
        let request = FBSDKGraphRequest(graphPath: userId, parameters:["fields" : "email,name,friends"])
        
        // Send request to Facebook
        request.startWithCompletionHandler {
            
            (connection, result, error) in
            
            if error != nil {
                // Some error checking here
            }
            else if let userData = result as? [String:AnyObject] {
                self.facebookID = userData["id"] as! String
                self.name = userData["name"] as! String
                self.email = userData["email"] as? String
                self.pictureURL = NSURL(string: "https://graph.facebook.com/\(self.facebookID)/picture?type=large&return_ssl_resources=1")!
                print(self.name)
                if let completion = completion {
                    completion()
                }
            }
            
            
        }
    }
    
    /**
     Initializes user object based on a Parse User.
     */
    convenience init(user: PFUser, completion: (() -> ())?) {
        let ID = user["facebookID"] as! String
        self.init(userId: ID, completion: completion)
        parseUser = user
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
        User.currentUser = User(userId: "me", completion: nil)
        User.currentUser?.parseUser = PFUser.currentUser()
        
        FBSDKProfile.loadCurrentProfileWithCompletion({ (profile: FBSDKProfile!, error: NSError!) in
            User.currentUser?.parseUser["facebookID"] = profile.userID
            User.currentUser?.parseUser.saveInBackground()
        })
        
        controller!.dismissViewControllerAnimated(true, completion: nil)
        if let success = loginSuccess {
            success()
        }
        
    }
    
    // Called when the login fails
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        if let failure = loginFailure {
            failure(error)
        }
    }
}
