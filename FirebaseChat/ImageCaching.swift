//
//  ImageCaching.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/29/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

class ImageCaching : NSObject {
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func getImageFromCache(key: String) -> UIImage? {
        
        guard let imageFromCache = imageCache.object(forKey: key as AnyObject) as? UIImage else {
            return nil
        }
        return imageFromCache
    }
    
    func updateCache(with key: String, value: UIImage) {
        imageCache.setObject(value, forKey: key as AnyObject)
    }
    
    func getImage(with url: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        if let imageFromCache = getImageFromCache(key: url) {
            completionHandler(imageFromCache)
            return
        }
        
        downloadImage(with: url, completionHandler: completionHandler)
    }
    
    private func downloadImage(with urlString: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            guard isSuccess(error: error) else { return }
            
            guard let image = UIImage(data: data!) else {
                completionHandler(nil)
                return
            }
            
            self.updateCache(with: urlString, value: image)
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
            
        }).resume()
    }
}
