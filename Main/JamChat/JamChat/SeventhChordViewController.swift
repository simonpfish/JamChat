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
    
    var jam: Jam!
    var chords: [Chord]!

    override func viewDidLoad() {
        seventhCollection.delegate = self
        seventhCollection.dataSource = self
        
        if (jam.tempo == 80){
            chords = Chord.SevChords80
        }
        
        else if(jam.tempo == 110){
            chords = Chord.SevChords110
        }
        
        else{
            chords = Chord.SevChords140
        }
        
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = seventhCollection.dequeueReusableCellWithReuseIdentifier("SeventhChordCell", forIndexPath: indexPath) as! SeventhChordCell
        
        cell.chord = chords[indexPath.row]
        
        return cell
    }


}
