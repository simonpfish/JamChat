//
//  PagerViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/18/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class LoopsPagerViewController: ButtonBarPagerTabStripViewController {
    
    static var sharedInstance: LoopsPagerViewController?
    
    @IBInspectable var selectedColor: UIColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
    
    var jam: Jam?
    var waveformView: UIView?
    var loadingView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        
        LoopsPagerViewController.sharedInstance = self
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = UIColor.clearColor()
        settings.style.buttonBarItemBackgroundColor = UIColor.clearColor()
        settings.style.selectedBarBackgroundColor = selectedColor
        settings.style.buttonBarItemFont = UIFont(name: "HelveticaNeue-Light", size:14) ?? UIFont.systemFontOfSize(14)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .blackColor()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
            newCell?.label.textColor = .blackColor()
            
            // enlarges the size of the selected cell
            if animated {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }
        }
        
        moveToViewControllerAtIndex(0, animated: false)
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let jamStoryboard = UIStoryboard(name: "Jam", bundle: NSBundle.mainBundle())
        
        let drumLoopsController = jamStoryboard.instantiateViewControllerWithIdentifier("DrumLoops") as! LoopViewController
        let chordsController = jamStoryboard.instantiateViewControllerWithIdentifier("Chords")

        drumLoopsController.jam = jam
        drumLoopsController.waveformView = waveformView
        drumLoopsController.loadingView = loadingView
        
        return [drumLoopsController, chordsController]
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo) {
        super.configureCell(cell, indicatorInfo: indicatorInfo)
        cell.backgroundColor = .clearColor()
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
