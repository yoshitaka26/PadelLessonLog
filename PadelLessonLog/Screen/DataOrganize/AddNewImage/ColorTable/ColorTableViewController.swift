//
//  ColorTableViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/10.
//

import UIKit

enum ObjectColor: Int {
    case black = 0, yellow, red, blue

    func toColor() -> UIColor {
        switch self {
        case .black:
            return UIColor.black
        case .red:
            return UIColor.systemRed
        case .yellow:
            return UIColor.systemYellow
        case .blue:
            return UIColor.systemBlue
        }
    }

    static func defaultValue() -> ObjectColor {
        return ObjectColor.black
    }
}

protocol ColorTableViewControllerDelegate: AnyObject {
    func ColorTableViewController(colorTableViewController: ColorTableViewController, didSelectColor: ObjectColor)
}

final class ColorTableViewController: UITableViewController {
    
    weak var delegate: ColorTableViewControllerDelegate?
    var objectColor = ObjectColor.defaultValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let row = objectColor.rawValue as Int
        
        cell.accessoryType = indexPath.row == row ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedColor = ObjectColor(rawValue: indexPath.row) {
            delegate?.ColorTableViewController(colorTableViewController: self, didSelectColor: selectedColor)
        }
    }
}
