//
//  MajorChordViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MajorChordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var jam: Jam!
    var chords: [Chord] = []
    
    @IBOutlet weak var majorCollection: UICollectionView!
    
    override func viewDidLoad() {
        majorCollection.dataSource = self
        majorCollection.delegate = self
        
        if (jam.tempo == 80){
            chords = Chord.MajChords80
        }
            
        else if(jam.tempo == 110){
            chords = Chord.MajChords110
        }
            
        else{
            chords = Chord.MajChords140
        }
        
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = majorCollection.dequeueReusableCellWithReuseIdentifier("MajorChordCell", forIndexPath: indexPath) as! MajorChordCell
        
        cell.chord = chords[indexPath.row]
        
        return cell
    }

}
