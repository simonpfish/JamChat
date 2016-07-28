//
//  LoopViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/27/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class LoopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var jam: Jam!
    var array: [Loop] = []

    @IBOutlet weak var loopCollection: UICollectionView!
    
    override func viewDidLoad() {
        loopCollection.delegate = self
        loopCollection.dataSource = self
        
        if(jam.tempo == 80){
            array = [Loop.loop1BPM80, Loop.loop2BPM80, Loop.loop3BPM80, Loop.loop4BPM80, Loop.loop5BPM80, Loop.loop6BPM80]
        }

        super.viewDidLoad()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = loopCollection.dequeueReusableCellWithReuseIdentifier("LoopCell", forIndexPath: indexPath) as! LoopCell

        cell.loop = array[indexPath.row]

        return cell
    }

}
