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
    
    @IBInspectable var selectedColor: UIColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var numJamsLabel: UILabel!
    @IBOutlet weak var numTracksLabel: UILabel!
    
    @IBOutlet weak var friendsCollection: UICollectionView!
    @IBOutlet weak var instrumentCollection: UICollectionView!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var dismissProfileButton: UIButton!
    
    var user: User?
    
    var numTracks: Int!
    
    var userDelegate: UserCollectionDelegate!
    var instrumentDelegate: InstrumentCollectionDelegate!
    
    var jams: [Jam] = []
    
    var instrumentDic: [Instrument: Int] = [:]
    var instrumentNames: [Instrument] = []
    var topFriends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if user == nil {
            user = User.currentUser!
            dismissProfileButton.hidden = true
        } else {
            logoutButton.hidden = true
        }
        
        // Sets the user's profile picture
        profilePicture.setImageWithURL(user!.profileImageURL)
        
        // Sets the user's name
        userNameLabel.text = user!.firstName + " " + user!.lastName
        
        // Sets the number of jams user is a member of
        user!.getNumberOfJams({ (count: Int) in
            var labelText = String(count)
            labelText += " Jams"
            self.numJamsLabel.text = labelText
        })
        
        // Sets the number of tracks the user has sent
        user!.getNumberOfTracks({ (count: Int) in
            self.numTracks = count
            var labelText = String(count)
            labelText += " Tracks"
            self.numTracksLabel.text = labelText
        })
        
        // Goes through the user's tracks, and updates the instrumentCount array
        // The instrumentCount array is used to determine a user's "Favorite Instruments"
        
        // download the tracks the user has created, if they haven't already been downloaded
        if user!.tracks.count == 0 {
            user!.getUserTracks(){
                print("Loading user tracks")
                for track in self.user!.tracks {
                    for instrument in self.user!.instrumentCount.keys {
                        if let instrumentname = track.instrumentName {
                            if(instrument.name == instrumentname) {
                                var curNum = self.user!.instrumentCount[instrument]
                                curNum = curNum! + 1
                                self.user!.instrumentCount[instrument] = curNum
                            }
                        }
                    }
                }
            }
        }
        
        if user!.friends.count == 0 {
            user!.loadFriends({
                var loadedCount = 0
                for friend in self.user!.friends {
                    friend.loadData() {
                        loadedCount += 1
                        print("Loading friend number \(loadedCount) of \(self.user!.friends.count)")
                        if loadedCount == self.user!.friends.count {
                            
                            
                            for friend in self.user!.friends {
                                self.user!.friendCount[friend] = 0
                            }
                            
                            self.user?.getTopFriends({ (users: [User]) in
                                self.topFriends = users
                                
                                // retrieves the user's top three friends
                                if self.topFriends.count > 3 {
                                    while(self.topFriends.count > 3) {
                                        self.topFriends.removeAtIndex(self.topFriends.count-1)
                                    }
                                }
                                
                                // Set up friends collection view:
                                self.userDelegate = UserCollectionDelegate(users: self.topFriends, curUser: self.user!)
                                self.friendsCollection.dataSource = self.userDelegate
                                self.friendsCollection.delegate = self.userDelegate
                                self.friendsCollection.reloadData()
                            })

                        }
                    }
                }
            })
        }
        
        if user!.friends.count != 0 {
            for friend in self.user!.friends {
                self.user!.friendCount[friend] = 0
            }
            
            self.user?.getTopFriends({ (users: [User]) in
                self.topFriends = users
                
                // retrieves the user's top three friends
                if self.topFriends.count > 3 {
                    while(self.topFriends.count > 3) {
                        self.topFriends.removeAtIndex(self.topFriends.count-1)
                    }
                }
                
                // Set up friends collection view:
                self.userDelegate = UserCollectionDelegate(users: self.topFriends, curUser: self.user!)
                self.friendsCollection.dataSource = self.userDelegate
                self.friendsCollection.delegate = self.userDelegate
                self.friendsCollection.reloadData()
            })

        }
        
        
        // Makes the profile picture views circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
        profilePicture.clipsToBounds = true;
        
        // format the text
        numJamsLabel.textColor = selectedColor
        numTracksLabel.textColor = selectedColor
        
        // format logout button
        logoutButton.layer.cornerRadius = 7
        logoutButton.backgroundColor = UIColor.clearColor()
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = selectedColor.CGColor
        logoutButton.titleLabel!.textColor = selectedColor

        
        let friendsLayout = KTCenterFlowLayout()
        friendsLayout.minimumInteritemSpacing = 20.0
        friendsLayout.itemSize = CGSizeMake(60, 70)
        friendsLayout.minimumLineSpacing = 0.0
        friendsCollection.collectionViewLayout = friendsLayout
        

        let instrumentLayout = KTCenterFlowLayout()
        instrumentLayout.minimumInteritemSpacing = 20.0
        instrumentLayout.itemSize = CGSizeMake(60, 70)
        instrumentLayout.minimumLineSpacing = 0.0
        instrumentCollection.collectionViewLayout = instrumentLayout
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        setUpLabels()
    }
    
    func setUpLabels() {
        
        
        // retrieves the user's current instrument count
        instrumentDic = (user?.instrumentCount)!
        
        for instrument in instrumentDic.keys {
            instrumentNames.append(instrument)
        }
        
        // Set up instrument collection view:
        instrumentDelegate = InstrumentCollectionDelegate(instruments: instrumentNames, user: user!)
        instrumentCollection.dataSource = instrumentDelegate
        instrumentCollection.delegate = instrumentDelegate
        instrumentCollection.reloadData()

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
    
    @IBAction func onDismissProfile(sender: AnyObject) {
        print("dismiss profile clicked")
        dismissViewControllerAnimated(true, completion: nil)
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

