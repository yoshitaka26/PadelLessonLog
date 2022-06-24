//
//  InfoAlertView.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/10.
//

import UIKit

class InfoAlertView: UIAlertController {
    var afterDismiss: (() -> Void)?
    
    func timerStart() {
        Timer.scheduledTimer(timeInterval: TimeInterval(integerLiteral: 0.8), target: self, selector: #selector(performDismiss), userInfo: nil, repeats: false)
    }
    
    @objc
    func performDismiss(timer: Timer) {
        dismiss(animated: true, completion: afterDismiss)
    }
}
