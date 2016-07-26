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

class JamCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, IndicatorInfoProvider {
    
    @IBInspectable var selectedColor: UIColor = UIColor(red: 247/255, green: 148/255, blue: 0/255, alpha: 1.0)
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    var selectedFriendIDs: [String] = []
    var tempo: Int = 80
    var timer = NSTimer()
    
    @IBOutlet weak var totaltime: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    var resultSearchController = UISearchController()
    
    @IBOutlet weak var durationSliderView: UIView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var slowTempoView: BAPulseView!
    @IBOutlet weak var mediumTempoView: BAPulseView!
    @IBOutlet weak var fastTempoView: BAPulseView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var fastLabel: UILabel!
    
    
    var titleGenerator: [String] = []
    
    // stores the friends who match the user's search
    var filtered: [User] = []
    
    // creates an interval slider
    private var messageDurationSlider: IntervalSlider! {
        didSet {
            self.messageDurationSlider.tag = 1
            self.durationSliderView.addSubview(self.messageDurationSlider)
            self.messageDurationSlider.delegate = self
        }
    }
    
    // array with all the possible jam duration lengths (in seconds)
    private var messageDurationValues: [Float] {
        return [4, 8, 12, 16]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // format create button
        createButton.layer.cornerRadius = 7
        createButton.backgroundColor = UIColor.clearColor()
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = selectedColor.CGColor
        createButton.titleLabel!.textColor = selectedColor
        
        // set up the search bar
        searchBar.delegate = self
        
        // set up the table view
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.allowsMultipleSelection = true
        
        // read in a text file of random jam titles and store it in an array
        let path = NSBundle.mainBundle().pathForResource("jamNames", ofType: "txt")
        let jamTitles = try! String(contentsOfFile: path!)
        titleGenerator = jamTitles.componentsSeparatedByString("\n")
        
        // set up interval slider
        let result = self.createSources()
        self.messageDurationSlider = IntervalSlider(frame: self.durationSliderView.bounds, sources: result.sources, options: result.options)
        
        //sets up tempo buttons
        setTempoButtons()
        
        totaltime.text = ""

        // sets up the table view with the user's friends
        for friend in User.currentUser!.friends {
            self.filtered.append(friend)
        }
        
        self.tableView.reloadData()

    }
    
    //updates jam time label
    func updateJamTime(){
        let duration = Int(60.0/Double(tempo)*4.0*Double(messageDurationSlider.getValue()))
        totaltime.text = "\(duration)"
    }
    
