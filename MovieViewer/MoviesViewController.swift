//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Majid Rahimi on 1/9/16.
//  Copyright © 2016 Majid Rahimi. All rights reserved.
//

import UIKit
import AFNetworking
import BALoadingView
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{


    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var movieSearch: UISearchBar!
    @IBOutlet weak var topRated: UIButton!
    @IBOutlet weak var nowPlaying: UIButton!
    
    var refreshControl: UIRefreshControl!
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    var url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
    
    
    func networkRequest() {
        tableview.dataSource = self
        tableview.delegate = self
        movieSearch.delegate = self
        
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.filteredData = self.movies
                            self.tableview.reloadData()
                    }
                }
        });
        task.resume()
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableview.insertSubview(refreshControl, atIndex: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkRequest()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func urlChange(sender: AnyObject) {
        
        if sender as! NSObject == topRated {
            url = NSURL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        }
        
        if sender as! NSObject == nowPlaying {
            url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        }
        
        networkRequest()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let filteredData = filteredData{
            return filteredData.count
        }else{
            return 0
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredData[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
//        let review = movie["popularity"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        
        cell.titleLabel.text = title
        cell.overViewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        
        

        print("row \(indexPath.row)")
        return cell
    }
  
    
 //Table View Segue
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let cell = sender as? MovieCell {
//        let indexPath = self.tableview.indexPathForCell(cell)!.row
//            if segue.identifier == "movieSegue" {
//                let vc = segue.destinationViewController as! SecondViewController
//                vc.filteredDict = self.filteredData[indexPath]
//   
//            }
//        }
//        
    
    
//
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        movieSearch.showsCancelButton = true
        filteredData = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.tableview.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        movieSearch.showsCancelButton = false
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }


}
