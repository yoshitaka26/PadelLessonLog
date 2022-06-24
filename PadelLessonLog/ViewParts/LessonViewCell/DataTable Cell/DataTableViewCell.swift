//
//  DataTableViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/02.
//

import UIKit

final class DataTableViewCell: UITableViewCell {

    @IBOutlet private weak var starButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    var baseLesson: BaseLesson?
    
    func setLessonData(baseLesson: BaseLesson) {
        starButton.isHidden = false
        self.baseLesson = baseLesson
        titleLabel.text = baseLesson.title
        if let lesson = baseLesson as? Lesson {
            starButton.isSelected = lesson.favorite
            starButton.tintColor = lesson.favorite ? .systemYellow : .lightGray
        } else {
            starButton.isHidden = true
        }
    }
    
    @IBAction private func starButtonPressed(_ sender: UIButton) {
        if let lesson = baseLesson as? Lesson {
            lesson.favorite = !starButton.isSelected
            lesson.save()
            starButton.isSelected.toggle()
            starButton.tintColor = lesson.favorite ? .systemYellow : .lightGray
        }
    }
}
