//
//  MinorChordViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MinorChordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var minorCollection: UICollectionView!
    
    override func viewDidLoad() {
        minorCollection.delegate = self
        minorCollection.dataSource
            = self
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = minorCollection.dequeueReusableCellWithReuseIdentifier("MinorChordCell", forIndexPath: indexPath) as! MinorChordCell
        
        //cell.chords = array[indexPath.row]
        
        return cell
    }

}
