//
//  SeventhChordViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class SeventhChordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var seventhCollection: UICollectionView!

    override func viewDidLoad() {
        seventhCollection.delegate = self
        seventhCollection.dataSource = self
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = seventhCollection.dequeueReusableCellWithReuseIdentifier("SeventhChordCell", forIndexPath: indexPath) as! SeventhChordCell
        
        //cell.chords = array[indexPath.row]
        
        return cell
    }


}
