//
//  ViewController.swift
//  ImageRequest
//
//  Created by Joshua Kelley on 6/28/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageURL = NSURL(string: Constants.PuppyURL)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            print("Task Finished")
            
            if error == nil {
                let downloadedImage = UIImage(data: data!)
                performUIUpdatesOnMain { self.imageView.image = downloadedImage }
            }
        }.resume()
        
    }

}



// Look at NSURL Configuration Class
// look up using NSURL Delegates rather than closures (won't be in this course)