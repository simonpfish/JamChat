//
//  MinorChordViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MinorChordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var minorCollection: UICollectionView!
    
    var jam: Jam!
    var chords: [Chord] = []
    var panGesture: UIPanGestureRecognizer?
    var currentDragAndDropIndexPath: NSIndexPath?
    var currentDragAndDropSnapshot: UIView?
    var dragLoopHandler: ((UIView, UIPanGestureRecognizer) -> ())?
    var highlightView: UIView?
    var waveformView: UIView!
    
    override func viewDidLoad() {
        minorCollection.delegate = self
        minorCollection.dataSource
            = self
        
        if (jam.tempo == 80){
            chords = Chord.MinChords80
        }
            
        else if(jam.tempo == 110){
            chords = Chord.MinChords110
        }
            
        else{
            chords = Chord.MinChords140
        }
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(LoopViewController.dragLoop(_:)))
        self.minorCollection.addGestureRecognizer(self.panGesture!)
        
        super.viewDidLoad()
    }
    
    
    var selectedChordView: UIView?
    var selectedChord: Chord?
    var selectedMeasure = 0.0
    var isOverWaveform = false
    func dragLoop(sender: UIPanGestureRecognizer){
        
        switch sender.state{
        case .Began:
            if let indexPathForLocation = self.minorCollection.indexPathForItemAtPoint(sender.locationInView(minorCollection)) {
                let selectedCell: MinorChordCell? = self.minorCollection.cellForItemAtIndexPath(indexPathForLocation) as? MinorChordCell
                
                selectedChordView = selectedCell!.snapshot
                selectedChord = selectedCell?.chord
                selectedChordView?.center = sender.locationInView(self.view)
                self.parentViewController!.view.superview!.superview!.addSubview(selectedChordView!)
                
                highlightView = UIView(frame: CGRectMake(0, 0, self.view.frame.width/CGFloat(self.jam.numMeasures!), waveformView.frame.height))
                highlightView!.layer.cornerRadius = 25
                highlightView!.alpha = 0.3
                highlightView!.hidden = true
                highlightView!.backgroundColor = UIColor.orangeColor()
                waveformView.addSubview(highlightView!)
            }
        case .Changed:
            let point = sender.locationInView(self.view)
            let pointInSuperview = sender.locationInView(waveformView)
            isOverWaveform = pointInSuperview.y > 0 && pointInSuperview.y < waveformView.frame.height
            selectedMeasure = Double(floor(point.x / self.highlightView!.frame.width))
            
            UIView.animateWithDuration(0.25, animations: {() -> Void in
                self.selectedChordView!.center.x = point.x
                self.selectedChordView!.center.y = point.y
                self.highlightView?.frame.origin.x = CGFloat(self.selectedMeasure) * self.highlightView!.frame.width
                
                if self.isOverWaveform {
                    self.highlightView?.hidden = false
                } else {
                    self.highlightView?.hidden = true
                }
            })
        default:
            selectedChordView?.removeFromSuperview()
            highlightView?.backgroundColor = UIColor.clearColor()
            
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = minorCollection.dequeueReusableCellWithReuseIdentifier("MinorChordCell", forIndexPath: indexPath) as! MinorChordCell
        
        cell.chord = chords[indexPath.row]
        
        return cell
    }

}
