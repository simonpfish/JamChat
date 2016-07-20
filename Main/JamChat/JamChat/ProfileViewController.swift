//
//  ProfileViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/18/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProfileViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var numJamsLabel: UILabel!
    @IBOutlet weak var numTracksLabel: UILabel!
    
    @IBOutlet weak var topFriend1View: UIImageView!
    @IBOutlet weak var topFriend2View: UIImageView!
    @IBOutlet weak var topFriend3View: UIImageView!
    
    @IBOutlet weak var topFriend1Label: UILabel!
    @IBOutlet weak var topFriend2Label: UILabel!
    @IBOutlet weak var topFriend3Label: UILabel!
    
    
    
    var jams: [Jam] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Makes the profile picture views circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true;
        
        topFriend1View.layer.cornerRadius = topFriend1View.frame.size.width / 2;
        topFriend1View.clipsToBounds = true;
        
        topFriend2View.layer.cornerRadius = topFriend2View.frame.size.width / 2;
        topFriend2View.clipsToBounds = true;
        
        topFriend3View.layer.cornerRadius = topFriend3View.frame.size.width / 2;
        topFriend3View.clipsToBounds = true;
        
        // Sets the user's profile picture
        profilePicture.setImageWithURL(User.currentUser!.profileImageURL)
        
        // Sets the user's name
        userNameLabel.text = User.currentUser!.firstName + " " + User.currentUser!.lastName
        
        // Sets the number of jams user is a member of
        User.currentUser?.getNumberOfJams({ (count: Int) in
            self.numJamsLabel.text = String(count)
        })
        
        // Sets the number of tracks the user has sent
        User.currentUser?.getNumberOfTracks({ (count: Int) in
            self.numTracksLabel.text = String(count)
        })
        
        var topFriends = User.currentUser?.getTopFriends()
        
//        var friend1, friend2, friend3: User
//        
//        if(topFriends.count >= 3) {
//            friend1 = topFriends[0]
//            friend2 = topFriends[1]
//            friend3 = topFriends[2]
//        } else if (topFriends.count == 2) {
//            friend1 = topFriends[0]
//            friend2 = topFriends[1]
//        } else if (topFriends.count == 1) {
//            friend1 = topFriends[0]
//        }
//        
//        if friend1.firstName == nil {
//            
//        } else if friend2.firstName == nil {
//            topFriend1Label.text = topFriends![0]
//            topFriend1View.setImageWithURL(topFriends![0].profileImageURL)
//            
//        } else if friend3.firstName == nil {
//            topFriend1Label.text = topFriends![0]
//            topFriend1View.setImageWithURL(topFriends![0].profileImageURL)
//            
//            topFriend2Label.text = topFriends![1]
//            topFriend2View.setImageWithURL(topFriends![1].profileImageURL)
//            
//        } else {
//            topFriend1Label.text = topFriends![0]
//            topFriend1View.setImageWithURL(topFriends![0].profileImageURL)
//            
//            topFriend2Label.text = topFriends![1]
//            topFriend2View.setImageWithURL(topFriends![1].profileImageURL)
//            
//            topFriend3Label.text = topFriends![2]
//            topFriend3View.setImageWithURL(topFriends![2].profileImageURL)
//            
//        }
        
        topFriend1Label.text = topFriends![0]
        topFriend2Label.text = topFriends![1]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        PagerViewController.sharedInstance?.moveToViewControllerAtIndex(1, animated: false)
        let homeNavigation = PagerViewController.sharedInstance?.viewControllers[1] as! HomeNavigationController
        let home = homeNavigation.viewControllers[0] as! HomeViewController
        User.logout()
        User.login(home, success: {
            home.loadFeed()
        }) { (error: NSError?) in
            print(error?.localizedDescription)
        }
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profile")
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

