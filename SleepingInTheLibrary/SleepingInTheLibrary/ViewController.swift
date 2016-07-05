//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Joshua Kelley on 6/30/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    @IBAction func grabNewImage(sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: - Configure UI
    
    private func setUIEnabled(enabled:Bool) {
        photoTitleLabel.enabled = enabled
        grabImageButton.enabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: - Network Requests
    
    private func getImageFromFlickr() {
        
        let methodParameters = [
            FlickrClient.Parameter.Key.Method           : FlickrClient.Parameter.Value.GalleryPhotosMethod,
            FlickrClient.Parameter.Key.APIKey           : FlickrClient.Parameter.Value.APIKey,
            FlickrClient.Parameter.Key.GalleryID        : FlickrClient.Parameter.Value.ForcedPerspectivesGalleryID, //FlickrClient.Parameter.Value.GalleryID,
            FlickrClient.Parameter.Key.Extras           : FlickrClient.Parameter.Value.MediumURL,
            FlickrClient.Parameter.Key.Format           : FlickrClient.Parameter.Value.ResponseFormat,
            FlickrClient.Parameter.Key.NoJSONCallback   : FlickrClient.Parameter.Value.DisableJSONCallback
                                ]
        
        //let url = NSURL(string: "\(FlickrClient.BaseURL)?\(FlickrClient.Parameter.Key.Method)=\(FlickrClient.Parameter.Value.GalleryPhotosMethod)&\(FlickrClient.Parameter.Key.APIKey)=\(FlickrClient.Parameter.Value.APIKey)&\(FlickrClient.Parameter.Key.GalleryID)=\(FlickrClient.Parameter.Value.GalleryID)&\(FlickrClient.Parameter.Key.Extras)=\(FlickrClient.Parameter.Value.MediumURL)&\(FlickrClient.Parameter.Key.Format)=\(FlickrClient.Parameter.Value.ResponseFormat)&\(FlickrClient.Parameter.Key.NoJSONCallback)=\(FlickrClient.Parameter.Value.DisableJSONCallback)")
        
        let urlString = FlickrClient.BaseURL + escaped(parameters: methodParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                print("URL at the time of error: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
            }
            
            guard error == nil else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                where statusCode >= 200 && statusCode < 300 else {
                    displayError("Your request returned a status code other than 2xx!")
                    return
            }
            
            guard let data = data else {
                displayError("No Data was returned by the request.")
                return
            }

            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult[FlickrClient.Response.Key.Status]
                as? String where stat == FlickrClient.Response.Value.OKStatus
                else {
                    displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
            }
            
            guard let photosDictionary = parsedResult[FlickrClient.Response.Key.Photos] as? [String: AnyObject],
                        photoArray = photosDictionary[FlickrClient.Response.Key.Photo] as? [[String:AnyObject]]  else {
                displayError("Cannot find keys '\(FlickrClient.Response.Key.Photos)' and '\(FlickrClient.Response.Key.Photo)' in \(parsedResult)")
                return
            }
            print(photoArray[0])
            
            // generate random index
            let index = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[index] as [String: AnyObject]
            
            guard   let imageUrlString = photoDictionary[FlickrClient.Response.Key.MediumURL] as? String,
                    let photoTitle = photoDictionary[FlickrClient.Response.Key.Title] as? String else {
                displayError("Cannot find key '\(FlickrClient.Response.Key.Title)' in \(photoDictionary)")
                return
            }
            
            print(imageUrlString)
            print(photoTitle)
            let imageURL = NSURL(string: imageUrlString)
            guard let imageData = NSData(contentsOfURL: imageURL!) else {
                displayError("Error Downloading image data from \(imageURL!)")
                return
            }
            
            performUIUpdatesOnMain {
                self.photoImageView.image = UIImage(data: imageData)
                self.photoTitleLabel.text = photoTitle
                self.setUIEnabled(true)
            }
        }.resume()
    }

    private func escaped(parameters parameters: [String: AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                let stringValue = "\(value)"
                
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
    


}

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}



















