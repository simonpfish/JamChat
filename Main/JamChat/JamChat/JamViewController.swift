//
//  JamViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/14/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import KTCenterFlowLayout
import FDWaveformView
import AudioKit
import CircleMenu
import NVActivityIndicatorView
import BAPulseView

class JamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, CircleMenuDelegate {

    var jam: Jam!
    var tempoTimer = NSTimer()
    var countdownTimer = NSTimer()
    var countdown: Int = 4
    
    @IBInspectable var loadingColor: UIColor = UIColor.grayColor()
    
    @IBOutlet weak var progressIndicator: UIView!
    @IBOutlet weak var keyboardContainer: UIView!
    @IBOutlet weak var jamNameLabel: UILabel!
    @IBOutlet weak var userCollection: UICollectionView!
    @IBOutlet weak var waveformContainer: UIView!
    @IBOutlet weak var keyboardButton: CircleMenu!
    @IBOutlet weak var loadingIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var recordView: BAPulseView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardButton.delegate = self
        keyboardButton.layer.cornerRadius = keyboardButton.frame.size.width / 2.0
        keyboardButton.setImage(UIImage(named: "icon_menu"), forState: .Normal)
        keyboardButton.setImage(UIImage(named: "icon_close"), forState: .Selected)
        
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.type = .LineScaleParty
        loadingIndicatorView.color = loadingColor
        
        progressIndicator.layer.cornerRadius = progressIndicator.frame.width/2

        // Set up user collection view:
        userCollection.dataSource = self
        userCollection.delegate = self
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 5.0
        layout.itemSize = CGSizeMake(60, 70)
        layout.minimumLineSpacing = 0.0
        userCollection.collectionViewLayout = layout
        jamNameLabel.text = jam.title
        
        //Creates recording view
        recordView.layer.cornerRadius = recordView.frame.size.width/2
        let floatWidth = Float(recordView.frame.size.width)
        recordView.pulseCornerRadius = floatWidth/2
        recordView.backgroundColor = UIColor(red: 1, green: 0, blue: 0.298, alpha: 1.0)
        recordView.pulseStrokeColor = UIColor(red: 0.9569, green: 0.4471, blue: 0, alpha: 1.0).CGColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(JamViewController.onRecord(_:)))
        tap.delegate = self
        recordView.addGestureRecognizer(tap)

        drawWaveforms()
    }

    func drawWaveforms() {
        if let lastMessage = jam.messages.last {
            loadingIndicatorView.startAnimation()
            lastMessage.loadTracks({
                for track in (lastMessage.tracks) {
                    if let filepath = track.filepath {
                        
                        let fileURL = NSURL(fileURLWithPath: filepath)
                        
                        let waveformView = FDWaveformView(frame: self.waveformContainer.frame)
                        
                        waveformView.frame.origin.y = 0
                        waveformView.audioURL = fileURL
                        waveformView.doesAllowScrubbing = false
                        waveformView.doesAllowScroll = false
                        waveformView.doesAllowStretch = false
                        waveformView.wavesColor = track.color.colorWithAlphaComponent(0.6)
                        
                        self.waveformContainer.addSubview(waveformView)
                    }
                }
                self.loadingIndicatorView.stopAnimation()
                let keyboardController = self.childViewControllers[0] as! KeyboardViewController
                keyboardController.instrument.reload()
                
                let waveTap = UITapGestureRecognizer(target: self, action: #selector(JamViewController.onPlay(_:)))
                self.waveformContainer.subviews.last!.addGestureRecognizer(waveTap)
                
                self.waveformContainer.bringSubviewToFront(self.progressIndicator)
            })

        }
    }
    
    //Plays chat when wave is tapped
    func onPlay(sender: UITapGestureRecognizer? = nil) {
        let lastMessage = jam.messages.last
        lastMessage?.loadTracks({
            lastMessage?.play({ 
                UIView.animateWithDuration(self.jam.messageDuration, delay: 0.0, options: [.CurveLinear], animations: {
                    self.progressIndicator.frame.origin.x = self.view.frame.width
                }) { (success: Bool) in
                    self.progressIndicator.frame.origin.x = -2
                }
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jam.users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = userCollection.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        cell.user = jam.users[indexPath.row]
        return cell
    }
    
    let items: [(icon: String, color: UIColor)] = [
        ("icon_home", UIColor(red:0.19, green:0.57, blue:1, alpha:1)),
        ("icon_search", UIColor(red:0.22, green:0.74, blue:0, alpha:1)),
        ("notifications-btn", UIColor(red:0.96, green:0.23, blue:0.21, alpha:1)),
        ("settings-btn", UIColor(red:0.51, green:0.15, blue:1, alpha:1)),
        ("nearby-btn", UIColor(red:1, green:0.39, blue:0, alpha:1)),
        ]
    
    let instruments: [Instrument] = [Instrument.acousticBass, Instrument.choir, Instrument.electricBass, Instrument.electricGuitar, Instrument.saxophone, Instrument.piano]
    
    func circleMenu(circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = instruments[atIndex].color
        button.setImage(instruments[atIndex].image, forState: .Normal)
        
        // set highlited image
        let highlightedImage  = instruments[atIndex].image!.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(highlightedImage, forState: .Highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        let keyboardController = self.childViewControllers[0] as! KeyboardViewController
        keyboardController.instrument = instruments[atIndex]
        keyboardButton.selected = false
    }
    
    func onRecord(sender: UITapGestureRecognizer) {
        countdownLabel.text = "\(countdown)"
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(60/jam.tempo!, target: self, selector: #selector(JamViewController.startRecord), userInfo: nil, repeats: true)
        recordView.popAndPulse()
    }
    
    func startRecord(){
        recordView.popAndPulse()
        if (countdown == 1){
            countdownLabel.text = ""
            countdownTimer.invalidate()
            countdown = 4
            
            let keyboardController = self.childViewControllers[0] as! KeyboardViewController
            
            UIView.animateWithDuration(self.jam.messageDuration, delay: 0.0, options: [.CurveLinear], animations: {
                self.progressIndicator.frame.origin.x = self.view.frame.width
            }) { (success: Bool) in
                self.progressIndicator.frame.origin.x = -2
            }
            
            jam.recordSend(keyboardController.instrument, success: {
                self.tempoTimer.invalidate()
                for subview in self.waveformContainer.subviews {
                    if let waveform = subview as? FDWaveformView {
                        waveform.removeFromSuperview()
                    }
                }
                self.drawWaveforms()
                keyboardController.instrument.reload()
                print("Message sent!")
            }) { (error: NSError) in
                print(error.localizedDescription)
            }
            
            User.currentUser?.incrementInstrument(keyboardController.instrument)
        }
            
        else{
            countdownLabel.text = "\(countdown-1)"
            if (countdown == 2){
                tempoTimer = NSTimer.scheduledTimerWithTimeInterval(60/jam.tempo!, target: recordView, selector: #selector(BAPulseView.popAndPulse), userInfo: nil, repeats: true)
            }
            countdown = countdown - 1
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
