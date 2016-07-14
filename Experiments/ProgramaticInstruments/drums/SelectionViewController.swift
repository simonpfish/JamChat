//
//  SelectionViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/7/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    
    var soundString: String = ""
    var instrumentColor: UIColor?
    var scaleSegue: Bool = true
    
    @IBOutlet weak var instrumentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Displays the title of the selected instrument when the image is single tapped
    
    @IBAction func onMic(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Voice"
        self.soundString = "ChoirC"
        instrumentColor = UIColor.greenColor()
    }
    
    @IBAction func onGuitar(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Guitar"
        soundString = "RockGuitarC"
        instrumentColor = UIColor.blueColor()

    }
    
    @IBAction func onDrums(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Drum Kit"
        scaleSegue = false
    }
    
    @IBAction func onPiano(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Piano"
        soundString = "PianoC"
        instrumentColor = UIColor.whiteColor()

    }
    
    @IBAction func onSax(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Saxophone"
        soundString = "SaxC"
        instrumentColor = UIColor.yellowColor()

    }
    
    @IBAction func onStandUpBass(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Stand Up Bass"
        soundString = "AcousticBassC"
        instrumentColor = UIColor.brownColor()

    }
    
    @IBAction func onElectricBass(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Electric Bass"
        soundString = "ElectricBassC"
        instrumentColor = UIColor.redColor()

    }
    
    @IBAction func onMiscPercussion(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Percussion"
        scaleSegue = false
        
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(scaleSegue == true){
       let controller = segue.destinationViewController as! ScaleInstrumentViewController
        controller.soundString = self.soundString
        controller.instrumentColor = self.instrumentColor
        }
        scaleSegue = true
    }
    }


