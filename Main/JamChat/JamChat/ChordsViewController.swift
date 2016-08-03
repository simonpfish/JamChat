//
//  ChordsViewController.swift
//  JamChat
//
//  Created by Meena Sengottuvelu on 8/1/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class ChordsViewController: UIViewController{
    
    var jam: Jam!
    var waveformView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor(red:1.00, green:0.56, blue:0.45, alpha:1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if (segue.identifier == "majorSegue"){
        let chordsController = segue.destinationViewController as! MajorChordViewController
            chordsController.waveformView = waveformView
        chordsController.jam = jam
        }
        
        if (segue.identifier == "minorSegue"){
            let chordsController = segue.destinationViewController as! MinorChordViewController
            chordsController.waveformView = waveformView
            chordsController.jam = jam
        }
        
        if (segue.identifier == "seventhSegue"){
            let chordsController = segue.destinationViewController as! SeventhChordViewController
            chordsController.waveformView = waveformView
            chordsController.jam = jam
        }
        
    }

}
