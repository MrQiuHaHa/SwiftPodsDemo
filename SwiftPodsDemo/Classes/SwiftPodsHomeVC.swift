//
//  SwiftPodsHomeVC.swift
//  Pods
//
//  Created by 邱俊荣 on 2020/5/18.
//

import Foundation

import UIKit
import BaiduMapAPI_Map

public class SwiftPodsHomeVC: UIViewController, BMKGeneralDelegate {

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        
        let mapManager = BMKMapManager()
        // 启动引擎并设置AK并设置delegate
        if !(mapManager.start("启动引擎失败", generalDelegate: self)) {
//            NSLog("启动引擎失败")
        }
    }
}
