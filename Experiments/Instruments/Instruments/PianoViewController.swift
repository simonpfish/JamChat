//
//  PianoViewController.swift
//  Instruments
//
//  Created by Alexina Boudreaux-Allen on 7/11/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import AudioKit

class PianoViewController: UIViewController {
    
    let sampler = AKSampler()
    var touchPoint = CGPoint()
    var myGesture = UIPanGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       sampler.loadWav("PianoC")
        let reverb = AKReverb(sampler)
        reverb.loadFactoryPreset(.SmallRoom)
        AudioKit.output = reverb
        AudioKit.start()
        
        myGesture = UIPanGestureRecognizer(target: self, action: Selector("panDetected:"))
        myGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(myGesture)
    }
    
    @IBAction func downC(sender: AnyObject) {
        sampler.playNote(60)
    }
    
    @IBAction func upC(sender: AnyObject) {
        sampler.stopNote(60)
    }
    
    @IBAction func downCsharp(sender: AnyObject) {
        sampler.playNote(61)
    }
    
    @IBAction func upCsharp(sender: AnyObject) {
            sampler.stopNote(61)
    }
    
    @IBAction func downD(sender: AnyObject) {
        sampler.playNote(62)
    }
   
    @IBAction func upD(sender: AnyObject) {
        sampler.stopNote(62)
    }
    
    @IBAction func downEflat(sender: AnyObject) {
        sampler.playNote(63)
    }

    @IBAction func upEflat(sender: AnyObject) {
            sampler.stopNote(63)
    }
    
    @IBAction func downE(sender: AnyObject) {
        sampler.playNote(64)
    }
    
    @IBAction func upE(sender: AnyObject) {
            sampler.stopNote(64)
    }
    
    @IBAction func downF(sender: AnyObject) {
        sampler.playNote(65)
    }
    
    @IBAction func upF(sender: AnyObject) {
            sampler.stopNote(65)
    }
    
    @IBAction func downFsharp(sender: AnyObject) {
        sampler.playNote(66)
    }
    
    @IBAction func upFsharp(sender: AnyObject) {
            sampler.stopNote(66)
    }
   
    @IBAction func downG(sender: AnyObject) {
        sampler.playNote(67)
    }
    
    
    @IBAction func upG(sender: AnyObject) {
            sampler.stopNote(67)
    }
    
    @IBAction func downAflat(sender: AnyObject) {
        sampler.playNote(68)
    }
    
    @IBAction func upAflat(sender: AnyObject) {
            sampler.stopNote(68)
    }
   
    @IBAction func downA(sender: AnyObject) {
        sampler.playNote(69)
    }
    
    @IBAction func upA(sender: AnyObject) {
            sampler.stopNote(69)
    }
    
    @IBAction func downBflat(sender: AnyObject) {
                sampler.playNote(70)
    }
   
    @IBAction func upBflat(sender: AnyObject) {
        sampler.stopNote(70)
    }
    
    @IBAction func downB(sender: AnyObject) {
        sampler.playNote(71)
    }
    
    @IBAction func upB(sender: AnyObject) {
        sampler.stopNote(71)
        sampler.stopNote(70)
    }
   
    @IBOutlet weak var dragC: UIButton!
    var countC = 0
    @IBOutlet weak var dragCsharp: UIButton!
    var countCsharp = 0
    @IBOutlet weak var dragD: UIButton!
    var countD = 0
    @IBOutlet weak var dragEflat: UIButton!
    var countEflat = 0
    @IBOutlet weak var dragE: UIButton!
    var countE = 0
    @IBOutlet weak var dragF: UIButton!
    var countF = 0
    @IBOutlet weak var dragFsharp: UIButton!
    var countFsharp = 0
    @IBOutlet weak var dragG: UIButton!
    var countG = 0
    @IBOutlet weak var dragAflat: UIButton!
    var countAflat = 0
    @IBOutlet weak var dragA: UIButton!
    var countA = 0
    @IBOutlet weak var dragBflat: UIButton!
    var countBflat = 0
    @IBOutlet weak var dragB: UIButton!
    var countB = 0
    
    func panDetected(sender : UIPanGestureRecognizer) {
        touchPoint = sender.locationInView(self.view)
        
        
        if CGRectContainsPoint(dragC.frame, touchPoint) {
            if countC == 0{
                sampler.playNote(60)
                countC = 1
            }
            
        }
        else{
            countC = 0
        }
            
        if CGRectContainsPoint(dragCsharp.frame, touchPoint) {
            if countCsharp == 0{
                sampler.playNote(61)
                countCsharp = 1
            }
            
        }
        else{
            countCsharp = 0
        }

            
        if CGRectContainsPoint(dragD.frame, touchPoint) {
            if countD == 0{
                sampler.playNote(62)
                countD = 1
            }
            
        }
        else{
            countD = 0
        }

        
        if CGRectContainsPoint(dragEflat.frame, touchPoint) {
            if countEflat == 0{
                sampler.playNote(63)
                countEflat = 1
            }
            
        }
        else{
            countEflat = 0
        }

        
        if CGRectContainsPoint(dragE.frame, touchPoint) {
            if countE == 0{
                sampler.playNote(64)
                countE = 1
            }
            
        }
        else{
            countE = 0
        }

        
        if CGRectContainsPoint(dragF.frame, touchPoint) {
            if countF == 0{
                sampler.playNote(65)
                countF = 1
            }
            
        }
        else{
            countF = 0
        }

        
       if CGRectContainsPoint(dragFsharp.frame, touchPoint) {
            if countFsharp == 0{
                sampler.playNote(66)
                countFsharp = 1
            }
            
        }
        else{
            countFsharp = 0
        }

        
      if CGRectContainsPoint(dragG.frame, touchPoint) {
            if countG == 0{
                sampler.playNote(67)
                countG = 1
            }
            
        }
        else{
            countG = 0
        }

        
    if CGRectContainsPoint(dragAflat.frame, touchPoint) {
        if countAflat == 0{
            sampler.playNote(68)
            countAflat = 1
        }
        
    }
    else{
        countAflat = 0
        }

        
       if CGRectContainsPoint(dragA.frame, touchPoint) {
        if countA == 0{
            sampler.playNote(69)
            countA = 1
        }
        
       }
       else{
        countA = 0
        }
        
        if CGRectContainsPoint(dragBflat.frame, touchPoint) {
            if countBflat == 0{
                sampler.playNote(70)
                countBflat = 1
            }
            
        }
        else{
            countBflat = 0
        }

        
        if CGRectContainsPoint(dragB.frame, touchPoint) {
            if countB == 0{
                sampler.playNote(71)
                countB = 1
            }
            
        }
        else{
            countB = 0
        }

        
       
    }
   
    
}
