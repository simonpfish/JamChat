//
//  SelectionViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/7/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit


class SelectionViewController: UIViewController {
    
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
    }
    
    @IBAction func onGuitar(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Guitar"
    }
    
    @IBAction func onDrums(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Drums"
    }
    
    @IBAction func onPiano(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Piano"
    }
    
    @IBAction func onSax(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Saxophone"
    }
    
    @IBAction func onStandUpBass(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Stand Up Bass"
    }
    
    @IBAction func onElectricBass(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Electric Bass"
    }
    
    @IBAction func onMiscPercussion(sender: UITapGestureRecognizer) {
        instrumentLabel.text = "Miscellaneous Percussion"
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
