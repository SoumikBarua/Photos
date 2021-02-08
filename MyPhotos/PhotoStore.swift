//
//  PhotoStore.swift
//  MyPhotos
//
//  Created by SB on 2/6/21.
//

import UIKit

class PhotoStore {
    
    let imageStore = ImageStore()
    
    // MARK: - JSON Operations
    func fetchPhotos(completion: @escaping (Result<[PhotoModel], Error>) -> Void) {
        // Fetching JSON data asynchronously
        let url = URL(string: "https://eulerity-hackathon.appspot.com/image")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            
            let result = self.processPhotosRequest(data: data, error: error)
            
            // Call the completion handler on the main thread
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> Result<[PhotoModel], Error> {
        // Handle JSON success/failure, create instances of Photo Model objects for success
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        do {
            let photos = try JSONDecoder().decode([PhotoModel].self, from: jsonData)
            return .success(photos)
        } catch {
            return .failure(error)
        }
    }
    

    // MARK: - Image download operations
    func fetchImages(for photo: PhotoModel, completion: @escaping(Result<UIImage, Error>) -> Void) {
        // Fetching image from URLs asynchronously
        let photoKey = photo.url
        if let image = imageStore.getImage(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        let url = URL(string: photo.url)!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processImagesRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
            // Call the completion handler on the main thread
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
        
    
    private func processImagesRequest(data: Data?, error: Error?) -> Result<UIImage, Error> {
        // Handle image success/failure, return the image of for a particular photo
        guard let imageData = data, let image = UIImage(data: imageData) else {
            return .failure(error!)
        }
        
        return .success(image)
        
    }
    
}
