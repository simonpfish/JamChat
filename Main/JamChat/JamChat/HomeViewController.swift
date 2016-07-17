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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var jams: [Jam] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        AudioKit.output = Track.mainMixer
        AudioKit.start()
        // Do any additional setup after loading the view.
        
        if (!User.isLoggedIn()) {
            User.login(self, success: {
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
                    self.loadFeed()
                }
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadFeed() {
        Jam.downloadCurrentUserJams({ (jams: [Jam]) in
            self.jams = jams
            print("Reloading table view")
            self.tableView.reloadData()
        }) { (error: NSError) in
            print(error.localizedDescription)
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

    @IBAction func onNewJam(sender: AnyObject) {
        let newJamController = JamCreationViewController()
        presentViewController(newJamController, animated: true, completion: nil)
    }

    
    @IBAction func onLogout(sender: AnyObject) {
        User.logout()
        User.login(self, success: { 
            self.loadFeed()
        }) { (error: NSError?) in
            print(error?.localizedDescription)
        }
    }
    
    
    func addNewJam(userIDs: [String]) {
        var jam: Jam!
        if userIDs.count == 0 {
            print("Can't create jam without users")
        } else {
            jam = Jam(messageDuration: 5, userIDs: userIDs)
            jam.push { (success: Bool, error: NSError?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.jams.append(jam)
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