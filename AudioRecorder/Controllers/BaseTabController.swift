//
//  BaseTabController.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit
import AVFoundation

protocol SessionFlowDelegate: class {
    func startRecording()
    func startPlaying()
    func stoppedRecording()
}

final class BaseTabController: UITabBarController {
    
    // MARK:- Properties
    private let listController = ListController()
    private let recordController = RecordController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listController.delegate = self
        recordController.delegate = self
        tabBar.tintColor = .black
        viewControllers = [
            createNavController(viewController: listController, title: "Records", image: #imageLiteral(resourceName: "collection")),
            createNavController(viewController: recordController, title: "New Record", image: #imageLiteral(resourceName: "record"))
        ]
    }
    
    // MARK:- Private Methods
    private func createNavController(viewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: viewController)
        if #available(iOS 11, *) {
            navController.navigationBar.prefersLargeTitles = true
        }
        viewController.navigationItem.title = title
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return navController
    }
}

// MARK:- Extension
extension BaseTabController: SessionFlowDelegate {
    func startRecording() {
        listController.sessionHasChanged()
    }
    
    func stoppedRecording() {
        listController.getRecords()
    }
    
    func startPlaying() {
        recordController.sessionHasChanged()
    }
}
