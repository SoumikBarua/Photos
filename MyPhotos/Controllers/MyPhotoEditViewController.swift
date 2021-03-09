//
//  MyPhotoEditViewController.swift
//  MyPhotos
//
//  Created by SB on 3/8/21.
//

import UIKit
import CoreImage

class MyPhotoEditViewController: UIViewController {
    
    var passedOriginalImage: UIImage?
    @IBOutlet weak var editImageView: UIImageView!
    
    @IBOutlet weak var filterSelectionView: UIView!
    @IBOutlet weak var filterSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var addTextView: UIView!
    @IBOutlet weak var textOverlayTextField: UITextField!
    
    struct Filter {
        let filterName: String
        var filterEffectValue: Any?
        var filterEffectValueName: String?
        
        init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?) {
            self.filterName = filterName
            self.filterEffectValue = filterEffectValue
            self.filterEffectValueName = filterEffectValueName
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editImageView.image = passedOriginalImage
        
        filterSelectionView.isHidden = true
        filterSelectionView.layer.cornerRadius = 10
        filterSelectionView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        
        addTextView.isHidden = true
        addTextView.layer.cornerRadius = 10
        addTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    
    func applyFilterTo(image: UIImage, filterEffect: Filter) -> UIImage? {
        
        guard let cgImage = image.cgImage, let openGLContext = EAGLContext(api: .openGLES3) else {
            return nil
        }
        
        let context = CIContext(eaglContext: openGLContext)
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.filterEffectValue, let filterEffectValueName = filterEffect.filterEffectValueName {
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
        
        var filteredImage: UIImage?
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage, let cgiImageResult = context.createCGImage(output, from: output.extent) {
            filteredImage = UIImage(cgImage: cgiImageResult)
        }
        
        return filteredImage
    }
    
    // If the user would like to apply filters, display the view with filter options for users to choose from
    @IBAction func filtersButtonTapped(_ sender: Any) {
        filterSelectionView.isHidden = false
    }
    
    @IBAction func filterDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            editImageView.image = applyFilterTo(image: passedOriginalImage!, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.75, filterEffectValueName: kCIInputIntensityKey))
        case 1:
            editImageView.image = applyFilterTo(image: passedOriginalImage!, filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: nil, filterEffectValueName: nil))
        case 2:
            editImageView.image = applyFilterTo(image: passedOriginalImage!, filterEffect: Filter(filterName: "CIPhotoEffectNoir", filterEffectValue: nil, filterEffectValueName: nil))
        default:
            break
        }
    }
    
    
    // Hide the filter options once done
    @IBAction func doneFilterTapped(_ sender: Any) {
        filterSelectionView.isHidden = true
    }
    
    // If the user would like to overlay text, display the view with a text field for users to type into
    @IBAction func textButtonTapped(_ sender: Any) {
        addTextView.isHidden = false
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage? {
        let textSize = ((image.size.height + image.size.width)/2) * (1/5)
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: textSize)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // Hide the text field view once done
    @IBAction func doneTextTapped(_ sender: Any) {
        if let text = textOverlayTextField.text, text != "" {
            let point = CGPoint(x: 5, y: 5)
            editImageView.image = textToImage(drawText: text, inImage: editImageView.image!, atPoint: point)
        }
        addTextView.isHidden = true
    }
    
    // If the user would like perform rotation, rotate the last edited image clockwise
    @IBAction func rotateButtonTapped(_ sender: Any) {
        editImageView.image = rotate(image: editImageView.image!, radians: .pi/2)
    }
    
    func rotate(image: UIImage, radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: image.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        image.draw(in: CGRect(x: -image.size.width/2, y: -image.size.height/2, width: image.size.width, height: image.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
}
