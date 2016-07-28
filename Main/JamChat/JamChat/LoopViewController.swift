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
    var array: [Loops] = []

    @IBOutlet weak var loopCollection: UICollectionView!
    
    override func viewDidLoad() {
        loopCollection.delegate = self
        loopCollection.dataSource = self
        
        if(jam.tempo == 80){
            array = [Loops.loop1BPM80, Loops.loop2BPM80, Loops.loop3BPM80, Loops.loop4BPM80, Loops.loop5BPM80, Loops.loop6BPM80]
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
