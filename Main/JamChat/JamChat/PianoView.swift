//
//  PianoView.swift
//  AudioKitPiano
//
//  Created by Alexina Boudreaux-Allen on 7/11/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import AudioKit

public class PianoView: UIView {
    public var delegate: KeyboardDelegate?
    var keys: [PianoKey] = []
    var sharpCount = 0
    var naturalCount = 0
    var sharp: Bool = false
    var natural: Bool = false
    var instrumentColor: UIColor?
    
    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    public init(width: Int, height: Int, lowestKey: Int, totalKeys: Int, color: UIColor) {
        instrumentColor = color
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let allowedNotes = notesWithSharps //["A", "B", "C#", "D", "E", "F#", "G"]
        
        let keyWidth = width / totalKeys - 1
        
        let blackFrame = UIView(frame: CGRect(x: 0, y: 0, width: (keyWidth + 1) * totalKeys + 1, height: height))
        
        blackFrame.backgroundColor = UIColor.whiteColor()
        self.addSubview(blackFrame)
        
        var increment = 0
        var keyCount = 0
        
        while keyCount < totalKeys {
            if  allowedNotes.indexOf(notesWithFlats[(lowestKey + increment) % 12]) != nil || allowedNotes.indexOf(notesWithSharps[(lowestKey + increment) % 12]) != nil {
                let newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: height - 2))
                var color: UIColor?
                
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    color = UIColor.blackColor()
                    
                } else {
                    color = instrumentColor
                }
                
                newButton.backgroundColor = color
                newButton.setNeedsDisplay()
                newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                newButton.frame.origin.y = CGFloat(1)
                newButton.tag = lowestKey + increment
                let newKey = PianoKey()
                newKey.key = newButton
                keys.append(newKey)
                self.addSubview(newButton)

                keyCount += 1
            }
            increment += 1
            
        }
        print("keycount", keyCount)
        print("increment", increment)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            for key in keys {
                if CGRectContainsPoint(key.key!.frame, touch.locationInView(self)) {
                    
                    delegate?.noteOn(key.key!.tag)
                    key.count = 1
                    
                }
                
            }
            
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            for key in keys {
                if CGRectContainsPoint(key.key!.frame, touch.locationInView(self)) {
                    if(key.count == 0){
                        delegate?.noteOn(key.key!.tag)
                        key.count = 1
                    }
                }
                else{
                    key.count = 0
                }
            }
            
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            for key in keys {
                if CGRectContainsPoint(key.key!.frame, touch.locationInView(self)) {
                    delegate?.noteOff(key.key!.tag)
                }
            }
        }
    }
}
