//
//  JamCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import KTCenterFlowLayout

class JamCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var userCollection: UICollectionView!
    
    @IBOutlet weak var jamNameLabel: UILabel!
    
    
    var jam: Jam? {
        didSet {
            userCollection.reloadData()
            jamNameLabel.text = jam?.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userCollection.dataSource = self
        userCollection.delegate = self
        
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 5.0
        layout.itemSize = CGSizeMake(29, 29)
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        userCollection.collectionViewLayout = layout
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userCollection.contentInset.top = max((userCollection.frame.height - userCollection.contentSize.height) / 2, 0)
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
