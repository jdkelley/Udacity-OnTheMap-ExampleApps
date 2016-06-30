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
        
    }


}

/*
 
 
 func performUIUpdatesOnMain(updates: () -> Void) {
 dispatch_async(dispatch_get_main_queue()) {
 updates()
 }
 }
 */

