//
//  StepTableViewCell.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

protocol StepTableViewCellDelegate: AnyObject {
    func stepTableViewCell(_ stepTableViewCell: StepTableViewCell, didEditText newText: String)
    func stepTableViewCell(_ stepTableViewCell: StepTableViewCell, willEditTextForRowAt: Int?)
}

final class StepTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet private weak var cellLabel: UILabel!
    @IBOutlet private  weak var stepTextView: UITextView! {
        didSet {
            stepTextView.delegate = self
        }
    }
    
    var index: Int?
    var stepData: LessonStep?
    weak var delegate: StepTableViewCellDelegate?
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.stepTableViewCell(self, willEditTextForRowAt: index)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.stepTableViewCell(self, didEditText: stepTextView.text)
    }

    func setup(index: Int, stepData: LessonStep) {
        self.stepData = stepData
        self.index = index
        cellLabel.text = String(index + 1)
        stepTextView.text = stepData.explication
    }
}
