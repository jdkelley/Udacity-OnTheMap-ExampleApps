//
//  ViewController.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var phraseSearchButton: UIButton!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latLonSearchButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phraseTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        // FIX: As of Swift 2.2, using strings for selectors has been deprecated. Instead, #selector(methodName) should be used.
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Search Actions
    
    @IBAction func searchByPhrase(sender: AnyObject) {

        userDidTapView(self)
        setUIEnabled(false)
        
        if !phraseTextField.text!.isEmpty {
            photoTitleLabel.text = "Searching Text..."
            // TODO: Set necessary parameters!
            let methodParameters: [String: String!] = [
                Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParameterValues.DisableJSONCallback,
                Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.Text : phraseTextField.text!
            ]
            print("Method Parameters: \(methodParameters)")
            displayImageFromFlickrBySearch(methodParameters)
        } else {
            setUIEnabled(true)
            photoTitleLabel.text = "Phrase Empty."
        }
    }
    
    @IBAction func searchByLatLon(sender: AnyObject) {

        userDidTapView(self)
        setUIEnabled(false)
        
        if isTextFieldValid(latitudeTextField, forRange: Constants.Flickr.SearchLatRange) && isTextFieldValid(longitudeTextField, forRange: Constants.Flickr.SearchLonRange) {
            photoTitleLabel.text = "Searching..."
            // TODO: Set necessary parameters!
            let methodParameters: [String: String!] = [
                Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParameterValues.DisableJSONCallback,
                Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.BoundingBox : bboxString()
            ]
            displayImageFromFlickrBySearch(methodParameters)
        }
        else {
            setUIEnabled(true)
            photoTitleLabel.text = "Lat should be [-90, 90].\nLon should be [-180, 180]."
        }
    }
    
    private func bboxString() -> String {
        guard   let latitude = Double(latitudeTextField.text!),
                let longitude = Double(longitudeTextField.text!)
            else {
            return "0,0,0,0"
        }
        let minLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight,Constants.Flickr.SearchLatRange.0)
        let maxLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth,Constants.Flickr.SearchLonRange.1)
        let maxLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber: Int = -1) {
        let url = flickrURLFromParameters(methodParameters)
        print(url)
        let request = NSURLRequest(URL: url)
        
        _ = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                print("URL at the time of error \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.photoImageView.image = nil
                    self.photoTitleLabel.text = "No Photo returned. Try Again!"
                }
            }
            
            guard error == nil else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                displayError("Your request returned something other than 2xx!")
                return
            }
            
            guard let data = data else {
                displayError("No Data was returned from your request!")
                return
            }
            
            let parsedJSON: AnyObject!
            do {
                parsedJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let status = parsedJSON[Constants.FlickrResponseKeys.Status] as? String where status == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API Returned an error. See error Code and message in \(parsedJSON)")
                return
            }
            
            //print("JSON: \(parsedJSON)")
            
            guard   let photosResult = parsedJSON[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
                    let numberOfPages = photosResult[Constants.FlickrResponseKeys.Pages] as? Int,
                    let photoDicts = photosResult[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] where photoDicts.count > 0
                    else {
                    displayError("Could not find url of a photo in list of search results: \(parsedJSON)")
                        return
            }
            
            
            if withPageNumber == -1 {
                let pageLimit = min(numberOfPages, 40)
                let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                var params = methodParameters
                params[Constants.FlickrParameterKeys.Page] = randomPageNumber
                self.displayImageFromFlickrBySearch(params, withPageNumber: randomPageNumber)
            } else {
                let photo = photoDicts[Int(arc4random_uniform(UInt32(photoDicts.count)))]
                guard   let randomPhotoURLString = photo[Constants.FlickrResponseKeys.MediumURL] as? String,
                    let imageTitle = photo[Constants.FlickrResponseKeys.Title] as? String,
                    let imageURL = NSURL(string: randomPhotoURLString),
                    let imageData = NSData(contentsOfURL: imageURL) else {
                        displayError("Could not find image or title in returned results: \(photoDicts)")
                        return
                }
                
                performUIUpdatesOnMain {
                    self.photoImageView.image = UIImage(data: imageData)
                    self.photoTitleLabel.text = imageTitle
                    self.setUIEnabled(true)
                }
            }
            
            
            
            
        }.resume()
        
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}

// MARK: - ViewController: UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(phraseTextField)
        resignIfFirstResponder(latitudeTextField)
        resignIfFirstResponder(longitudeTextField)
    }
    
    // MARK: TextField Validation
    
    private func isTextFieldValid(textField: UITextField, forRange: (Double, Double)) -> Bool {
        if let value = Double(textField.text!) where !textField.text!.isEmpty {
            return isValueInRange(value, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    private func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
}

// MARK: - ViewController (Configure UI)

extension ViewController {
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        phraseTextField.enabled = enabled
        latitudeTextField.enabled = enabled
        longitudeTextField.enabled = enabled
        phraseSearchButton.enabled = enabled
        latLonSearchButton.enabled = enabled
        
        // adjust search button alphas
        if enabled {
            phraseSearchButton.alpha = 1.0
            latLonSearchButton.alpha = 1.0
        } else {
            phraseSearchButton.alpha = 0.5
            latLonSearchButton.alpha = 0.5
        }
    }
}

// MARK: - ViewController (Notifications)

extension ViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}