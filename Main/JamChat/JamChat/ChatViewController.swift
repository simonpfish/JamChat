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
    var jam: Jam? {
        didSet {
            for message in jam!.messages {
                message.loadTracks() {
                    self.tableView.reloadData()
                }
            }
        }
    }
    var instrument: AKNode?
    
    var recording = false
    
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
        
    }
    
    func noteOn(note: Int) {
        
        if (!recording) {
            recording = true
            print("recording")
            jam?.recordSend(instrument!, success: {
                print("done!")
                self.tableView.reloadData()
                self.recording = false
                self.jam?.fetch({ 
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
        return jam?.messages.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.message = jam!.messages[indexPath.row]
        return cell
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
