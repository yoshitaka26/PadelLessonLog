//
//  ImageViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

final class ImageViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    var lesson: Lesson?
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = R.string.localizable.imageView()
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage.chevronBackwardCircle, select: #selector(back))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let safeLesson = lesson else { return }
        imageView.image = safeLesson.getImage()
    }
    
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
}
