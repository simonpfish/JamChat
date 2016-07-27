//
//  JamCreationViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import RAMReel
import XLPagerTabStrip
import IntervalSlider
import BAPulseView
import GMStepper

class JamCreationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, IndicatorInfoProvider, UITextFieldDelegate {
    
    @IBInspectable var selectedColor: UIColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
    
    var selectedFriendIDs: [String] = []
    
    var tempo: Int = 110
    var timer = NSTimer()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var keyboardDismissView: UIView!
    
    @IBOutlet weak var stepperView: GMStepper!
    @IBOutlet weak var jamLengthLabel: UILabel!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var resultSearchController = UISearchController()
    
    @IBOutlet weak var titleLabel: UITextField!
    
    @IBOutlet weak var slowTempoView: BAPulseView!
    @IBOutlet weak var mediumTempoView: BAPulseView!
    @IBOutlet weak var fastTempoView: BAPulseView!
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var fastLabel: UILabel!
    
    @IBOutlet weak var createButton: UIButton!
    
    var titleGenerator: [String] = []
    
    // stores the friends who match the user's search
    var filtered: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // formats jam duration stepper
        //updateStepperValues(17, min: 8, max: 26, stepper: 9)
        
        stepperView.buttonsBackgroundColor = selectedColor
        stepperView.labelBackgroundColor = UIColor(red: 249/255, green: 194/255, blue: 97/255, alpha: 1.0)
        stepperView.limitHitAnimationColor = UIColor.redColor()
        
        // format create button
        createButton.layer.cornerRadius = 7
        createButton.backgroundColor = selectedColor
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = selectedColor.CGColor
        
        // set up the search bar
        searchBar.delegate = self
        
        // set up the table view
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = true
        
        // read in a text file of random jam titles and store it in an array
        let path = NSBundle.mainBundle().pathForResource("jamNames", ofType: "txt")
        let jamTitles = try! String(contentsOfFile: path!)
        titleGenerator = jamTitles.componentsSeparatedByString("\n")
        
        
        //sets up tempo buttons
        setTempoButtons()
        
        // download the current user's friends, if they haven't already been downloaded
        if User.currentUser!.friends.count == 0 {
            print("loading friends")
            User.currentUser?.loadFriends({
                var loadedCount = 0
                for friend in User.currentUser!.friends {
                    friend.loadData() {
                        loadedCount += 1
                        print("Loading friend number \(loadedCount) of \(User.currentUser!.friends.count)")
                        if loadedCount == User.currentUser?.friends.count {
                            print("reloading table view")
                            // sets up the table view with the user's friends
                            for friend in User.currentUser!.friends {
                                self.filtered.append(friend)
                            }
                            self.collectionView.reloadData()
                        }
                    }
                }
            })
        } else {
            
            // if the friends have already been downloaded
            
            for friend in User.currentUser!.friends {
                self.filtered.append(friend)
            }
            self.collectionView.reloadData()
        }
        
