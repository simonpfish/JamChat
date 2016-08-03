//
//  MinorChordCell.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MinorChordCell: UICollectionViewCell {
    
    @IBOutlet weak var chordLabel: UILabel!
    var chord: Chord! {
        didSet{
            chordLabel.text = chord.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