    func setTempoButtons (){
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
    
    func onSlow (sender: UITapGestureRecognizer){
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60/80, target: slowTempoView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
        tempo = 80
        
        // modify tempo labels when selected
        slowLabel.textColor = selectedColor
        mediumLabel.textColor = UIColor.darkGrayColor()
        fastLabel.textColor = UIColor.darkGrayColor()
        
        slowLabel.font = UIFont.boldSystemFontOfSize(13.0)
        mediumLabel.font = UIFont.systemFontOfSize(13.0)
        fastLabel.font = UIFont.systemFontOfSize(13.0)

        
        updateJamTime()
    }
    
    func onMedium (sender: UITapGestureRecognizer){
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60/110, target: mediumTempoView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
        tempo = 110
        
        // modify tempo labels when selected
        slowLabel.textColor = UIColor.darkGrayColor()
        mediumLabel.textColor = selectedColor
        fastLabel.textColor = UIColor.darkGrayColor()
        
        slowLabel.font = UIFont.systemFontOfSize(13.0)
        mediumLabel.font = UIFont.boldSystemFontOfSize(13.0)
        fastLabel.font = UIFont.systemFontOfSize(13.0)

        
        updateJamTime()
    }
    
    func onFast (sender: UITapGestureRecognizer){
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60/140, target: fastTempoView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
        tempo = 140
        
        // modify tempo labels when selected
        slowLabel.textColor = UIColor.darkGrayColor()
        mediumLabel.textColor = UIColor.darkGrayColor()
        fastLabel.textColor = selectedColor
        
        slowLabel.font = UIFont.systemFontOfSize(13.0)
        mediumLabel.font = UIFont.systemFontOfSize(13.0)
        fastLabel.font = UIFont.boldSystemFontOfSize(13.0)
        
        updateJamTime()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filtered.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = ((User.currentUser?.friends)! as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filtered = array as! [User]
        self.tableView.reloadData()
        
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

        tableView.reloadData()
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
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return User.currentUser?.friends.count ?? 0
        return filtered.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendCell
        //cell.user = User.currentUser?.friends[indexPath.row]
        cell.user = filtered[indexPath.row]
        return cell
    }
    
    /**
     Highlights and added a check mark to a selected cell
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! FriendCell
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
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! FriendCell
        
        self.selectedFriendIDs.removeAtIndex(selectedFriendIDs.indexOf(currentCell.user.facebookID)!)

        print("Removed friend from chat in creation: \(currentCell.nameLabel.text!)")
    }
    
    // formats the slider and the jam duration text
    private func createSources() -> (sources: [IntervalSliderSource], options: [IntervalSliderOption]) {
        
        // Sample of equally spaced intervals
        var sources = [IntervalSliderSource]()
        var appearanceValue: Float = 0.5
        
        for data in self.messageDurationValues {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
            label.text = "\(Int(data))"
            label.font = UIFont.systemFontOfSize(CGFloat(12))
            label.textColor = selectedColor
            label.textAlignment = .Center
            let source = IntervalSliderSource(validValue: data, appearanceValue: appearanceValue, label: label)
            sources.append(source)
            
            // sets the spacing between the duration text
            appearanceValue += 33
        }
        
        // image used for the thumb image on the interval slider
        let thumbView = UIView(frame: CGRectMake(0, 0 , 20, 20))
        thumbView.backgroundColor = UIColor.lightGrayColor()
        thumbView.layer.cornerRadius = thumbView.bounds.width * 0.5
        thumbView.clipsToBounds = true
        let image = imageFromViewWithCornerRadius(thumbView)
        
        // sets the track tint color and the thumb image
        let options: [IntervalSliderOption] = [
            .MinimumTrackTintColor(selectedColor),
            .ThumbImage(image)
        ]
        
        return (sources, options)
    }
    
    func imageFromViewWithCornerRadius(view: UIView) -> UIImage {
        // maskImage
        let imageBounds = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
        let path = UIBezierPath(roundedRect: imageBounds, cornerRadius: view.bounds.size.width * 0.5)
        UIGraphicsBeginImageContextWithOptions(path.bounds.size, false, 0)
        view.backgroundColor?.setFill()
        path.fill()
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // drawImage
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextClipToMask(context, imageBounds, maskImage.CGImage)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image;
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
    
    @IBAction func onCreate(sender: AnyObject) {
        
        // if the user does not enter a Jam Title, use the randomly generated one
        if(titleLabel.text == "") {
            self.titleLabel.text = self.titleLabel.placeholder
        }
        
        PagerViewController.sharedInstance?.moveToViewControllerAtIndex(1, animated: true)
        let homeNavigation = PagerViewController.sharedInstance?.viewControllers[1] as! HomeNavigationController
        let home = homeNavigation.viewControllers[0] as! HomeViewController
        home.addNewJam(Double(totaltime.text!)!, userIDs: self.selectedFriendIDs, name: titleLabel.text!, tempo: tempo)
        self.selectedFriendIDs = []
        self.titleLabel.text = ""
        
        self.totaltime.text = ""
        
        slowLabel.textColor = UIColor.darkGrayColor()
        mediumLabel.textColor = UIColor.darkGrayColor()
        fastLabel.textColor = UIColor.darkGrayColor()
        
        slowLabel.font = UIFont.systemFontOfSize(13.0)
        mediumLabel.font = UIFont.systemFontOfSize(13.0)
        fastLabel.font = UIFont.systemFontOfSize(13.0)
        
        timer.invalidate()
        
        // unselects previously selected friends from the table view
        let paths = self.tableView.indexPathsForSelectedRows ?? []
        for path in paths {
            tableView.deselectRowAtIndexPath(path, animated: false)
            tableView.cellForRowAtIndexPath(path)?.accessoryType = UITableViewCellAccessoryType.None
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

extension JamCreationViewController: IntervalSliderDelegate {
    func confirmValue(slider: IntervalSlider, validValue: Float) {
        updateJamTime()
        switch slider.tag {
        //case 1:
            //self.valueLabel1.text = "\(Int(validValue))"
        default:
            break
        }
    }
}

struct FriendSearchTheme: Theme {
    let font: UIFont = UIFont(name: "Roboto", size: 30)!
    let listBackgroundColor: UIColor = UIColor.clearColor()
    let textColor: UIColor = UIColor.blackColor()
}