//
//  MajorChordViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MajorChordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var majorCollection: UICollectionView!
    
    override func viewDidLoad() {
        majorCollection.dataSource = self
        majorCollection.delegate = self
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = majorCollection.dequeueReusableCellWithReuseIdentifier("MajorChordCell", forIndexPath: indexPath) as! MajorChordCell
        
        //cell.chords = array[indexPath.row]
        
        return cell
    }

}
