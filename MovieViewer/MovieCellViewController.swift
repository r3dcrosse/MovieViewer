//
//  MovieCellViewController.swift
//  MovieViewer
//
//  Created by David Wayman on 1/21/16.
//  Copyright © 2016 David Wayman. All rights reserved.
//

import UIKit

class MovieCellViewController: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var timesAppeared: Int = 0
    
    override func viewWillAppear(animated: Bool) {
        setMovieInfo()
        
        if timesAppeared <= 0 {
            blurBackground()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        posterView.userInteractionEnabled = true
        posterView.addGestureRecognizer(tapGestureRecognizer)
        
        titleLabel.text = (userDefaults.objectForKey("cell_movie_title") as! String)
        overviewLabel.text = (userDefaults.objectForKey("cell_movie_overview") as! String)
        
        let rating = userDefaults.doubleForKey("cell_rating")
        (rating < 1.0) ? (ratingLabel.text = "Score: Not Rated Yet") :
                         (ratingLabel.text = "Score: \(rating)/10")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPosterImage(imageURL: NSURL) {
        
        posterView.setImageWithURL(imageURL)
    }
    
    func setMovieInfo() {
        
        let URL = userDefaults.URLForKey("cell_poster_URL")
        
        posterView.setImageWithURL(URL!)
        
        
    }
    
    func imageTapped(img: AnyObject) {
        performSegueWithIdentifier("posterFullScreen", sender: self)
    }
    
    func blurBackground() {
        // blur poster image for nice background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = posterView.bounds
        posterView.addSubview(blurEffectView)
        
        timesAppeared++
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
