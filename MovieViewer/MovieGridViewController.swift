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

class MovieGridViewController: UIViewController, UISearchBarDelegate {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorBackground: UIView!
    @IBOutlet weak var networkErrorTextLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    var searchActive : Bool = false
    
    override func viewWillAppear(animated: Bool) {
        self.searchBar.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
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
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func moviePosterForIndexPath(indexPath: NSIndexPath) -> NSURL {
        var movie: NSDictionary
        
        searchActive ? (movie = filteredData![indexPath.row]) : (movie = movies![indexPath.row])
        
        let posterPath = movie["poster_path"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w500"
        let imageURL = NSURL(string: baseURL + posterPath)
        
        return imageURL!
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
                filteredData = movies?.filter({ (movie: NSDictionary) -> Bool in
                    if let title = movie["title"] as? String {
                        if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                            return true
                        } else {
                            return false
                        }
                    }
                    return false
                })
                
                if(filteredData.count == 0){
                    searchActive = false;
                } else {
                    searchActive = true;
                }
        
            self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.text = ""
        searchActive = false
        self.searchBar.endEditing(true)
        self.collectionView.reloadData()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.searchBar.endEditing(true)
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
        
        if(searchActive) {
            return filteredData.count
        } else {
            if let movies = movies {
                return movies.count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.codepath.MoviePosterCell", forIndexPath: indexPath) as! MoviePosterCell
        let cellPosterURL = moviePosterForIndexPath(indexPath)
        
        cell.posterView.setImageWithURL(cellPosterURL)
        
        return cell
    }
}

extension MovieGridViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var movie: NSDictionary
        
        searchActive ? (movie = filteredData![indexPath.row]) : (movie = movies![indexPath.row])
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterURL = moviePosterForIndexPath(indexPath)
        let rating = movie["vote_average"] as! Double
        
        // Store movie information in userDefaults after a user clicks on a movie
        userDefaults.setObject(title, forKey: "cell_movie_title")
        userDefaults.setObject(overview, forKey: "cell_movie_overview")
        userDefaults.setURL(posterURL, forKey: "cell_poster_URL")
        userDefaults.setDouble(rating, forKey: "cell_rating")
        userDefaults.setInteger(indexPath.row, forKey: "cell_index")
        userDefaults.synchronize()
    }
}
