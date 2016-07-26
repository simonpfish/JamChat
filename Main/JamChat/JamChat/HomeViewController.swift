//
//  FeedViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse
import ParseUI
import AudioKit
import DGElasticPullToRefresh
import NVActivityIndicatorView
import PubNub

@IBDesignable class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate

    @IBOutlet weak var loadingIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBInspectable var refreshTint: UIColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
    @IBInspectable var refreshFill: UIColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
    @IBInspectable var refreshBackground: UIColor {
        return tableView.backgroundColor!
    }
    var jams: [Jam] = []
    var jamIDs: [String] = []
    
    @IBInspectable var backTint: UIColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = backTint

        // Set up the table view
        tableView.delegate = self
        tableView.dataSource = self
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = refreshTint
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.loadFeed()
        }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(refreshFill)
        tableView.dg_setPullToRefreshBackgroundColor(refreshBackground)
        
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.type = .LineScaleParty
        loadingIndicatorView.color = refreshFill
        
        // Handle login and user persistance
        if (!User.isLoggedIn()) {
            User.login(self, success: {
                self.loadingIndicatorView.startAnimation()
                self.loadFeed()
                }, failure: { (error: NSError?) in
                    print(error?.localizedDescription)
            })
        } else {
            FBSDKProfile.loadCurrentProfileWithCompletion({ (profile: FBSDKProfile!, error: NSError!) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    User.currentUser?.updateDataFromProfile(profile)
                    self.loadingIndicatorView.startAnimation()
                    self.loadFeed()
                }
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            loadFeed()
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
    }
    
    func loadFeed() {
        
        Jam.downloadCurrentUserJams({ (jams: [Jam]) in
            self.jams = jams
            print("Reloading table view")
            self.tableView.reloadData()
            self.tableView.dg_stopLoading()
            self.loadingIndicatorView.stopAnimation()
            
            if self.jamIDs.count == 0 {
                for jam in jams {
                    self.jamIDs.append(jam.id)
                }
                
                self.appDelegate.client.subscribeToChannels(self.jamIDs, withPresence: true)
                let userToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as! NSData
                self.appDelegate.client.addPushNotificationsOnChannels(self.jamIDs, withDevicePushToken: userToken) { (status: PNAcknowledgmentStatus) in
                    print(status.debugDescription)
                }
            }
            
        }) { (error: NSError) in
            print(error.localizedDescription)
            self.tableView.dg_stopLoading()
            self.loadingIndicatorView.stopAnimation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JamCell") as! JamCell
        cell.jam = jams[indexPath.row]
        return cell
    }
        
    func addNewJam(duration: Double, userIDs: [String], name: String, tempo: Int) {
        var jam: Jam!
        let jamLength = duration
        let jamName = name
        let jamTempo = tempo
        
        if userIDs.count == 0 {
            print("Can't create jam without users")
        } else {
            jam = Jam(messageDuration: Double(jamLength), userIDs: userIDs, title: jamName, tempo: jamTempo)
            jam.push { (success: Bool, error: NSError?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.jams.insert(jam, atIndex: 0)
                    print("Succesfully created jam, reloading data")
                    jam.loadData({
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let jamView = segue.destinationViewController as? JamViewController {
            let cell = sender as! JamCell
            jamView.jam = cell.jam
        }
        
    }
    
}

extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}
