//
//  LoopCell.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/27/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class LoopCell: UICollectionViewCell {

    @IBOutlet weak var selectLoop: UIButton!
    
    var loop: Loops!{
        didSet{
            selectLoop.setTitle(loop.name, forState: .Normal)
            selectLoop.backgroundColor = loop.color
        }
    }
    
    override func awakeFromNib() {
        selectLoop.layer.cornerRadius = 0.5*selectLoop.bounds.size.width
        
        super.awakeFromNib()
    }
    
    @IBAction func onLoop(sender: AnyObject) {
        loop.play()
        
    }
    

}
