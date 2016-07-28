//
//  LoopCell.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/27/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import BAPulseView

class LoopCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var loopView: BAPulseView!
    @IBOutlet weak var loopLabel: UILabel!
    
    var loop: Loop!{
        didSet{
            loopLabel.text = loop.name
            loopView.backgroundColor = loop.color
        }
    }
    
    override func awakeFromNib() {
        loopView.layer.cornerRadius = 0.5*loopView.bounds.size.width
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoopCell.tapLoop(_:)))
            tap.delegate = self
            loopView.addGestureRecognizer(tap)
            
            super.awakeFromNib()
    }
    
    func tapLoop(sender: UITapGestureRecognizer){

        loop.play()
    }
    

}
