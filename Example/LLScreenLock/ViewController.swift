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
        
        LLScreenLock.repeatable = true
        
        
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
            LLScreenLock.lock(types: [.gesture(.unlock)])
        case 1:
            LLScreenLock.lock(types: [.gesture(.new)])
        case 2:
            LLScreenLock.lock(types: [.gesture(.reset)])
        case 3:
            LLScreenLock.lock(types: [.gesture(.close)])
        default:
            break
        }
    }
}
