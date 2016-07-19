//
//  Instrument.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/18/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AudioKit

class Instrument: NSObject {
    
        private(set) var _name: String?
        private(set) var _color: UIColor?
        private(set) var _sound: String?
    
    func setInstrument(name: String) {
        _name = name
    
        
        if(_name == "ElectricGuitar"){
            _color = UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0)
            _sound = "RockGuitarC"
        }
            
        else if(_name == "Saxophone"){
            _color = UIColor(red: 0.9294, green: 0.8353, blue: 0, alpha: 1.0)
            _sound = "SaxC"
        }
            
        else if(_name == "Choir"){
            _color = UIColor(red: 0.6392, green: 0, blue: 0.6275, alpha: 1.0)
            _sound = "ChoirC"
        }
            
        else if(_name == "Piano"){
            _color = UIColor.whiteColor()
            _sound = "PianoC"
        }
            
        else if(_name == "AcousticBass"){
            _color = UIColor(red: 0.5294, green: 0.1294, blue: 0, alpha: 1.0)
            _sound = "AcousticBassC"
        }
            
        else if(_name == "ElectricBass"){
            _color = UIColor(red: 0.4118, green: 0.6863, blue: 0, alpha: 1.0)
            _sound = "ElectricBassC"
        }

    }
    
    
    }
