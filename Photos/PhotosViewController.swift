//
//  PhotosViewController.swift
//  Photos
//
//  Created by SB on 2/6/21.
//

import UIKit

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var photos = [[String:String]]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the data source & the delegate of the tableview to be displayed
        tableView.dataSource = self
        tableView.delegate = self
    
        fetchPhotosAndReloadTable()
    }
    
    
    func fetchPhotosAndReloadTable() {
        // Fetching image data asynchronously
        let url = URL(string: "https://eulerity-hackathon.appspot.com/image")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
                
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: String]]
                
                self.photos = dataDictionary
                print(self.photos)
                
                self.tableView.reloadData()
           }
        }
        task.resume()
    }
    
    
    // MARK: - Table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        cell.textLabel?.text = "cell # \(indexPath.row)"
        return cell
    }


}

