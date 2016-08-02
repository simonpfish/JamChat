//
//  Loop.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/28/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AVFoundation
import RandomColorSwift

class Loop: NSObject {
    private(set) var name: String!
    private(set) var color: UIColor!
    private(set) var tempo: Int!
    private(set) var image: UIImage?
    
    private var fileName: String!
    private var loopSound: AVAudioPlayer!
    
    private init(name: String, color: UIColor, fileName: String, tempo: Int, image: UIImage?) {
        self.name = name
        self.color = color
        self.fileName = fileName
        self.tempo = tempo
        self.image = image
    }
    
    func play() {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "wav")!
        let url = NSURL(fileURLWithPath: path)
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            loopSound = sound
            sound.play()
        } catch {
            // couldn't load file :(
            print("Failed to load loop")
        }
    }
    
    // Loops:
    static let loop1BPM80 = Loop(name: "1", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#1BPM80", tempo: 80, image: UIImage(named: "afro"))
    static let loop2BPM80 = Loop(name: "2", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#2BPM80", tempo: 80, image: UIImage(named: "circleTech"))
    static let loop3BPM80 = Loop(name: "3", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#3BPM80", tempo: 80, image: UIImage(named: "peace"))
    static let loop4BPM80 = Loop(name: "4", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#4BPM80", tempo: 80, image: UIImage(named: "computer"))
    static let loop5BPM80 = Loop(name: "5", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#5BPM80", tempo: 80, image: UIImage(named: "wires"))
    static let loop6BPM80 = Loop(name: "6", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#6BPM80", tempo: 80, image: UIImage(named: "rockon"))
    static let loop1BPM110 = Loop(name: "1", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#1BPM110", tempo: 110, image: UIImage(named: "leaf"))
    static let loop2BPM110 = Loop(name: "2", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#2BPM110", tempo: 110, image: UIImage(named: "ipodWires"))
    static let loop3BPM110 = Loop(name: "3", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#3BPM110", tempo: 110, image: UIImage(named: "square"))
    static let loop4BPM110 = Loop(name: "4", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#4BPM110", tempo: 110, image: UIImage(named: "headphones"))
    static let loop5BPM110 = Loop(name: "5", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#5BPM110", tempo: 110, image: UIImage(named: "cd"))
    static let loop6BPM110 = Loop(name: "6", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#6BPM110", tempo: 110, image: UIImage(named: "wave"))
    static let loop1BPM140 = Loop(name: "1", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#1BPM140", tempo: 140, image: UIImage(named: "robot"))
    static let loop2BPM140 = Loop(name: "2", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#2BPM140", tempo: 140, image: UIImage(named: "musicnotes"))
    static let loop3BPM140 = Loop(name: "3", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#3BPM140", tempo: 140, image: UIImage(named: "wires"))
    static let loop4BPM140 = Loop(name: "4", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#4BPM140", tempo: 140, image: UIImage(named: "ipod"))
    static let loop5BPM140 = Loop(name: "5", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#5BPM140", tempo: 140, image: UIImage(named: "circleTech1"))
    static let loop6BPM140 = Loop(name: "6", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), fileName: "#6BPM140", tempo: 140, image: UIImage(named: "peaceon"))
}
