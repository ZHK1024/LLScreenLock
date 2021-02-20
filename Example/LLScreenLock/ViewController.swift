//
//  ViewController.swift
//  LLScreenLock
//
//  Created by Ruris on 02/07/2021.
//  Copyright (c) 2021 Ruris. All rights reserved.
//

import UIKit
import LLScreenLock

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let titles: [String] = [
        "手势解锁", "手势新建", "手势重置", "关闭手势锁"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LLScreenLock.repeatable = false
//        Workflow()
//            .draw {
//                print($0)
//            }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard LLScreenLock.gestureLockIsOpen || indexPath.row == 1 else {
            print("gestureLockIsOpen: false")
            return
        }
        switch indexPath.row {
        case 0:
            LLScreenLock.lock(.unlock, type: .biometrics)
        case 1:
            LLScreenLock.lock(.new, type: .all, target: navigationController)
        case 2:
            LLScreenLock.lock(.reset, type: .all, target: navigationController)
        case 3:
            LLScreenLock.lock(.close, type: .all, target: navigationController)
        default:
            break
        }
    }
}
