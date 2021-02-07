//
//  LLScreenLockViewController.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

public class LLScreenLockViewController: UIViewController {
    
    /// 手势密码视图
    private lazy var gestureLockView = LLGestureLockView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    // MARK: UI
    
    func setupUI() {
        view.addSubview(gestureLockView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.view.layoutSubviews()
        gestureLockView.frame = view.bounds
    }

}
