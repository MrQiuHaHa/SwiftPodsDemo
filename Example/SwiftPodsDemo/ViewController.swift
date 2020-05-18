//
//  ViewController.swift
//  SwiftPodsDemo
//
//  Created by 2574282239@qq.com on 05/18/2020.
//  Copyright (c) 2020 2574282239@qq.com. All rights reserved.
//

import UIKit
import SwiftPodsDemo

class ViewController: UIViewController {

    
    lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("点我", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.setTitleColor(UIColor.black, for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 50, height: 20)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
        view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func buttonAction() {
        let vc = SwiftPodsHomeVC()
        self.present(vc, animated: true, completion: nil)
    }
}

