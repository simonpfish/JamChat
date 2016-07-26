//
//  LoginViewController.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/26/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class LoginViewController: PFLogInViewController {

    var backgroundImage : UIImageView!;

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImage = UIImageView(image: UIImage(named: "LoginBackground"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.logInView!.insertSubview(backgroundImage, atIndex: 0)
        // Do any additional setup after loading the view.
        
        // remove the parse Logo
        let logo = UILabel()
        logo.text = "JamChat"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "ArialRoundedMTBold", size: 70)
        logo.shadowColor = UIColor.lightGrayColor()
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
        logInView?.logo?.frame.origin.y = view.frame.height/6
        
        logInView?.facebookButton?.frame = CGRectMake(0, 0, 50, 50)
        logInView?.facebookButton?.frame.origin.y = view.frame.height/5 * 4
        logInView?.facebookButton?.frame.origin.x = view.frame.width/2 - 25


        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
