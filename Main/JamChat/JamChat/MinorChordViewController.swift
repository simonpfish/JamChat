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
    
    var jam: Jam!
    var chords: [Chord] = []
    
    override func viewDidLoad() {
        minorCollection.delegate = self
        minorCollection.dataSource
            = self
        
        if (jam.tempo == 80){
            chords = Chord.MinChords80
        }
            
        else if(jam.tempo == 110){
            chords = Chord.MinChords110
        }
            
        else{
            chords = Chord.MinChords140
        }
        
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = minorCollection.dequeueReusableCellWithReuseIdentifier("MinorChordCell", forIndexPath: indexPath) as! MinorChordCell
        
        cell.chord = chords[indexPath.row]
        
        return cell
    }

}
