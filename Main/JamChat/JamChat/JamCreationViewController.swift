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

class JamCreationViewController: UIViewController, IndicatorInfoProvider {
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    var selectedFriendIDs: [String] = []
    
    @IBOutlet weak var selectedUsersLabel: UILabel!
    
    @IBOutlet weak var sliderView1: UIView!
    //@IBOutlet weak var valueLabel1: UILabel!
    
    @IBOutlet weak var setJamName: UITextField!
    
    // creates an interval slider
    private var intervalSlider1: IntervalSlider! {
        didSet {
            self.intervalSlider1.tag = 1
            self.sliderView1.addSubview(self.intervalSlider1)
            self.intervalSlider1.delegate = self
        }
    }
    
    // array with all the possible jam duration lengths (in seconds)
    private var data1: [Float] {
        return [5, 10, 15, 20]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up interval slider
        self.intervalSlider1 = IntervalSlider(frame: self.sliderView1.bounds, sources: self.createSources())
        
        initializeFriendPicker()
    }
    
    // formats the slider and the jam duration text
    private func createSources() -> [IntervalSliderSource] {
        
        // Sample of equally spaced intervals
        var sources = [IntervalSliderSource]()
        var appearanceValue: Float = 0.5
        
        for data in self.data1 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
            label.text = "\(Int(data))"
            label.font = UIFont.systemFontOfSize(CGFloat(12))
            label.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
            label.textAlignment = .Center
            let source = IntervalSliderSource(validValue: data, appearanceValue: appearanceValue, label: label)
            sources.append(source)
            
            // sets the spacing between the duration text
            appearanceValue += 33
        }
        return sources
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        PagerViewController.sharedInstance?.moveToViewControllerAtIndex(1, animated: true)
        let homeNavigation = PagerViewController.sharedInstance?.viewControllers[1] as! HomeNavigationController
        let home = homeNavigation.viewControllers[0] as! HomeViewController
       // let jamName = setJamName.text as! String
        home.addNewJam(Int(self.jamDurationSlider.value), userIDs: self.selectedFriendIDs, name: setJamName.text!)
        self.selectedFriendIDs = []
        self.selectedUsersLabel.text = ""
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
