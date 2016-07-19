//
//  JamViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/14/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import KTCenterFlowLayout
import FDWaveformView
import AudioKit

class JamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var jam: Jam!
    
    @IBOutlet weak var jamNameLabel: UILabel!
    @IBOutlet weak var userCollection: UICollectionView!
    @IBOutlet weak var waveformContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up user collection view:
        userCollection.dataSource = self
        userCollection.delegate = self
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 20.0
        layout.itemSize = CGSizeMake(60, 70)
        layout.minimumLineSpacing = 0.0
        userCollection.collectionViewLayout = layout
        jamNameLabel.text = jam.title
        
        
        // Set up waveform view:
        let lastMessage = jam.messages.last
        lastMessage?.loadTracks({
            for track in (lastMessage?.tracks)! {
                if let filepath = track.filepath {
                    
                    let fileURL = NSURL(fileURLWithPath: filepath)
                    
                    let waveformView = FDWaveformView(frame: self.waveformContainer.frame)
                    
                    waveformView.frame.origin.y = 0
                    waveformView.audioURL = fileURL
                    waveformView.doesAllowScrubbing = false
                    waveformView.doesAllowScroll = false
                    waveformView.doesAllowStretch = false
                    
                    self.waveformContainer.addSubview(waveformView)
                    
                    //adds tap gesture recognizer to view
                    let waveTap = UITapGestureRecognizer(target: self, action: Selector("onPlay:"))
                     waveformView.addGestureRecognizer(waveTap)
                }
            }
            
        })
        

    }
    
    //Plays chat when wave is tapped
    func onPlay(sender: UITapGestureRecognizer? = nil) {
        
        let lastMessage = jam.messages.last
        lastMessage?.loadTracks({
            lastMessage?.play()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jam.users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = userCollection.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        cell.user = jam.users[indexPath.row]
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
