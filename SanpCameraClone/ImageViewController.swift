//
//  ImageViewController.swift
//  SanpCameraClone
//
//  Created by Michael Budd on 1/5/18.
//  Copyright © 2018 Michael Budd. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    
    
}
