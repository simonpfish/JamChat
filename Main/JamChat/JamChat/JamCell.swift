//
//  JamCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class JamCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var userCollection: UICollectionView!
    
    @IBOutlet weak var jamNameLabel: UILabel!
    
    
    var jam: Jam? {
        didSet {
            userCollection.reloadData()
            jamNameLabel.text = jam?.jamName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userCollection.dataSource = self
        userCollection.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jam?.users.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = userCollection.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        cell.user = jam!.users[indexPath.row]
        return cell
    }

}