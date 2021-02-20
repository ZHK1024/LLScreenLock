//
//  LLNavigationController.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/18.
//  
//

import UIKit

class LLNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
    }
}
