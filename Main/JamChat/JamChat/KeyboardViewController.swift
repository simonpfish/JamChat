//
//  KeyboardViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/19/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController {
    
    var keys: [UIView] = []
    
    var onKeys: Set<UIView> = []
    
    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    let totalKeys = 12
    let lowestKey = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let allowedNotes = notesWithSharps //["A", "B", "C#", "D", "E", "F#", "G"]
        
        let keyWidth = Int(view.frame.width) / totalKeys - 1
        let height = Int(view.frame.height)
        
        let blackFrame = UIView(frame: CGRect(x: 0, y: 0, width: (keyWidth + 1) * totalKeys + 1, height: height))
        blackFrame.backgroundColor = UIColor.clearColor()
        view.addSubview(blackFrame)
        
        var keyCount = 0
        var increment = 0
        while keyCount < totalKeys {
            if  allowedNotes.indexOf(notesWithFlats[(lowestKey + increment) % 12]) != nil || allowedNotes.indexOf(notesWithSharps[(lowestKey + increment) % 12]) != nil {
                var newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: height - 2))
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: height - 50))
                    newButton.backgroundColor = UIColor.blackColor()
                } else {
                    newButton.backgroundColor = UIColor.whiteColor()
                    newButton.layer.borderColor = UIColor.blackColor().CGColor
                    newButton.layer.borderWidth = 2
                }
                
                newButton.setNeedsDisplay()
                
                newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                newButton.frame.origin.y = CGFloat(1)
                newButton.tag = lowestKey + increment
                keys.append(newButton)
                view.addSubview(newButton)
                keyCount += 1
                
            }
            increment += 1
            
        }
        // Do any additional setup after loading the view.
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
                    Instrument.electricGuitar.play(key.tag)
                    unhighlightKeys()
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
                    Instrument.electricGuitar.play(key.tag)
                    unhighlightKeys()
                    key.backgroundColor = UIColor.redColor()
                    onKeys.insert(key)
                }
            }
            
            // determine vertical value
            //setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            for key in keys where onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self.view)) {
                    Instrument.electricGuitar.stop(key.tag)
                    unhighlightKeys()
                }
            }
        }
    }
    
    func unhighlightKeys() {
        for key in onKeys {
            if notesWithSharps[key.tag % 12].rangeOfString("#") != nil {
                key.backgroundColor = UIColor.blackColor()
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
