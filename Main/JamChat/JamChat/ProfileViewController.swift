//
//  ProfileViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/18/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import KTCenterFlowLayout

class ProfileViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var numJamsLabel: UILabel!
    @IBOutlet weak var numTracksLabel: UILabel!
    
    @IBOutlet weak var friendsCollection: UICollectionView!
    @IBOutlet weak var instrumentCollection: UICollectionView!
    
    var userDelegate: UserCollectionDelegate!
    var instrumentDelegate: InstrumentCollectionDelegate!
    
    var jams: [Jam] = []
    
    var instrumentDic: [Instrument: Int] = [:]
    var instrumentNames: [Instrument] = []
    var topFriends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        topFriends = (User.currentUser?.getTopFriends())!
        
        instrumentDic = (User.currentUser?.instrumentCount)!
        
        for instrument in instrumentDic.keys {
            instrumentNames.append(instrument)
        }
        
        // Set up friends collection view:
        userDelegate = UserCollectionDelegate(users: topFriends)
        friendsCollection.dataSource = userDelegate
        friendsCollection.delegate = userDelegate
        friendsCollection.reloadData()
        
        let friendsLayout = KTCenterFlowLayout()
        friendsLayout.minimumInteritemSpacing = 20.0
        friendsLayout.itemSize = CGSizeMake(60, 70)
        friendsLayout.minimumLineSpacing = 0.0
        friendsCollection.collectionViewLayout = friendsLayout
        
        // Set up instrument collection view:
        instrumentDelegate = InstrumentCollectionDelegate(instruments: instrumentNames)
        instrumentCollection.dataSource = instrumentDelegate
        instrumentCollection.delegate = instrumentDelegate
        instrumentCollection.reloadData()
        
        let instrumentLayout = KTCenterFlowLayout()
        instrumentLayout.minimumInteritemSpacing = 20.0
        instrumentLayout.itemSize = CGSizeMake(60, 70)
        instrumentLayout.minimumLineSpacing = 0.0
        instrumentCollection.collectionViewLayout = instrumentLayout
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        setUpLabels(User.currentUser!)

    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Makes the profile picture views circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true;
        
        // format the text
        numJamsLabel.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        numTracksLabel.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
    }
    
    func setUpLabels(user: User) {
        
        // Sets the user's profile picture
        profilePicture.setImageWithURL(user.profileImageURL)
        
        // Sets the user's name
        userNameLabel.text = User.currentUser!.firstName + " " + User.currentUser!.lastName
        
        // Sets the number of jams user is a member of
        user.getNumberOfJams({ (count: Int) in
            var labelText = String(count)
            labelText += " Jams"
            self.numJamsLabel.text = labelText
        })
        
        // Sets the number of tracks the user has sent
        user.getNumberOfTracks({ (count: Int) in
            var labelText = String(count)
            labelText += " Tracks"
            self.numTracksLabel.text = labelText
        })

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

