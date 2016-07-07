//
//  GCD+Helpers.swift
//  FlickFinder
//
//  Created by Joshua Kelley on 7/6/16.
//  Copyright © 2016 Joshua Kelley. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}