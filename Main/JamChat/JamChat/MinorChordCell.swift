//
//  MinorChordCell.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MinorChordCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var chordView: UIView!
    @IBOutlet weak var chordLabel: UILabel!
    var chord: Chord! {
        didSet{
            chordLabel.text = chord.name
        }
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
