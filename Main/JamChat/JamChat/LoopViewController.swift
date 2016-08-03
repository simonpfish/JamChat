//
//  LoopViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/27/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RandomColorSwift
import NVActivityIndicatorView

class LoopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IndicatorInfoProvider {
    
    var jam: Jam!
    var array: [Loop] = []
    var panGesture: UIPanGestureRecognizer?
    var currentDragAndDropIndexPath: NSIndexPath?
    var currentDragAndDropSnapshot: UIView?
    var dragLoopHandler: ((UIView, UIPanGestureRecognizer) -> ())?
    var highlightView: UIView?
    var loadingView: NVActivityIndicatorView!
    var waveformView: UIView!
    
    @IBOutlet weak var loopCollection: UICollectionView!
    
    override func viewDidLoad() {
        
        loopCollection.delegate = self
        loopCollection.dataSource = self
        
        if(jam.tempo == 80){
            array = Loop.Loops80
        }
        else if(jam.tempo == 110){
            array = Loop.Loops110
        }
        else{
            array = Loop.Loops140
        }
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(LoopViewController.dragLoop(_:)))
        self.loopCollection.addGestureRecognizer(self.panGesture!)
        
        super.viewDidLoad()
    }
    
    var selectedLoopView: UIView?
    var selectedLoop: Loop?
    var selectedMeasure = 0.0
    var isOverWaveform = false
    func dragLoop(sender: UIPanGestureRecognizer){
        
        switch sender.state{
        case .Began:
            if let indexPathForLocation = self.loopCollection.indexPathForItemAtPoint(sender.locationInView(loopCollection)) {
                let selectedCell: LoopCell? = self.loopCollection.cellForItemAtIndexPath(indexPathForLocation) as? LoopCell
                
                selectedLoopView = selectedCell!.snapshot
                selectedLoop = selectedCell?.loop
                selectedLoopView?.center = selectedCell!.center
                self.view.superview!.superview!.addSubview(selectedLoopView!)
                
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
                self.selectedLoopView!.center.x = point.x
                self.selectedLoopView!.center.y = point.y
                self.highlightView?.frame.origin.x = CGFloat(self.selectedMeasure) * self.highlightView!.frame.width
                
                if self.isOverWaveform {
                    self.highlightView?.hidden = false
                } else {
                    self.highlightView?.hidden = true
                }
            })
        default:
            selectedLoopView?.removeFromSuperview()
            highlightView?.backgroundColor = UIColor.clearColor()
            if isOverWaveform {
                loadingView.startAnimation()
                if jam.isPlaying {
                    jam.stop()
                }
                jam.recordSendLoop(selectedLoop!, measure: selectedMeasure, success: {
                    self.loadingView.stopAnimation()
                    print("Sent loop!")
                    }, failure: { (error: NSError) in
                        print(error.localizedDescription)
                })
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = loopCollection.dequeueReusableCellWithReuseIdentifier("LoopCell", forIndexPath: indexPath) as! LoopCell
        
        cell.loop = array[indexPath.row]
        
        return cell
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Drum Loops")
    }
    
}
