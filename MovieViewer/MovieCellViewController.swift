//
//  MovieCellViewController.swift
//  MovieViewer
//
//  Created by David Wayman on 1/21/16.
//  Copyright © 2016 David Wayman. All rights reserved.
//

import UIKit

class MovieCellViewController: UIViewController {
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        scrollView.userInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        titleLabel.text = movie["title"] as? String
        titleLabel.sizeToFit()
        
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        
        let rating = movie["vote_average"] as! Double
        (rating < 1.0) ? (ratingLabel.text = "Score: Not Rated Yet") :
                         (ratingLabel.text = "Score: \(rating)/10")
        ratingLabel.sizeToFit()
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            posterView.setImageWithURL(imageURL!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapped(img: AnyObject) {
        performSegueWithIdentifier("posterFullScreen", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let movies = movie!
        
        let posterImageViewController = segue.destinationViewController as! PosterImageViewController
        posterImageViewController.movie = movies
        
    }
    

}
