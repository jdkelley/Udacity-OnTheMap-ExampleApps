//
//  GCDBlackBox.swift
//  ImageRequest
//
//  Created by Joshua Kelley on 6/28/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}