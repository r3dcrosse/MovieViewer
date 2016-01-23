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
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let URL = userDefaults.URLForKey("cell_poster_URL")
        posterView.setImageWithURL(URL!)
        titleLabel.text = (userDefaults.objectForKey("cell_movie_title") as! String)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap(sender: AnyObject) {
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
