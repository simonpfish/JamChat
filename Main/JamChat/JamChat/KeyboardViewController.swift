//
//  KeyboardViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/19/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import CircleMenu
import AudioKit

class KeyboardViewController: UIViewController, CircleMenuDelegate{
    
    var keys: [UIView] = []
    
    var onKeys: Set<UIView> = []
    
    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    let totalKeys = 12
    let lowestKey = 60
    
    static var selectedInstrument = Instrument.instruments[randomInt(0..<Instrument.instruments.count)]
    
    var sharpKeyColor = selectedInstrument.color
    
    var instrument: Instrument! = selectedInstrument {
        didSet {
            instrument.reload()
            sharpKeyColor = instrument.color
            
            for key in keys {
                if notesWithSharps[key.tag % 12].rangeOfString("#") != nil {
                    print("changing color")
                    UIView.animateWithDuration(0.5, animations: { 
                        key.backgroundColor = self.sharpKeyColor
                    })
                } else {
                    key.backgroundColor = UIColor.whiteColor()
                }
            }
            
            KeyboardViewController.selectedInstrument = instrument
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        renderKeyboard()
        // Do any additional setup after loading the view.
    }
    
    func renderKeyboard() {
        let allowedNotes = notesWithSharps //["A", "B", "C#", "D", "E", "F#", "G"]
        
        let keyWidth = Int(view.frame.width) / totalKeys - 1
        let height = Int(view.frame.height)
        
        let blackFrame = UIView(frame: CGRect(x: 0, y: 0, width: (keyWidth + 1) * totalKeys + 1, height: height))
        blackFrame.backgroundColor = UIColor.clearColor()
        view.addSubview(blackFrame)
        
        var labelColor: UIColor!
        
        var keyCount = 0
        var increment = 0
        while keyCount < totalKeys {
            if  allowedNotes.indexOf(notesWithFlats[(lowestKey + increment) % 12]) != nil || allowedNotes.indexOf(notesWithSharps[(lowestKey + increment) % 12]) != nil {
                var newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: 100))
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: 200))
                    newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                    newButton.backgroundColor = sharpKeyColor
                    labelColor = UIColor.whiteColor()
                } else {
                    newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: 200))
                    newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                    newButton.backgroundColor = UIColor.whiteColor()
                    labelColor = UIColor.blackColor()
                }
                
                newButton.layer.borderColor = UIColor.blackColor().CGColor
                newButton.layer.cornerRadius = 10
                newButton.layer.borderWidth = 2
                
                //labels notes
                let noteLabel = UILabel(frame: CGRectMake(0, newButton.frame.height-newButton.frame.width, newButton.frame.width, newButton.frame.width))
                noteLabel.font = noteLabel.font.fontWithSize(12)
                noteLabel.textColor = labelColor
                noteLabel.textAlignment = NSTextAlignment.Center
                noteLabel.text = notesWithSharps[(lowestKey + increment) % 12]
                newButton.addSubview(noteLabel)
                
                newButton.setNeedsDisplay()
                newButton.frame.origin.y = CGFloat(1)
                newButton.tag = lowestKey + increment
                keys.append(newButton)
                view.addSubview(newButton)
                keyCount += 1
                
            }
            increment += 1
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            for key in keys where !onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self.view)) {
                    instrument.play(key.tag)
//                    unhighlightKeys()
                    key.backgroundColor = UIColor.redColor()
                    onKeys.insert(key)
                }
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            for key in keys where !onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self.view)) {
                    instrument.play(key.tag)
                    unhighlightKeys()
                    key.backgroundColor = UIColor.redColor()
                    onKeys.insert(key)
                }
            }
            
            // determine vertical value
            //setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    @IBAction func onPan(sender: UIPanGestureRecognizer) {
        
        for key in keys where !onKeys.contains(key) {
            if CGRectContainsPoint(key.frame, sender.locationInView(self.view)) {
                instrument.play(key.tag)
                for key in onKeys {
                    instrument.stop(key.tag)
                }
                unhighlightKeys()
                key.backgroundColor = UIColor.redColor()
                onKeys.insert(key)
            }
        }
        
        if(sender.state == .Ended){
            for key in keys where onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, sender.locationInView(self.view)) {
                    instrument.stop(key.tag)
                    unhighlightKeys()
                }
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            for key in keys where onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self.view)) {
                    instrument.stop(key.tag)
                    unhighlightKeys()
                }
            }
        }
        
        
    }
    
    func unhighlightKeys() {
        for key in onKeys {
            if notesWithSharps[key.tag % 12].rangeOfString("#") != nil {
                key.backgroundColor = sharpKeyColor
            } else {
                key.backgroundColor = UIColor.whiteColor()
            }
        }
        onKeys.removeAll()
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
