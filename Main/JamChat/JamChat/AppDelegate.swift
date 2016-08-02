//
//  AppDelegate.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/6/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse
import ParseFacebookUtilsV4
import AudioKit
import PubNub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    var window: UIWindow?
    
    static var mainMixer: AKMixer?
    
    var client : PubNub
    var config : PNConfiguration
    
    override init() {
        config = PNConfiguration(publishKey: "pub-c-9d14846c-d67e-4d85-b279-b189919c1ed6", subscribeKey: "sub-c-df45123e-52aa-11e6-ba28-02ee2ddab7fe")
        client = PubNub.clientWithConfiguration(config)
        client.subscribeToChannels(["global"], withPresence: false)
        
        super.init()
        client.addListener(self)
    }

    static func restartAudiokit() {
        print("Restarting audio")
        AudioKit.stop()
        
        mainMixer?.volume = 1
        Track.mixer.volume = 1
        Instrument.mixer.volume = 1
        
        AudioKit.start()
    }
    
    func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        print(message.data)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.initializeWithConfiguration(
            ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "jamchat-parse"
                configuration.clientKey = "a308h2fenwdjalskmdkland#@!DSa"
                configuration.server = "https://jamchat-parse.herokuapp.com/parse"
            })
        )
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions);
        
        // Push
        let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Audio setup
        print("Setting up audio")
        AppDelegate.mainMixer = AKMixer(Track.mixer, Instrument.mixer)
        AudioKit.output = AppDelegate.mainMixer
        Track.mixer.start()
        Instrument.mixer.start()
        AppDelegate.mainMixer!.start()
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? [NSObject : AnyObject] {
            if let aps = notification["aps"] as? NSDictionary {
                if let userID = aps["userID"] as? String {
                    if userID != User.currentUser!.facebookID {
                        if let jamID = aps["jamID"] as? String {
                            let root = self.window?.rootViewController as! PagerViewController
                            root.moveToViewControllerAtIndex(1, animated: false)
                            
                            let query = PFQuery(className: "Jam")
                            var jam: Jam?
                            
                            query.whereKey("objectId", equalTo: jamID)
                            query.includeKey("tracks")
                            query.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) in
                                if error == nil {
                                    jam = Jam(object: objects!.last!)
                                    
                                    jam?.loadUsers({ 
                                        let jamView = JamViewController()
                                        jamView.jam = jam
                                        
                                        let home = root.viewControllers[1] as! HomeViewController
                                        home.presentViewController(jamView, animated: true, completion: nil)
                                    })
                                }
                            }
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName("new_jam", object: nil)
                        }
                    }
                }
            }
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Push setup:
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation!.setDeviceTokenFromData(deviceToken)
        installation!.channels = ["global"]
        installation!.saveInBackground()
        NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: "DeviceToken")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let userID = aps["userID"] as? String {
                if userID != User.currentUser!.facebookID {
                    if let trackID = aps["trackID"] as? String {
                        let jamID = aps["jamID"] as! String
                        NSNotificationCenter.defaultCenter().postNotificationName("new_message", object: [trackID, jamID])
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName("new_jam", object: nil)
                    }
                }
            }
        }
    }
    
}

