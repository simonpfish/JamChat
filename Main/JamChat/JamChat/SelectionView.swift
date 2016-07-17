//
//  SelectionView.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/15/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class SelectionView: UIView {
    var soundString: String?
    
    init(width: Int, height: Int) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let imageView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.addSubview(imageView)
        
        var image = UIImage(named: "sax2")
        let saxView = UIImageView(image: image!)
        saxView.frame = CGRect(x: 50, y: 60, width: 50, height: 50)
        self.addSubview(saxView)
        saxView.userInteractionEnabled = true
        
        image = UIImage(named: "mic_large")
        let choirView = UIImageView(image: image!)
        choirView.frame = CGRect(x: 50, y: 10, width: 50, height: 50)
        self.addSubview(choirView)
        choirView.userInteractionEnabled = true
        
        image = UIImage(named: "electricGuitar")
        let guitarView = UIImageView(image: image!)
        guitarView.frame = CGRect(x: 165, y: 10, width: 50, height: 50)
        self.addSubview(guitarView)
        guitarView.userInteractionEnabled = true
        
        image = UIImage(named: "Piano")
        let pianoView = UIImageView(image: image!)
        pianoView.frame = CGRect(x: 280, y: 10, width: 50, height: 50)
        self.addSubview(pianoView)
        pianoView.userInteractionEnabled = true
        
        image = UIImage(named: "standUp")
        let standUpView = UIImageView(image: image!)
        standUpView.frame = CGRect(x: 165, y: 60, width: 50, height: 50)
        self.addSubview(standUpView)
        standUpView.userInteractionEnabled = true
        
        image = UIImage(named: "electricBass")
        let bassView = UIImageView(image: image!)
        bassView.frame = CGRect(x: 280, y: 80, width: 50, height: 30)
        self.addSubview(bassView)
        bassView.userInteractionEnabled = true
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
