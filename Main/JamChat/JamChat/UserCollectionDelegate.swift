//
//  UserCollectionDelegate.swift
//  JamChat
//
//  Created by Meena Sengottuvelu on 7/21/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class UserCollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    var users: [User]
    
    init (users: [User]) {
        self.users = users
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
}
