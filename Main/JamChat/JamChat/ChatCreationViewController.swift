//
//  ChatCreationViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import RAMReel

class ChatCreationViewController: UIViewController {
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    var selectedFriendIDs: [String] = []
    
    @IBOutlet weak var selectedUsersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        initializeFriendPicker()
    }
    
    func initializeFriendPicker() {
        
        var friendNames: [String] = []
        
        User.currentUser?.loadFriends({ 
            for friend in User.currentUser!.friends! {
                friendNames.append(friend["name"]!)
            }
            
            self.dataSource = SimplePrefixQueryDataSource(friendNames)
            self.ramReel = RAMReel(frame: self.view.bounds, dataSource: self.dataSource, placeholder: "Start by typing…") {
                print("Selected:", $0)
                if let index = friendNames.indexOf(self.ramReel.selectedItem!) {
                    let selectedID = User.currentUser!.friends![index]["id"]!
                    if !self.selectedFriendIDs.contains(selectedID) {
                        self.selectedFriendIDs.append(selectedID)
                        self.selectedUsersLabel.text?.appendContentsOf($0 + "\n")
                        self.ramReel.prepareForReuse()
                    }
                    print(index)
                }
                print(self.selectedFriendIDs)
            }
            
            self.view.addSubview(self.ramReel.view)
            self.view.sendSubviewToBack(self.ramReel.view)
            self.ramReel.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreate(sender: AnyObject) {
        let navController = presentingViewController as! UINavigationController
        let feed = navController.topViewController as! FeedViewController
        self.dismissViewControllerAnimated(true) {
//            feed.createNewChat([self.userField.text!])
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
