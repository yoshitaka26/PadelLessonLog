//
//  ImageCollectionViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var lessonImageView: UIImageView!
    var lesson: Lesson?
    var row: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setLessonData(lesson: Lesson, row: Int) {
        self.lesson = lesson
        titleLabel.text = lesson.title
        lessonImageView.contentMode = .scaleAspectFit
        if lesson.imageSaved {
            lessonImageView.image = lesson.getImage()
        } else {
            // こっちには来ないはずだけど、念の為残しておく
            lessonImageView.image = UIImage(named: "img_no_court")
        }

        self.row = row
    }
}
