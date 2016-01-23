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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setMovieInfo()
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
        
        titleLabel.text = (userDefaults.objectForKey("cell_movie_title") as! String)
        overviewLabel.text = (userDefaults.objectForKey("cell_movie_overview") as! String)
        posterView.setImageWithURL(URL!)
        
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
