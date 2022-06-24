//
//  UIImageExtension.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/01/21.
//

import UIKit

extension UIImage {
    static let gearshape = UIImage.named("gearshape")
    static let plusCircle = UIImage.named("plus.circle")
    static let trashCircle = UIImage.named("trash.circle")
    static let checkmarkCircle = UIImage.named("checkmark.circle")
    static let chevronBackwardCircle = UIImage.named("chevron.backward.circle")
    static let pencilTipCropCircleBadgePlus = UIImage.named("pencil.tip.crop.circle.badge.plus")
    static let arrowClockwiseCircle = UIImage.named("arrow.clockwise.circle")
    
    static func named(_ name: String) -> UIImage {
        if let image = UIImage(systemName: name) {
            return image
        } else {
            fatalError("Could not initialize \(UIImage.self) named \(name).")
        }
    }
}
