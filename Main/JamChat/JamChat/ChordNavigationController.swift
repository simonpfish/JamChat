//
//  ChordNavigationController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ChordNavigationController: UINavigationController, IndicatorInfoProvider {
    
    var jam: Jam?
    
    override func viewDidLoad() {
        let chordController = self.topViewController as! ChordsViewController
        chordController.jam = self.jam
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Chords")

    }

}
