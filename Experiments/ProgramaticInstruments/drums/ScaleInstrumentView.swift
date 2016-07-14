//
//  ScaleInstrumentView.swift
//  drums
//
//  Created by Alexina Boudreaux-Allen on 7/13/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit
import AudioKit

public protocol KeyboardDelegate {
    func noteOn(note: Int)
    func noteOff(note: Int)
}

public class ScaleInstrumentView: UIView {
    public var delegate: KeyboardDelegate?
    var keys: [ScaleInstrumentObject] = []
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
        
        let keyWidth = width / totalKeys
        //let height = Int(frame.height)
        
        let blackFrame = UIView(frame: CGRect(x: 0, y: 0, width: (keyWidth ) * totalKeys , height: height))
        //blackFrame.layer.cornerRadius = 100
        blackFrame.clipsToBounds = true
        blackFrame.backgroundColor = UIColor.whiteColor()
        self.addSubview(blackFrame)
        
        //var keyCount = 0
        var increment = 0
        while (sharpCount + naturalCount) < totalKeys {
            if  allowedNotes.indexOf(notesWithFlats[(lowestKey + increment) % 12]) != nil || allowedNotes.indexOf(notesWithSharps[(lowestKey + increment) % 12]) != nil {
                
                var color: UIColor?
                var size: Double?
                
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    color = UIColor.blackColor()
                    size = keyWidth*0.9
                    sharp = true
                    //newButton.backgroundColor = UIColor.blackColor()
                } else {
                    color = instrumentColor
                    //newButton.backgroundColor = UIColor.greenColor()
                    size = keyWidth*4/3
                    natural = true
                }
                
                let newButton = UIView(frame:CGRect(x: 0, y: 0, width: size!, height: size!))
                newButton.backgroundColor = color
                newButton.layer.borderColor = UIColor.blackColor().CGColor
                newButton.layer.borderWidth = 2.0
                newButton.layer.cornerRadius = 15
                newButton.clipsToBounds = true
                
                
                newButton.setNeedsDisplay()
                
                var sharpWidth: Double = sharpCount*keyWidth*2/3
                let naturalWidth: Double = naturalCount*keyWidth*4/3
                
                if (sharp == true){
                    sharpWidth = sharpWidth-4
                }
                
                newButton.frame.origin.x = CGFloat(naturalWidth + sharpWidth)
                //print("sharps: ", sharpCount, ", ", sharpWidth, " naturals: ", naturalCount, ", ", naturalWidth)
                
                newButton.frame.origin.y = CGFloat(1)
                newButton.tag = lowestKey + increment
                let newKey = ScaleInstrumentObject()
                newKey.key = newButton
                keys.append(newKey)
                self.addSubview(newButton)
                
                if(sharp == true){
                    sharpCount += 1
                    sharp = false
                }
                if(natural == true ){
                    naturalCount += 1
                    natural = false
                }
                
            }
            increment += 1
            
        }
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
            
            // determine vertical value
            //setPercentagesWithTouchPoint(touchPoint)
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
