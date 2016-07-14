//
//  PlayDrumsViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/8/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit
import AVFoundation

class PlayDrumsViewController: UIViewController {

    //create variables to reference the .mp3 soundfiles
    var crashSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("crashShort", ofType: "mp3")!)
    var highHatSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("highHat", ofType: "mp3")!)
    var smallTomSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("small", ofType: "WAV")!)
    var mediumTomSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("medium", ofType: "wav")!)
    var floorTomSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("G_TOM_1", ofType: "wav")!)
    var snareSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("snare", ofType: "mp3")!)
    var duplicateTomSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("duplicate", ofType: "WAV")!)
    var rideSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("longCrash", ofType: "mp3")!)
    
    //create an AVAudioPlayer object for each instrument
    var crashPlayer = AVAudioPlayer()
    var highHatPlayer = AVAudioPlayer()
    var smallTomPlayer = AVAudioPlayer()
    var mediumTomPlayer = AVAudioPlayer()
    var floorTomPlayer = AVAudioPlayer()
    var snarePlayer = AVAudioPlayer()
    var duplicateTomPlayer = AVAudioPlayer()
    var rideSoundPlayer = AVAudioPlayer()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //instantiate the AudioPlayer object with the correct sound and prepare it to play
        
        crashPlayer = try! AVAudioPlayer(contentsOfURL: crashSound)
        crashPlayer.prepareToPlay()
        
        highHatPlayer = try! AVAudioPlayer(contentsOfURL: highHatSound)
        highHatPlayer.prepareToPlay()
        
        smallTomPlayer = try! AVAudioPlayer(contentsOfURL: smallTomSound)
        smallTomPlayer.prepareToPlay()
        
        mediumTomPlayer = try! AVAudioPlayer(contentsOfURL: mediumTomSound)
        mediumTomPlayer.prepareToPlay()
        
        floorTomPlayer = try! AVAudioPlayer(contentsOfURL: floorTomSound)
        floorTomPlayer.prepareToPlay()
        
        snarePlayer = try! AVAudioPlayer(contentsOfURL: snareSound)
        snarePlayer.prepareToPlay()
        
        duplicateTomPlayer = try! AVAudioPlayer(contentsOfURL: duplicateTomSound)
        duplicateTomPlayer.prepareToPlay()
        
        rideSoundPlayer = try! AVAudioPlayer(contentsOfURL: rideSound)
        rideSoundPlayer.prepareToPlay()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //calls the play method on the appropriate AVAudioPlayer depending on which button is clicked
    
    @IBAction func onCrash(sender: AnyObject) {
        crashPlayer.stop()
        crashPlayer.play()
    }
    
    @IBAction func onHighHat(sender: AnyObject) {
        highHatPlayer.stop()
        highHatPlayer.play()
    }
    
    @IBAction func onSmallTom(sender: AnyObject) {
        smallTomPlayer.stop()
        smallTomPlayer.play()
    }
    
    @IBAction func onMediumTom(sender: AnyObject) {
        mediumTomPlayer.stop()
        mediumTomPlayer.play()
    }
    
    @IBAction func onFloorTom(sender: AnyObject) {
        floorTomPlayer.stop()
        floorTomPlayer.play()
    }
    
    @IBAction func onSnare(sender: AnyObject) {
        snarePlayer.stop()
        snarePlayer.play()
    }
    
    @IBAction func onDuplicateTom(sender: AnyObject) {
        duplicateTomPlayer.stop()
        duplicateTomPlayer.play()
    }
    
    @IBAction func onRide(sender: AnyObject) {
        rideSoundPlayer.stop()
        rideSoundPlayer.play()
    }
    
    //performs the appropriate segue depending on which button on the navigation bar is pressed
    
    @IBAction func toSelection(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayDrumtoSelection", sender: self)
    }
    
    
    
}



