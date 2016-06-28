//
//  ViewController.swift
//  FatImages
//
//  Created by Joshua Kelley on 6/28/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import UIKit

enum BigImage: String {
    case whale = "https://lh3.googleusercontent.com/16zRJrj3ae3G4kCDO9CeTHj_dyhCvQsUDU0VF0nZqHPGueg9A9ykdXTc6ds0TkgoE1eaNW-SLKlVrwDDZPE=s0#w=4800&h=3567"
    case shark = "https://lh3.googleusercontent.com/BCoVLCGTcWErtKbD9Nx7vNKlQ0R3RDsBpOa8iA70mGW2XcC76jKS09pDX_Rad6rjyXQCxngEYi3Sy3uJgd99=s0#w=4713&h=3846"
    case seaLion = "https://lh3.googleusercontent.com/ibcT9pm_NEdh9jDiKnq0NGuV2yrl5UkVxu-7LbhMjnzhD84mC6hfaNlb-Ht0phXKH4TtLxi12zheyNEezA=s0#w=4626&h=3701"
}

class ViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    
    @IBAction func synchronousDownload(sender: UIBarButtonItem) {
        
        let url = NSURL(string: BigImage.seaLion.rawValue)
        
        let imageData = NSData(contentsOfURL: url!)
        
        let image = UIImage(data: imageData!)
        
        photoView.image = image
        
    }
    
    @IBAction func simpleAsyncronousDownload(sender: UIBarButtonItem) {
        //
    }
    
    @IBAction func asynchronousDownload(sender: UIBarButtonItem) {
        // <#Code#>
    }
    
    @IBAction func setTransparencyOfImage(sender: UISlider) {
        photoView.alpha = CGFloat(sender.value)
    }

}