        //adds tap to dismiss keyboard
        let dismissTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JamCreationViewController.dismissKeyboard))
        keyboardDismissView.addGestureRecognizer(dismissTap)
        titleLabel.delegate = self
        titleLabel.returnKeyType = .Done
        
        onMedium(nil)
    }
    
    
    // updates stepper values
    func updateStepperValues(defaultValue: Double, min: Double, max: Double, stepper: Double) {
        stepperView.value = defaultValue
        stepperView.minimumValue = min
        stepperView.maximumValue = max
        stepperView.stepValue = stepper
    }
    
    //updates jam time label
    func updateJamTime(){
        //let duration = Int(60.0/Double(tempo)*4.0*Double(messageDurationSlider.getValue()))
        let duration = Int(60.0/Double(tempo)*4.0*Double(0))
    }
    
    func setTempoButtons(){
        slowTempoView.layer.cornerRadius = slowTempoView.bounds.width * 0.5
        slowTempoView.clipsToBounds = true
        slowTempoView.backgroundColor = selectedColor
        let slowTap = UITapGestureRecognizer(target: self, action: #selector(JamCreationViewController.onSlow(_:)))
        slowTempoView.addGestureRecognizer(slowTap)
        
        mediumTempoView.layer.cornerRadius = mediumTempoView.bounds.width * 0.5
        mediumTempoView.clipsToBounds = true
        mediumTempoView.backgroundColor = selectedColor
        let mediumTap = UITapGestureRecognizer(target: self, action: #selector(JamCreationViewController.onMedium(_:)))
        mediumTempoView.addGestureRecognizer(mediumTap)
        
        fastTempoView.layer.cornerRadius = fastTempoView.bounds.width * 0.5
        fastTempoView.clipsToBounds = true
        fastTempoView.backgroundColor = selectedColor
        let fastTap = UITapGestureRecognizer(target: self, action: #selector(JamCreationViewController.onFast(_:)))
        fastTempoView.addGestureRecognizer(fastTap)
    }
    
    func onSlow (sender: UITapGestureRecognizer?){
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60/80, target: slowTempoView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
        tempo = 80
        
        // modify tempo labels when selected
        slowLabel.textColor = UIColor.whiteColor()
        mediumLabel.textColor = UIColor.whiteColor()
        fastLabel.textColor = UIColor.whiteColor()
        
        slowLabel.font = UIFont.boldSystemFontOfSize(13.0)
        mediumLabel.font = UIFont.systemFontOfSize(13.0)
        fastLabel.font = UIFont.systemFontOfSize(13.0)
        
        updateStepperValues(24, min: 12, max: 36, stepper: 12)
        updateStepperValues(24, min: 12, max: 36, stepper: 12)
        
        updateJamTime()
    }
    
    func onMedium (sender: UITapGestureRecognizer?){
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60/110, target: mediumTempoView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
        tempo = 110
        
        // modify tempo labels when selected
        slowLabel.textColor = UIColor.whiteColor()
        mediumLabel.textColor = UIColor.whiteColor()
        fastLabel.textColor = UIColor.whiteColor()
        
        slowLabel.font = UIFont.systemFontOfSize(13.0)
        mediumLabel.font = UIFont.boldSystemFontOfSize(13.0)
        fastLabel.font = UIFont.systemFontOfSize(13.0)
        
        updateStepperValues(17, min: 8, max: 26, stepper: 9)
        updateStepperValues(17, min: 8, max: 26, stepper: 9)
        
        updateJamTime()
    }
    
    func onFast (sender: UITapGestureRecognizer?){
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60/140, target: fastTempoView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
        tempo = 140
        
        // modify tempo labels when selected
        slowLabel.textColor = UIColor.whiteColor()
        mediumLabel.textColor = UIColor.whiteColor()
        fastLabel.textColor = UIColor.whiteColor()
        
        slowLabel.font = UIFont.systemFontOfSize(13.0)
        mediumLabel.font = UIFont.systemFontOfSize(13.0)
        fastLabel.font = UIFont.boldSystemFontOfSize(13.0)
        
        updateStepperValues(13, min: 6, max: 20, stepper: 7)
        updateStepperValues(13, min: 6, max: 20, stepper: 7)
        
        updateJamTime()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filtered.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = ((User.currentUser?.friends)! as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filtered = array as! [User]
        self.collectionView.reloadData()
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filtered = (User.currentUser?.friends)!
        } else {
            filtered = ((User.currentUser?.friends)!).filter({(dataItem: User) -> Bool in
                // If dataItem matches the searchText, return true to include it
                let title = dataItem.name
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
            
        }

        collectionView.reloadData()
    }
    
    // Show cancel button on search bar when being used
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    // Clear search bar when cancel is hit
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
        filtered = (User.currentUser?.friends)!
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        cell.user = filtered[indexPath.row]
        return cell
    }

    
    /**
     Highlights a selected cell
     */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! FriendCell
        currentCell.backgroundColor = UIColor.lightGrayColor()
        
        let selectedFriend = currentCell.nameLabel.text
        
        // Loops through all of the user's friends
        for friend in (User.currentUser?.friends)! {
            
            // Finds the selected friend
            if friend.name == selectedFriend {
                let selectedID = friend.facebookID
                
                // Adds the selected friend to an array of selected friends
                if !self.selectedFriendIDs.contains(selectedID) {
                    self.selectedFriendIDs.append(selectedID)
                    print("Added friend to chat in creation: \(friend.firstName)")
                } else {
                    print("Friend does not exist: \(friend.firstName)")
                }
            }
        }
    }
    
    
    /**
     Unhighlights and removes a check mark from an unselected cell
     */
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let currentCell = collectionView.cellForItemAtIndexPath(indexPath) as! FriendCell
        currentCell.backgroundColor = UIColor.whiteColor()
        
        self.selectedFriendIDs.removeAtIndex(selectedFriendIDs.indexOf(currentCell.user.facebookID)!)
        
        print("Removed friend from chat in creation: \(currentCell.nameLabel.text!)")
    }
    
    @IBAction func onCreate(sender: AnyObject) {
        
        // if the user does not enter a Jam Title, use the randomly generated one
        if(titleLabel.text == "") {
            self.titleLabel.text = self.titleLabel.placeholder
        }
        
        PagerViewController.sharedInstance?.moveToViewControllerAtIndex(1, animated: true)
        let homeNavigation = PagerViewController.sharedInstance?.viewControllers[1] as! HomeNavigationController
        let home = homeNavigation.viewControllers[0] as! HomeViewController
//        home.addNewJam(Double(totaltime.text!)!, userIDs: self.selectedFriendIDs, name: titleLabel.text!, tempo: tempo)
        home.addNewJam(Double(0), userIDs: self.selectedFriendIDs, name: titleLabel.text!, tempo: tempo)

        self.selectedFriendIDs = []
        self.titleLabel.text = ""
        
        slowLabel.textColor = selectedColor
        mediumLabel.textColor = UIColor.darkGrayColor()
        fastLabel.textColor = UIColor.darkGrayColor()
        
        slowLabel.font = UIFont.boldSystemFontOfSize(13.0)
        mediumLabel.font = UIFont.systemFontOfSize(13.0)
        fastLabel.font = UIFont.systemFontOfSize(13.0)
                
        // unselects previously selected friends from the table view
        let paths = self.collectionView.indexPathsForSelectedItems() ?? []
        for path in paths {
            collectionView.deselectItemAtIndexPath(path, animated: false)
            //collectionView.cellForItemAtIndexPath(path)?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        onMedium(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let randomNumber = arc4random_uniform(UInt32(titleGenerator.count))
        self.titleLabel.placeholder = titleGenerator[Int(randomNumber)]
        
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "New")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //dismisses keyboard on "Done"
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleLabel.resignFirstResponder()
        return true
    }
    
    //dismisses keyboard on tap
    func dismissKeyboard() {
        view.endEditing(true)
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
