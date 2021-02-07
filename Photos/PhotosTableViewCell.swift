//
//  PhotosTableViewCell.swift
//  Photos
//
//  Created by SB on 2/6/21.
//

import UIKit

class PhotosTableViewCell: UITableViewCell {

    @IBOutlet weak var urlImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imageUpdate(displaying image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            urlImageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            urlImageView.image = nil
        }
    }

}
