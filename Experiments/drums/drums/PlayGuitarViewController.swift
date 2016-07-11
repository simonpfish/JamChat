//
//  PlayGuitarViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/8/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit

class PlayGuitarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toVoice(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayGuitartoPlayVoice", sender: self)
    }
    
    @IBAction func toDrums(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayGuitartoPlayDrums", sender: self)
    }
    
    @IBAction func toSelection(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayGuitartoSelection", sender: self)
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
