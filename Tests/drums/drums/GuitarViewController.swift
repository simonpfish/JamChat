//
//  GuitarViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/7/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit

class GuitarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onVoice(sender: AnyObject) {
        performSegueWithIdentifier("toVoiceFromGuitar", sender: self)
    }
    
    @IBAction func onDrums(sender: AnyObject) {
        performSegueWithIdentifier("toDrumsFromGuitar", sender: self)
    }
    
    @IBAction func onPiano(sender: AnyObject) {
        performSegueWithIdentifier("toPianoFromGuitar", sender: self)
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
