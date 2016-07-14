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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var chats: [Chat] = []
    
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
        Chat.downloadCurrentUserChats({ (chats: [Chat]) in
            self.chats = chats
            print("Reloading table view")
            self.tableView.reloadData()
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! ChatCell
        cell.chat = chats[indexPath.row]
        return cell
    }

    @IBAction func onNewChat(sender: AnyObject) {
        let newChatController = ChatCreationViewController()
        presentViewController(newChatController, animated: true, completion: nil)
    }

    
    @IBAction func onLogout(sender: AnyObject) {
        User.logout()
        User.login(self, success: { 
            self.loadFeed()
        }) { (error: NSError?) in
            print(error?.localizedDescription)
        }
        
    }
    
    
    func addNewChat(userIDs: [String]) {
        var chat: Chat!
        if userIDs.count == 0 {
            print("Can't create chat without users")
        } else {
            chat = Chat(messageDuration: 5, userIDs: userIDs)
            chat.push { (success: Bool, error: NSError?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.chats.append(chat)
                    print("Succesfully created chat, reloading data")
                    chat.loadData({
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
        if let chatView = segue.destinationViewController as? ChatViewController {
            let cell = sender as! ChatCell
            chatView.chat = cell.chat
        }
        
    }
 

}
