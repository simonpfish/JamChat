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
    var countdown = 4
    var inKeyboard: Bool = true
    var inMicrophone: Bool = false
    var inLoop: Bool = false
    
    @IBInspectable var loadingColor: UIColor = UIColor.grayColor()
    
    @IBOutlet weak var measuresView: UIView!
    @IBOutlet weak var progressIndicator: UIView!
    @IBOutlet weak var loopContainer: UIView!
    @IBOutlet weak var keyboardContainer: UIView!
    @IBOutlet weak var jamNameLabel: UILabel!
    @IBOutlet weak var userCollection: UICollectionView!
    @IBOutlet weak var microphoneContainer: UIView!
    @IBOutlet weak var waveformContainer: UIView!
    @IBOutlet weak var keyboardButton: CircleMenu!
    @IBOutlet weak var loadingIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var sendingMessageView: NVActivityIndicatorView!
    @IBOutlet weak var recordView: BAPulseView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    
    
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
                
        layoutMeasureBars()
        
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
        
        //customizes microphone button to be a circle
        microphoneButton.layer.cornerRadius = 0.5 * microphoneButton.bounds.size.width
        microphoneContainer.alpha = 0

        for user in jam!.users {
            if user.facebookID != User.currentUser!.facebookID {
                users.append(user)
            }
        }
        
        //Delegate method for loop drags
        let loopController = self.childViewControllers[1] as! LoopViewController
        loopController.dragLoopHandler = self.dragLoop
        
        drawWaveforms()
    }
    
    func layoutMeasureBars() {
        var measureImage: UIView
        
        for i in 1...jam.numMeasures!-1 {
            measureImage = UIView(frame:CGRectMake((measuresView.frame.width/CGFloat(jam.numMeasures!))*CGFloat(i), ((measuresView.frame.height)/2)-12, 1, 24));
            measureImage.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            measureImage.layer.cornerRadius = 0.5
            measuresView.addSubview(measureImage)
        }
        
        measureImage = UIView(frame:CGRectMake(0, ((measuresView.frame.height)/2), measuresView.frame.width, 1));
        measureImage.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
        measuresView.addSubview(measureImage)
    }
    
    var selectedLoopView: UIView?
    func dragLoop(view: UIView, sender: UIPanGestureRecognizer) {

        switch sender.state{
        case .Began:
            selectedLoopView = view
            selectedLoopView?.backgroundColor = UIColor.clearColor()
            self.view.addSubview(selectedLoopView!)
        case .Changed:
            UIView.animateWithDuration(2, animations: {() -> Void in
                self.selectedLoopView?.transform = CGAffineTransformTranslate(self.selectedLoopView!.transform, 20, 100)
            })
        default:
            selectedLoopView?.removeFromSuperview()
        }
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
            stopAnimatingCursor()
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
    var refreshTime = 0.055
    func startAnimatingCursor() {
        progressTimer =  NSTimer.scheduledTimerWithTimeInterval(refreshTime, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    private var previousProgress: CGFloat = 0
    func updateProgressView() {
        let progress = CGFloat(Double(self.view.frame.width) * jam.playthroughProgress)
        
        if progress < previousProgress {
            self.progressIndicator.frame.origin.x = progress
        } else {
            UIView.animateWithDuration(refreshTime, delay: 0.0, options: [.CurveLinear], animations: {
                self.progressIndicator.frame.origin.x = progress
                }, completion: nil)
        }
        
        previousProgress = progress
    }
    
    func stopAnimatingCursor() {
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
    
    var isCounting = false
    var isRecording = false
    
    func onRecord(sender: UITapGestureRecognizer) {
        if isRecording {return}
        if isCounting {
            cancelCountdown()
        } else {
            startCountdown()
        }
    }
    
    func onBeat() {
        recordView.popAndPulse()
        
        if isCounting {
            countdown -= 1
            countdownLabel.text = String(countdown)
            
            if countdown == 0 {
                startRecording()
            }
        }
    }
    
    func startCountdown() {
        isCounting = true
        self.keyboardButton.hidden = true
        loopButton.hidden = true
        countdownLabel.text = "\(countdown)"
        tempoTimer = NSTimer.scheduledTimerWithTimeInterval(60/jam.tempo!, target: self, selector: #selector(onBeat), userInfo: nil, repeats: true)
        metronome.play()
    }
    
    func cancelCountdown() {
        isCounting = false
        countdownLabel.text = "REC"
        tempoTimer.invalidate()
        isCounting = false
        metronome.stop()
        countdown = 4
    }
    
    var metronome: Metronome {
        switch jam.tempo! {
        case 110:
            return Metronome.metronomeBPM110
        case 140:
            return Metronome.metronomeBPM140
        default:
            return Metronome.metronomeBPM80
            
        }
    }

    func startRecording(){
        isRecording = true
        isCounting = false
        countdownLabel.text = ""
        countdown = 4
        
        onPlay()
        
        delay(self.jam.messageDuration) {
            self.tempoTimer.invalidate()
            self.sendingMessageView.startAnimation()
            self.onPlay()
        }
        
        let keyboardController = self.childViewControllers[0] as! KeyboardViewController
        jam.recordSend(keyboardController.instrument, success: {
            
            for subview in self.waveformContainer.subviews {
                if let waveform = subview as? FDWaveformView {
                    waveform.removeFromSuperview()
                }
            }
                
            self.sendingMessageView.stopAnimation()
            self.keyboardButton.hidden = false
            self.loopButton.hidden = false
            self.drawWaveforms()
            keyboardController.instrument.reload()
            print("Message sent!")
            
            self.isRecording = false
            self.countdownLabel.text = "REC"
        }) { (error: NSError) in
            self.isRecording = false
            self.countdownLabel.text = "REC"
            print(error.localizedDescription)
        }
            
        User.currentUser?.incrementInstrument(keyboardController.instrument)
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
    loopButton.setImage(UIImage(named:"piano.png"), forState: .Normal)
            inKeyboard = false
            keyboardButton.hidden = true
            recordView.hidden = true
            inLoop = true
        }
            
        else if (inMicrophone){
            loopContainer.alpha = 1
            microphoneContainer.alpha = 0
    loopButton.setImage(UIImage(named:"piano.png"), forState: .Normal)
microphoneButton.setImage(UIImage(named:"microphone.png"), forState: .Normal)
            inMicrophone = false
            inLoop = true
        }
            
        else{
            loopContainer.alpha = 0
            keyboardContainer.alpha = 1
    loopButton.setImage(UIImage(named:"loop.png"), forState: .Normal)
            inKeyboard = true
            inLoop = false
            keyboardButton.hidden = false
            recordView.hidden = false
        }
    }
    
    @IBAction func onMicrophone(sender: AnyObject) {
        if (inKeyboard){
            microphoneContainer.alpha = 1
            keyboardContainer.alpha = 0
            microphoneButton.setImage(UIImage(named:"piano.png"), forState: .Normal)
            inKeyboard = false
            keyboardButton.hidden = true
            recordView.hidden = true
            inMicrophone = true
        }
            
        else if (inLoop){
            microphoneContainer.alpha = 1
            loopContainer.alpha = 0
    loopButton.setImage(UIImage(named:"loop.png"), forState: .Normal)
microphoneButton.setImage(UIImage(named:"piano.png"), forState: .Normal)
            inMicrophone = true
            inLoop = false
        }
            
        else{
            microphoneContainer.alpha = 0
            keyboardContainer.alpha = 1
microphoneButton.setImage(UIImage(named:"microphone.png"), forState: .Normal)
            inKeyboard = true
            inMicrophone = false
            keyboardButton.hidden = false
            recordView.hidden = false
        }
    }
    

}
