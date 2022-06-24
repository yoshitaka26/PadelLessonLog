//
//  MainTabBarController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/02/07.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lessonImageVC = LessonImageViewController.makeInstance(dependency: .init(viewModel: LessonImageViewModel(dependency: .init(coreDataProtocol: CoreDataManager.shared))))
        let lessonDataVC = LessonDataViewController.makeInstance(dependency: .init(viewModel: LessonDataViewModel(dependency: .init(coreDataProtocol: CoreDataManager.shared))))
        self.viewControllers = [lessonImageVC, lessonDataVC]
    }
}
