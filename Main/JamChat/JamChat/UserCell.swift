//
//  UserCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/17/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AFNetworking

class UserCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!

    var user: User! {
        didSet {
            if let nameLabel = nameLabel {
                nameLabel.text = user.firstName
            }
            profilePictureView.setImageWithURL(user.profileImageURL)
        }
    }
    
    override func awakeFromNib() {
        // Make image circular:
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2;
        profilePictureView.clipsToBounds = true;
        
        if let button = countButton {
            button.layer.cornerRadius = countButton.frame.size.width / 2;
        }

        
        // download the tracks the user has created, if they haven't already been downloaded
        
        if user != nil {
            if user.tracks.count == 0 {
                user.getUserTracks(){
                    print("Loading user tracks")
                }
            }
        }
        
    }
    
    var numberIsDisplayed = false
    
    @IBAction func onUserTap(sender: AnyObject) {
        
        var friendsNames: [User] = []
        friendsNames = (user.getTopFriends())
        
        //retrieve the names of the top three friends
        if friendsNames.count > 3 {
            while(friendsNames.count > 3) {
                friendsNames.removeAtIndex(friendsNames.count-1)
            }
        }
        
        var topFriendsNum = user.getTopFriendNumbers()
        topFriendsNum.sortInPlace()
        var topThreeNums: [Int] = []
        
        //retrieves the number of jams from highest to lowest
        if (topFriendsNum.count == 1) {
            topThreeNums.append(topFriendsNum[0])
        } else if (topFriendsNum.count == 2) {
            topThreeNums.append(topFriendsNum[1])
            topThreeNums.append(topFriendsNum[0])
        } else {
            //retrieves the top three highest numbers
            for i in 1...3 {
                topThreeNums.append(topFriendsNum[topFriendsNum.count-i])
            }
        }

        //maps the number to the friend
        var index = 0
        for curUser in friendsNames {
            if curUser.name == self.user.name {
                break;
            }
            index += 1
        }
        
        self.countButton.backgroundColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
        self.countLabel.hidden = false
        self.countLabel.text = String(topThreeNums[index])
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {

            if self.numberIsDisplayed {
                self.countButton.backgroundColor = self.countButton.backgroundColor?.colorWithAlphaComponent(0.0)
                self.countLabel.hidden = true
                self.numberIsDisplayed = false
            } else {
                self.countButton.backgroundColor = self.countButton.backgroundColor?.colorWithAlphaComponent(1)
                self.countLabel.hidden = false
                self.numberIsDisplayed = true
            }
            
            }, completion: nil)
    }
    
    @IBAction func toProfileView(sender: AnyObject) {
        print("clicked user's name")
        
        
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: NSBundle.mainBundle())
        let profileViewController = profileStoryboard.instantiateViewControllerWithIdentifier("ProfileView") as! ProfileViewController
        
        profileViewController.user = self.user
        
        if user != nil {
            if user.friends.count == 0 {
                user.loadFriends({
                    var loadedCount = 0
                    for friend in self.user.friends {
                        friend.loadData() {
                            loadedCount += 1
                            print("Loading friend number \(loadedCount) of \(self.user.friends.count)")
                            if loadedCount == self.user.friends.count {
                                
                                PagerViewController.sharedInstance?.presentViewController(profileViewController, animated: true, completion: nil)
                            }
                        }
                    }
                })
            } else {
                
                PagerViewController.sharedInstance?.presentViewController(profileViewController, animated: true, completion: nil)
            }
        }

    }
    
}
