//
//  ChatCreationViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import RAMReel
import XLPagerTabStrip

class JamCreationViewController: UIViewController, IndicatorInfoProvider {
    
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
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "New")
    }
    
    func initializeFriendPicker() {
        
        var friendNames: [String] = []
        
        User.currentUser?.loadFriends({ 
            for friend in User.currentUser!.friends! {
                friendNames.append(friend["name"]!)
            }
            
            self.dataSource = SimplePrefixQueryDataSource(friendNames)
            self.ramReel = RAMReel(frame: self.view.bounds, dataSource: self.dataSource, placeholder: "Start by typing…") {
                if let index = friendNames.indexOf(self.ramReel.selectedItem!) {
                    let selectedID = User.currentUser!.friends![index]["id"]!
                    if !self.selectedFriendIDs.contains(selectedID) {
                        self.selectedFriendIDs.append(selectedID)
                        self.selectedUsersLabel.text?.appendContentsOf($0 + "\n")
                        print("Added friend to chat in creation: ", $0)
                        self.ramReel.prepareForReuse()
                    }
                } else {
                    print("Friend does not exist: ", $0)
                }
            }
            
            self.ramReel.theme = FriendSearchTheme()
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
        let home = navController.topViewController as! HomeViewController
        self.dismissViewControllerAnimated(true) {
            home.addNewJam(self.selectedFriendIDs)
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

struct FriendSearchTheme: Theme {
    let font: UIFont = UIFont(name: "Roboto", size: 30)!
    let listBackgroundColor: UIColor = UIColor.clearColor()
    let textColor: UIColor = UIColor.blackColor()
}
