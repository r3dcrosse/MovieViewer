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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorBackground: UIView!
    @IBOutlet weak var networkErrorTextLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    var searchActive: Bool = false
    var endpoint: String!
    
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
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        var movie: NSDictionary
        
        searchActive ? (movie = filteredData![indexPath!.row]) : (movie = movies![indexPath!.row])
        
        let movieCellViewController = segue.destinationViewController as! MovieCellViewController
        movieCellViewController.movie = movie
        
    }
    

}

extension MovieGridViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(searchActive) {
            print("SEARCH IS ACTIVE")
            return filteredData.count
        } else {
            print("SEARCH IS NOT ACTIVE")
            if let movies = movies {
                return movies.count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var movie: NSDictionary
        
        searchActive ? (movie = filteredData![indexPath.row]) : (movie = movies![indexPath.row])
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.codepath.MoviePosterCell", forIndexPath: indexPath) as! MoviePosterCell
        
        let smallImageBaseURL = "http://image.tmdb.org/t/p/w92"
        let largeImageBaseURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageBaseURL + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageBaseURL + posterPath)!)
            
            cell.posterView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        cell.posterView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            cell.posterView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    cell.posterView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
        }
        
        return cell
    }
}

extension MovieGridViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var movie: NSDictionary
        
        searchActive ? (movie = filteredData![indexPath.row]) : (movie = movies![indexPath.row])
        
    }
}
