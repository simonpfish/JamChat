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

class JamCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    var selectedFriendIDs: [String] = []
    var intTempo = Int ()
    var currentTempo: UILabel!
    var timer = NSTimer()
    
    @IBOutlet weak var selectedUsersLabel: UILabel!
    @IBOutlet weak var sliderView1: UIView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var tempoSliderView: UIView!
    @IBOutlet weak var minTempo: UILabel!
    @IBOutlet weak var maxTempo: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var tempoPulseView: BAPulseView!

    @IBOutlet weak var tableView: UITableView!
    
    var titleGenerator: [String] = []
    
    // creates an interval slider
    private var messageDurationSlider: IntervalSlider! {
        didSet {
            self.messageDurationSlider.tag = 1
            self.sliderView1.addSubview(self.messageDurationSlider)
            self.messageDurationSlider.delegate = self
        }
    }
    
    // array with all the possible jam duration lengths (in seconds)
    private var messageDurationValues: [Float] {
        return [5, 10, 15, 20]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // need to make it so all friends appear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // read in a text file of random jam titles and store it in an array
        let path = NSBundle.mainBundle().pathForResource("jamNames", ofType: "txt")
        let jamTitles = try! String(contentsOfFile: path!)
        titleGenerator = jamTitles.componentsSeparatedByString("\n")
        
        // set up interval slider
        let result = self.createSources()
        self.messageDurationSlider = IntervalSlider(frame: self.sliderView1.bounds, sources: result.sources, options: result.options)
        
        setTempoSlider()
        
        User.currentUser?.loadFriends({
            var loadedCount = 0
            for friend in User.currentUser!.friends {
                friend.loadData() {
                    loadedCount += 1
                    if loadedCount == User.currentUser?.friends.count {
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
//        initializeFriendPicker()
        
        setPulse()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.currentUser?.friends.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendCell
        cell.user = User.currentUser?.friends[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if(selectedCell.contentView.backgroundColor == UIColor.lightGrayColor()) {
            selectedCell.contentView.backgroundColor = UIColor.whiteColor()
        } else {
            selectedCell.contentView.backgroundColor = UIColor.lightGrayColor()
        }
        
    }
    
    //creates pulse effect for tempo
    func setPulse(){
        
        tempoPulseView.layer.cornerRadius = tempoPulseView.frame.size.width/2
        let floatWidth = Float(tempoPulseView.frame.size.width)
        tempoPulseView.pulseCornerRadius = floatWidth/2
        tempoPulseView.backgroundColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        
        currentTempo = UILabel(frame: CGRectMake(view.frame.origin.x, view.frame.origin.y, tempoPulseView.frame.width-1, tempoPulseView.frame.height-1))
        currentTempo.textAlignment = NSTextAlignment.Center
        currentTempo.text = "80"
        currentTempo.font = currentTempo.font.fontWithSize(12)
        currentTempo.textColor = UIColor.whiteColor()
        tempoPulseView.addSubview(currentTempo)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(tempoSlider.value/60), target: tempoPulseView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
    }
    
    func setTempoSlider () {
        
        let thumbView = UIView(frame: CGRectMake(0, 0 , 20, 20))
        thumbView.backgroundColor = UIColor.lightGrayColor()
        thumbView.layer.cornerRadius = thumbView.bounds.width * 0.5
        thumbView.clipsToBounds = true
        let image = imageFromViewWithCornerRadius(thumbView)
        
        tempoSlider.setThumbImage(image, forState: .Normal)
        tempoSlider.setThumbImage(image, forState: .Selected)
        tempoSlider.setThumbImage(image, forState: .Application)
        tempoSlider.setThumbImage(image, forState: .Highlighted)
        
        tempoSlider.minimumValue = 80
        tempoSlider.maximumValue = 180
        tempoSlider.continuous = true
        tempoSlider.tintColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        tempoSlider.value = 80
        tempoSlider.addTarget(self, action: #selector(JamCreationViewController.tempoValueDidChange(_:)), forControlEvents: .ValueChanged)
        maxTempo.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        minTempo.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        minTempo.text = "\(80)"
        maxTempo.text = "\(180)"
        intTempo = 80
    }
    
    //Changes displayed tempo with slider change
    func tempoValueDidChange(sender: UISlider){
        intTempo = Int(tempoSlider.value)
        currentTempo.text = "\(intTempo)"
      timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(60/tempoSlider.value), target: tempoPulseView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
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
            label.textColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
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
            .MinimumTrackTintColor(UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)),
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
    
//    func initializeFriendPicker() {
//        
//        var friendNames: [String] = []
//        
//        User.currentUser?.loadFriends({ 
//            for friend in User.currentUser!.friends! {
//                friendNames.append(friend["name"]!)
//            }
//            
//            self.dataSource = SimplePrefixQueryDataSource(friendNames)
//            self.ramReel = RAMReel(frame: self.view.bounds, dataSource: self.dataSource, placeholder: "Start by typing…") {
//                if let index = friendNames.indexOf(self.ramReel.selectedItem!) {
//                    let selectedID = User.currentUser!.friends![index]["id"]!
//                    if !self.selectedFriendIDs.contains(selectedID) {
//                        self.selectedFriendIDs.append(selectedID)
//                        self.selectedUsersLabel.text?.appendContentsOf($0 + "\n")
//                        print("Added friend to chat in creation: ", $0)
//                        self.ramReel.prepareForReuse()
//                    }
//                } else {
//                    print("Friend does not exist: ", $0)
//                }
//            }
//            
//            self.ramReel.theme = FriendSearchTheme()
//            self.view.addSubview(self.ramReel.view)
//            self.view.sendSubviewToBack(self.ramReel.view)
//            self.ramReel.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        })
//        
//    }

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
        home.addNewJam(Double(messageDurationSlider.getValue()), userIDs: self.selectedFriendIDs, name: titleLabel.text!, tempo: intTempo)
        self.selectedFriendIDs = []
        self.selectedUsersLabel.text = ""
        self.titleLabel.text = ""
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