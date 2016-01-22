//
//  MovieGridViewController.swift
//  MovieViewer
//
//  Created by David Wayman on 1/21/16.
//  Copyright © 2016 David Wayman. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieGridViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorBackground: UIView!
    @IBOutlet weak var networkErrorTextLabel: UILabel!
    
    var movies: [NSDictionary]?
    
    func moviePosterForIndexPath(indexPath: NSIndexPath) -> NSURL {
        
        let movie = movies![indexPath.row]
        let posterPath = movie["poster_path"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let imageURL = NSURL(string: baseURL + posterPath)
        
        return imageURL!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        
        loadDataFromNetwork()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
    }
    
    // Check if connected to network ----------------------
    func checkNetwork() {
        if Reachability.isConnectedToNetwork() {
            networkErrorBackground.hidden = true
            networkErrorTextLabel.hidden = true
        } else {
            networkErrorBackground.hidden = false
            networkErrorTextLabel.hidden = false
        }
    }
    // ----------------------------------------------------
    
    func loadDataFromNetwork() {
        
        checkNetwork()
        
        // Display HUD right before next request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                            // Hide HUD once network request comes back (must be done on main UI thread)
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // Make network request to fetch latest data
        loadDataFromNetwork()
        
        // Do the following when the network request comes back successfully:
        // Update tableView data source
        refreshControl.backgroundColor = UIColor.redColor()
        refreshControl.tintColor = UIColor.cyanColor()
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
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

extension MovieGridViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let movies = movies {
            print("movies.count: \(movies.count)")
            return movies.count
        } else {
            print("movies.count: 0")
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.codepath.MoviePosterCell", forIndexPath: indexPath) as! MoviePosterCell
        let cellPosterURL = moviePosterForIndexPath(indexPath)
        
        cell.posterView.setImageWithURL(cellPosterURL)
        
        print("row \(indexPath.row)")
        return cell
    }
}
