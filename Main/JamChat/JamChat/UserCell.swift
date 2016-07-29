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

    var curUser: User!
    
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
        
        var num = 0
        
        // if the user's friends have not been counted, count them
        if curUser.friends.count == 0 {
            curUser.loadFriends({
                var loadedCount = 0
                for friend in self.curUser.friends {
                    friend.loadData() {
                        loadedCount += 1
                        print("Loading friend number \(loadedCount) of \(self.curUser.friends.count)")
                        if loadedCount == self.curUser.friends.count {
                            
                            var friendNum: [User : Int] = [:]
                            friendNum = (self.curUser.friendCount)
                            
                            for curFriend in friendNum.keys {
                                if curFriend.facebookID == self.user!.facebookID {
                                    num = friendNum[curFriend]!
                                }
                            }
                        }
                    }
                }
            })
        } else {
            
            //if the user's friends have already been counted
            
            var friendNum: [User : Int] = [:]
            friendNum = (curUser.friendCount)
            
            for curFriend in friendNum.keys {
                if curFriend.facebookID == user!.facebookID {
                    num = friendNum[curFriend]!
                }
            }
        }

        
        self.countButton.backgroundColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
        self.countLabel.hidden = false
        self.countLabel.text = String(num)
        
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
            
            // reverts back to the friend's image after 3 seconds, if the count label is still showing
            self.delay(3.0, closure: {
                
                if self.numberIsDisplayed {
                    self.countButton.backgroundColor = self.countButton.backgroundColor?.colorWithAlphaComponent(0.0)
                    self.countLabel.hidden = true
                    self.numberIsDisplayed = false
                    
                }
                
            })
            
            }, completion: nil)
        
    }
    
    @IBAction func toProfileView(sender: AnyObject) {
        print("clicked user's name")
        
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: NSBundle.mainBundle())
        let profileViewController = profileStoryboard.instantiateViewControllerWithIdentifier("ProfileView") as! ProfileViewController
        
        profileViewController.user = self.user
        
        // load the user's friends if they have not already been loaded
        if user != nil {
            if user.friends.count == 0 {
                user.loadFriends({
                    var loadedCount = 0
                    for friend in self.user.friends {
                        friend.loadData() {
                            loadedCount += 1
                            print("Loading friend number \(loadedCount) of \(self.user.friends.count)")
                            if loadedCount == self.user.friends.count {
                                
                                // display the user's profile after the user's friends have been loaded
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
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
}
