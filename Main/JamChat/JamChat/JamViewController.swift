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
import AVFoundation

class JamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, CircleMenuDelegate {

    var jam: Jam!
    var users: [User] = []
    var tempoTimer = NSTimer()
    var countdownTimer = NSTimer()
    var countdown: Int = 4
    var metronome: AVAudioPlayer!
    var stringBPM: String = ""
    var inKeyboard: Bool = true
    
    @IBInspectable var loadingColor: UIColor = UIColor.grayColor()
    
    @IBOutlet weak var measuresView: UIView!
    @IBOutlet weak var progressIndicator: UIView!
    @IBOutlet weak var loopContainer: UIView!
    @IBOutlet weak var keyboardContainer: UIView!
    @IBOutlet weak var jamNameLabel: UILabel!
    @IBOutlet weak var userCollection: UICollectionView!
    @IBOutlet weak var waveformContainer: UIView!
    @IBOutlet weak var keyboardButton: CircleMenu!
    @IBOutlet weak var loadingIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var sendingMessageView: NVActivityIndicatorView!
    @IBOutlet weak var recordView: BAPulseView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var loopButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardButton.delegate = self
        keyboardButton.layer.cornerRadius = keyboardButton.frame.size.width / 2.0
        keyboardButton.setImage(UIImage(named: "icon_menu"), forState: .Normal)
        keyboardButton.setImage(UIImage(named: "icon_close"), forState: .Selected)
        
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.type = .LineScaleParty
        loadingIndicatorView.color = loadingColor
        
        sendingMessageView.hidesWhenStopped = true
        sendingMessageView.type = .LineScale
        sendingMessageView.color = loadingColor
        
        self.sendingMessageView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
        progressIndicator.layer.cornerRadius = progressIndicator.frame.width/2
                
        var measureImage: UIImageView
        
        if jam.numMeasures == 4 {
            
            for i in 1...3 {
                measureImage = UIImageView(frame:CGRectMake((measuresView.frame.width/4)*CGFloat(i), ((measuresView.frame.height)/2)-15, 10, 30));
                measureImage.image = UIImage(named:"measureBar")
                measuresView.addSubview(measureImage)
            }
        
        } else if jam.numMeasures == 8 {
            
            for i in 1...7 {
                measureImage = UIImageView(frame:CGRectMake((measuresView.frame.width/8)*CGFloat(i), ((measuresView.frame.height)/2)-15, 10, 30));
                measureImage.image = UIImage(named:"measureBar")
                measuresView.addSubview(measureImage)
            }

            
        } else if jam.numMeasures == 12 {
            
            for i in 1...11 {
                measureImage = UIImageView(frame:CGRectMake((measuresView.frame.width/12)*CGFloat(i), ((measuresView.frame.height)/2)-15, 10, 30));
                measureImage.image = UIImage(named:"measureBar")
                measuresView.addSubview(measureImage)
            }
            
        }
        
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
        
        //customizes loop button to be a circle
        loopButton.layer.cornerRadius = 0.5 * loopButton.bounds.size.width

        for user in jam!.users {
            if user.facebookID != User.currentUser!.facebookID {
                users.append(user)
            }
        }
        
        drawWaveforms()
    }

    func drawWaveforms() {
        if let lastMessage = jam.messages.last {
            self.measuresView.hidden = true
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
                self.measuresView.hidden = false
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
        
        if lastMessage!.isPlaying {
            stopAnitatingCursor()
            lastMessage?.stop()
        } else {
            lastMessage?.loadTracks({
                lastMessage?.play({
                    self.startAnimatingCursor()
                })
            })
        }
        
    }
    
    var progressTimer: NSTimer!
    func startAnimatingCursor() {
        progressTimer =  NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    func updateProgressView() {
        let progress = CGFloat(Double(self.view.frame.width) * jam.playthroughProgress)
        UIView.animateWithDuration(0.05, delay: 0.0, options: [.CurveLinear], animations: {
            self.progressIndicator.frame.origin.x = progress
        }, completion: nil)
    }
    
    func stopAnitatingCursor() {
        progressIndicator.frame.origin.x = -2
        progressTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = userCollection.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        cell.user = users[indexPath.row]
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
        metronomeCount()
        recordView.popAndPulse()
    }
    
    //Plays metronome count-in
    func metronomeCount(){
        if (jam.tempo! == 80){
            stringBPM = "80BPM"
        }
        else if (jam.tempo! == 110){
            stringBPM = "110BPM"
        }
        else if (jam.tempo! == 140){
            stringBPM = "140BPM"
        }
        
        let path = NSBundle.mainBundle().pathForResource(stringBPM, ofType: "wav")!
        let url = NSURL(fileURLWithPath: path)
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            metronome = sound
            sound.play()
        } catch {
            print("Couldn't load metronome sound file")
        }
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
            
            delay(self.jam.messageDuration) {
                self.tempoTimer.invalidate()
                self.sendingMessageView.startAnimation()
                self.keyboardButton.hidden = true
            }
            
            jam.recordSend(keyboardController.instrument, success: {
                
                for subview in self.waveformContainer.subviews {
                    if let waveform = subview as? FDWaveformView {
                        waveform.removeFromSuperview()
                    }
                }
                
                self.sendingMessageView.stopAnimation()
                self.keyboardButton.hidden = false
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
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "loopSegue") {
            let childViewController = segue.destinationViewController as! LoopViewController
            childViewController.jam = self.jam
        }
    }
    
    @IBAction func onLoop(sender: AnyObject) {
        if (inKeyboard){
        loopContainer.alpha = 1
        keyboardContainer.alpha = 0
    loopButton.setImage(UIImage(named:"back_arrow.png"), forState: .Normal)
            inKeyboard = false
            keyboardButton.hidden = true
        }
            
        else{
            loopContainer.alpha = 0
            keyboardContainer.alpha = 1
            loopButton.setImage(UIImage(named:"loop.png"), forState: .Normal)
            inKeyboard = true
            keyboardButton.hidden = false
        }
    }

}
