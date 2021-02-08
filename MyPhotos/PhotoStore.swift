//
//  PhotoStore.swift
//  MyPhotos
//
//  Created by SB on 2/6/21.
//

import UIKit

class PhotoStore {
    
    let imageStore = ImageStore()
    
    let getJSONURL = "https://eulerity-hackathon.appspot.com/image"
    let getImageUploadAddressURL = "https://eulerity-hackathon.appspot.com/upload"
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // MARK: - Fetch JSON Operations
    func fetchPhotos(completion: @escaping (Result<[PhotoModel], Error>) -> Void) {
        // Fetching JSON data asynchronously
        let url = URL(string: getJSONURL)!
        let request = URLRequest(url: url)
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
            
            // Call the completion handler on the main thread
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            
            return
        }
        
        let url = URL(string: photo.url)!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            
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
    
    
    func postUpload(editedImage: UIImage, originalURL: String,  completion: @escaping([String:String]) -> Void) {
        
        // Fetching the URL to upload to
        let uploadURL = URL(string: getImageUploadAddressURL)!
        let uploadRequest = URLRequest(url: uploadURL)
        session.dataTask(with: uploadRequest) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
                
                
                // Set up boundary - unique
                let boundary = UUID().uuidString
                
                // appid: a string unique to your project (e.g. your email address)
                let appidField = "appid"
                let appidValue = "mr.soumikbarua@gmail.com"
                
                // original: the url of the original image the user edited
                let original = "original"
                
                // file: the image file being uploaded
                let file = "file"
                let fileName = "image.jpeg"
                
                let url = URL(string: dataDictionary["url"]!)!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)" , forHTTPHeaderField: "Content-Type")
                
                var data = Data()
                // appid
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(appidField)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(appidValue)".data(using: .utf8)!)
                
                // Edited file
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(file)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                //data.append(editedImage.jpegData(compressionQuality: 0.50)!)
                data.append(editedImage.pngData()!)
                
                // Original url
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(original)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(originalURL)".data(using: .utf8)!)
                
                
                // End request data
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                self.session.uploadTask(with: request, from: data) { (postData, postResponse, postError) in
                    
                    // This will run when the network request returns
                    if let postError = postError {
                        print(postError.localizedDescription)
                    } else if let postData = postData {
                        let postDictionary = try! JSONSerialization.jsonObject(with: postData, options: []) as! [String: String]
                        
                        // Call the completion handler on the main thread
                        OperationQueue.main.addOperation {
                            completion(postDictionary)
                        }
                    }
                }.resume()
            }
        }.resume()
        
    }
    
}
