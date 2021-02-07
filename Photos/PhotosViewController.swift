//
//  PhotosViewController.swift
//  Photos
//
//  Created by SB on 2/6/21.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var photos = [Photo]()
    var photoStore: PhotoStore!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set the data source & the delegate of the tableview to be displayed
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
    
        photoStore.fetchPhotos() {
            (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos")
                self.photos = photos
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
                self.photos.removeAll()
            }
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosTableViewCell") as! PhotosTableViewCell
        
        cell.imageUpdate(displaying: nil)
        cell.createdLabel.text = ""
        cell.updatedLabel.text = ""
        
        return cell
    }
    
    
    // MARK: - Table view delegate methods
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let photo = self.photos[indexPath.row]
        
        // Let's download the image for this photo
        photoStore.fetchImages(for: photo) {
            (result) in
            
            guard let photoIndex = self.photos.firstIndex(of: photo), case let .success(image) = result else {
                return
            }
            
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.tableView.cellForRow(at: photoIndexPath) as? PhotosTableViewCell {
                cell.imageUpdate(displaying: image)
                cell.createdLabel.text = "Created \(photo.created)"
                cell.updatedLabel.text = "Updated \(photo.updated)"
            }
        }
    }


}

