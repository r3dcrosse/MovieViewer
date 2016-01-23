//
//  PosterImageViewController.swift
//  MovieViewer
//
//  Created by David Wayman on 1/23/16.
//  Copyright © 2016 David Wayman. All rights reserved.
//

import UIKit

class PosterImageViewController: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var posterView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        posterView.userInteractionEnabled = true
        posterView.addGestureRecognizer(tapGestureRecognizer)
        
        let URL = userDefaults.URLForKey("cell_poster_URL")
        posterView.setImageWithURL(URL!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapped(img: AnyObject)
    {
        // Your action
        print("TAPPED")
        
        self.dismissViewControllerAnimated(true, completion: {})
        
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
