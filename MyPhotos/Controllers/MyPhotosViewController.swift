//
//  MyPhotosViewController.swift
//  MyPhotos
//
//  Created by SB on 2/6/21.
//

import UIKit
import PhotoEditorSDK

class MyPhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PhotoEditViewControllerDelegate {
    
    var photos = [PhotoModel]()
    var photoStore: PhotoStore!
    let configuration = Configuration { builder in
        // Modify the appearance of the library
        builder.theme = .light
    }
    var lastSelectedRow: Int! // Keeps track of which row number was tapped/selected for getting relevate data
    let dateFormatter: DateFormatter = { // To reflect the change in the 'updated' field
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y HH:mm:ss a"
        return formatter
    }()
    
    
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
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadPhotos))
        //navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    
    // MARK: - Table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPhotosTableViewCell") as! MyPhotosTableViewCell
        
        cell.imageUpdate(displaying: nil)
        cell.createdLabel.text = "Loading..."
        cell.updatedLabel.text = "Loading..."
        cell.selectionStyle = .none
        
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

            if let cell = self.tableView.cellForRow(at: photoIndexPath) as? MyPhotosTableViewCell {
                cell.imageUpdate(displaying: image)
                cell.createdLabel.text = "Created \(photo.created)"
                cell.updatedLabel.text = "Updated \(photo.updated)"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedRow = indexPath.row
        let lastSelectedPhoto = self.photos[lastSelectedRow]
        let image = photoStore.imageStore.getImage(forKey: lastSelectedPhoto.url)!
        let photo = Photo(image: image)

//        let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
//        photoEditViewController.delegate = self
//
//        //present(photoEditViewController, animated: true, completion: nil)
//        self.navigationController?.pushViewController(photoEditViewController, animated: true)
        
        performSegue(withIdentifier: "myPhotosToMyPhotoEdit", sender: image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "myPhotosToMyPhotoEdit":
            let editViewController = segue.destination as! MyPhotoEditViewController
            editViewController.passedOriginalImage = sender as? UIImage
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    
    // MARK: - Photo edit delegate methods
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        
        print("Successfully saved")
        // Let's cache the edited image locally
        let photo = photos[lastSelectedRow]
        photoStore.imageStore.setImage(image, forKey: photo.url)
        
        // Get the current time to modify updatedLabel
        let currentDateTime = Date()
        let newDate = dateFormatter.string(from: currentDateTime)
        photo.updated = newDate
        
        let indexPath = IndexPath(row: lastSelectedRow, section: 0)
        
        // Instead of reloading the entire table view, just update the imageview & the label of the row/Photo that was edited
        if let cell = tableView.cellForRow(at: indexPath) as? MyPhotosTableViewCell {
            cell.imageUpdate(displaying: image)
            cell.updatedLabel.text = "Updated \(newDate)"
        }
        
        navigationController?.popViewController(animated: true)
        
        // Let's upload the image
        photoStore.postUpload(editedImage: image, originalURL: photo.url) {
            (result) in
            
            if result["status"] == "success" {
                
                let title = "Success"
                let message = "Your edited image has been saved locally & successfully uploaded online!"
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) {
                    _ in
                }
                alertController.addAction(dismissAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        print("Oops, something didn't quite work out!")
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        print("Was simply dismissed")
        return
    }
    
    
    // @objc func uploadPhoto

}

