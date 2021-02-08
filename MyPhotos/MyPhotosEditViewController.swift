//
//  MyPhotosEditViewController.swift
//  MyPhotos
//
//  Created by SB on 2/7/21.
//

import UIKit

class MyPhotosEditViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var photo: PhotoModel!
    var photoStore: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoStore.fetchImages(for: photo) { (result) in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
