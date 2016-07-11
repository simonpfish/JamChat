//
//  PlayElectricBassViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/11/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit

class PlayElectricBassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //performs the appropriate segue depending on which button on the navigation bar is pressed
    
    @IBAction func onSelection(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayElectricBasstoSelection", sender: self)
    }
    
    @IBAction func onRight(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayElectricBasstoPlayMiscPercussion", sender: self)
    }
    
    @IBAction func onLeft(sender: AnyObject) {
        performSegueWithIdentifier("fromPlayElectricBasstoPlayStandUpBass", sender: self)
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
