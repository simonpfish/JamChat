//
//  ProfileViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/18/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DBProfileViewController

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
        var topInstruments = User.currentUser?.getTopInstrument()
        
        // Makes the profile picture views circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true;
        
        topFriend1View.layer.cornerRadius = topFriend1View.frame.size.width / 2;
        topFriend1View.clipsToBounds = true;
        
        topFriend2View.layer.cornerRadius = topFriend2View.frame.size.width / 2;
        topFriend2View.clipsToBounds = true;
        
        topFriend3View.layer.cornerRadius = topFriend3View.frame.size.width / 2;
        topFriend3View.clipsToBounds = true;
        
        // format the text
        topFriend1Label.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        topFriend2Label.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        topFriend3Label.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        numJamsLabel.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        numTracksLabel.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        
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
        
        // array of the current User's top three friends
        var topFriends = User.currentUser?.getTopFriends()
        
        var friend1Name: String = ""
        var friend2Name: String = ""
        var friend3Name: String = ""
        
        var friend1URL: NSURL = NSURL()
        var friend2URL: NSURL = NSURL()
        var friend3URL: NSURL = NSURL()
        
        if(topFriends!.count >= 3) {
            
            friend1Name = topFriends![0].firstName
            friend1URL = topFriends![0].profileImageURL
            
            topFriend1Label.text = friend1Name
            topFriend1View.setImageWithURL(friend1URL)
            
            friend2Name = topFriends![1].firstName
            friend2URL = topFriends![1].profileImageURL
            
            topFriend2Label.text = friend2Name
            topFriend2View.setImageWithURL(friend2URL)
            
            friend3Name = topFriends![2].firstName
            friend3URL = topFriends![2].profileImageURL
            
            topFriend3Label.text = friend3Name
            topFriend3View.setImageWithURL(friend3URL)
            
        } else if (topFriends!.count == 2) {
            
            friend1Name = topFriends![0].firstName
            friend1URL = topFriends![0].profileImageURL
            
            topFriend1Label.text = friend1Name
            topFriend1View.setImageWithURL(friend1URL)
            
            friend2Name = topFriends![1].firstName
            friend2URL = topFriends![1].profileImageURL
            
            topFriend2Label.text = friend2Name
            topFriend2View.setImageWithURL(friend2URL)
            
        } else if (topFriends!.count == 1) {
            
            friend1Name = topFriends![0].firstName
            friend1URL = topFriends![0].profileImageURL
            
            topFriend1Label.text = friend1Name
            topFriend1View.setImageWithURL(friend1URL)
        }
        
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

