//
//  SeventhChordCell.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class SeventhChordCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var chordLabel: UILabel!
    @IBOutlet weak var chordView: UIView!
    
    var chord: Chord!{
        didSet{
            chordLabel.text = chord.name
        }
    }
    
    var isMoving: Bool = false {
        didSet{
            self.chordView!.alpha = isMoving ? 0.0: 1.0
            print("ISMOVING")
        }
    }
    
    var snapshot: UIView{
        let snapshot: UIView = self.snapshotViewAfterScreenUpdates(true)
        
        return snapshot
    }
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SeventhChordCell.tapChord(_:)))
        tap.delegate = self
    chordView.addGestureRecognizer(tap)
        
        super.awakeFromNib()
    }
    
    func tapChord(sender: UITapGestureRecognizer){
        chord.play()
        
    }


}
