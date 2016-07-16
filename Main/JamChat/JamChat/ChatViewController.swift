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
    
    @IBOutlet var chatView: UIView!
        
    @IBOutlet weak var waveformView: UIView!
    
    var sampler = AKSampler()
    var jam: Jam?
    var instrument: AKNode?
    var keyboard: PianoView?
    var selection: SelectionView?
    var soundString: String = ""
    var instrumentColor: UIColor?
    var gridButton: UIButton?
    var guitarSender: Bool = false
    
    var recording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        goToSelection()
        //instrument = sampler
        Track.mainMixer.connect(sampler)//instrument!)
        
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
    
    func goToSelection(){
        selection = SelectionView(width: 351, height: 100)
        selection!.frame.origin.y = CGFloat(500)
        chatView.addSubview(selection!)
        
        let saxButton = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        saxButton.addTarget(self, action: #selector(toSax), forControlEvents: .TouchUpInside)
        selection!.addSubview(saxButton)
        
        let voiceButton = UIButton(frame: CGRect(x: 50, y: 10, width: 50, height: 50))
        voiceButton.addTarget(self, action: #selector(toVoice), forControlEvents: .TouchUpInside)
        selection!.addSubview(voiceButton)
        
        let guitarButton = UIButton(frame: CGRect(x: 165, y: 10, width: 50, height: 50))
        guitarButton.addTarget(self, action: #selector(toGuitar), forControlEvents: .TouchUpInside)
        selection!.addSubview(guitarButton)
        
        let pianoButton = UIButton(frame: CGRect(x: 280, y: 10, width: 50, height: 50))
        pianoButton.addTarget(self, action: #selector(toPiano), forControlEvents: .TouchUpInside)
        selection!.addSubview(pianoButton)
        
        let standUpButton = UIButton(frame: CGRect(x: 165, y:60, width: 50, height: 50))
        standUpButton.addTarget(self, action: #selector(toStandUp), forControlEvents: .TouchUpInside)
        selection!.addSubview(standUpButton)
        
        let bassButton = UIButton(frame: CGRect(x: 280, y:80, width: 50, height: 30))
        bassButton.addTarget(self, action: #selector(toBass), forControlEvents: .TouchUpInside)
        selection!.addSubview(bassButton)
        
    }
    
    func toSax(sender: UIButton!) {
        soundString = "SaxC"
        instrumentColor = UIColor(red: 0.9294, green: 0.8353, blue: 0, alpha: 1.0)
        goToInstrument()
    }
    
    func toVoice(sender: UIButton!) {
        soundString = "ChoirC"
        instrumentColor = UIColor(red: 0.6392, green: 0, blue: 0.6275, alpha: 1.0)
        goToInstrument()
    }
    
    func toGuitar(sender: UIButton!) {
        soundString = "RockGuitarC"
        instrumentColor = UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0)
        guitarSender = true
        goToInstrument()
    }
    
    func toPiano(sender: UIButton!) {
        soundString = "PianoC"
        instrumentColor = UIColor.whiteColor()
        goToInstrument()
    }
    
    func toStandUp(sender: UIButton!) {
        soundString = "AcousticBassC"
        instrumentColor = UIColor(red: 0.5294, green: 0.1294, blue: 0, alpha: 1.0)
        goToInstrument()
    }
    
    func toBass(sender: UIButton!) {
        soundString = "ElectricBassC"
        instrumentColor = UIColor(red: 0.4118, green: 0.6863, blue: 0, alpha: 1.0)
        goToInstrument()
    }
    
    func goToInstrument (){
        selection!.removeFromSuperview()
        
        keyboard = PianoView(width: 351, height: 30, lowestKey: 60, totalKeys: 13, color: self.instrumentColor!)
        keyboard!.frame.origin.y = CGFloat(550)
        keyboard!.setNeedsDisplay()
        keyboard!.delegate = self
        sampler.loadWav(self.soundString)
        instrument = sampler
        
        chatView.addSubview(keyboard!)
        
        gridButton = UIButton(frame: CGRect(x: 175, y: 620, width: 30, height: 30))
        
        let image = UIImage(named: "GridView") as UIImage?
        gridButton!.setImage(image, forState: .Normal)
        gridButton!.addTarget(self, action: #selector(onToSelection), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(gridButton!)
        
        
    }
    
    func onToSelection(sender: UIButton!) {
        keyboard!.removeFromSuperview()
        gridButton!.removeFromSuperview()
        goToSelection()
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
