//
//  ChatViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AudioKit
import RBBAnimation
import EasyAnimation

class ChatViewController: UIViewController, KeyboardDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
        
    @IBOutlet weak var waveformView: UIView!
    
    var sampler = AKSampler()
    var wah: AKAutoWah?
    var chat: Chat?
    var instrument: AKNode?
    
    var recording = false
    
    let r = CAReplicatorLayer()
    let dot = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let keyboard = PianoView(width: Int(self.view.frame.width), height: 200, lowestKey: 60, totalKeys: 12)
        keyboard.frame.origin.y = CGFloat(self.view.frame.maxY - 200)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.view.addSubview(keyboard)
        sampler.loadWav("RockGuitarC")
        let reverb = AKReverb(sampler)
        reverb.loadFactoryPreset(.SmallRoom)
        
        instrument = reverb
        Track.mainMixer.connect(instrument!)
        
        
        // Do any additional setup after loading the view.
        
        
        r.frame = waveformView.bounds
        waveformView.layer.addSublayer(r)
        
        dot.bounds = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
        dot.position = CGPoint(x: 18.0, y: waveformView.center.y)
        dot.backgroundColor = UIColor.magentaColor().CGColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        dot.borderWidth = 1.0
        dot.cornerRadius = 2.0
        r.addSublayer(dot)
        
        r.instanceCount = 35
        r.instanceTransform = CATransform3DMakeTranslation(20.0, 0.0, 0.0)
        r.instanceDelay = 0.1
        
    }
    
    func sineWaveOn() {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseOut, .Repeat, .Autoreverse, .FillModeForwards], animations: {
            self.dot.transform = CATransform3DMakeScale(1.4, 10, 1.0)
            self.dot.backgroundColor = UIColor.purpleColor().CGColor
            
            }, completion: nil)
        dot.transform = CATransform3DIdentity
        
        UIView.animateWithDuration(1.25, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.r.instanceTransform = CATransform3DMakeTranslation(10.0, 0.0, 0.0)
            }, completion: nil)

    }
    
    func sineWaveOff() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseOut, .Repeat, .Autoreverse, .FillModeForwards], animations: {
            self.dot.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            self.dot.backgroundColor = UIColor.purpleColor().CGColor
            
            }, completion: nil)
        dot.transform = CATransform3DIdentity
        
        UIView.animateWithDuration(1.25, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.r.instanceTransform = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
            }, completion: nil)
    }
    
    func noteOn(note: Int) {
        
        if (!recording) {
            recording = true
            print("recording")
            sineWaveOn()
            chat?.recordSend(instrument!, success: {
                print("done!")
                self.tableView.reloadData()
                self.sineWaveOff()
                self.recording = false
                self.chat?.fetch({ 
                    self.tableView.reloadData()
                    }, failure: { (error: NSError) in
                        print(error.localizedDescription)
                })
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
            })
        }
        
        sampler.playNote(note)

    }
    
    func noteOff(note: Int) {
        sampler.stopNote(note)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat?.messages.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.message = chat!.messages[indexPath.row]
        return cell
    }
    
    
    //does this work?
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var previousOffset: CGFloat
        var rect: CGRect = self.view.frame
        previousOffset = scrollView.contentOffset.y
        rect.origin.y += previousOffset - scrollView.contentOffset.y
        self.view.frame = rect
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
