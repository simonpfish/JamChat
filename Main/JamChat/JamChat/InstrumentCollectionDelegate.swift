//
//  InstrumentCollectionDelegate.swift
//  JamChat
//
//  Created by Meena Sengottuvelu on 7/21/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class InstrumentCollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var instruments: [Instrument]
    var user: User
    
    init (instruments: [Instrument], user: User) {
        self.user = user
        
        let unsortedCounts = user.instrumentCount
        self.instruments = unsortedCounts.keysSortedByValue { (a: Int, b: Int) -> Bool in
            return a>b
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath) as! InstrumentCell
        cell.instrument = instruments[indexPath.row]
        cell.user = user
        return cell
    }
        
}
