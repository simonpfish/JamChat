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
    
    init (instruments: [Instrument]) {
        self.instruments = instruments
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instruments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath) as! InstrumentCell
        cell.instrument = instruments[indexPath.row]
        return cell
    }
        
}
