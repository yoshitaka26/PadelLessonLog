//
//  ObjectTableViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/10.
//

import UIKit

enum ObjectType: Int {
    case pen = 0, line, arrow, ball, pin, rect, fill

    static func defaultValue() -> ObjectType {
        return ObjectType.pen
    }
}

protocol ObjectTableViewControllerDelegate: AnyObject {
    func ObjectTableViewController(objectTableViewController: ObjectTableViewController, didSelectObject: ObjectType)
}

final class ObjectTableViewController: UITableViewController {
    
    weak var delegate: ObjectTableViewControllerDelegate?
    var objectType = ObjectType.defaultValue()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let row = objectType.rawValue as Int
        
        cell.accessoryType = indexPath.row == row ? .checkmark : .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedObject = ObjectType(rawValue: indexPath.row) {
            delegate?.ObjectTableViewController(objectTableViewController: self, didSelectObject: selectedObject)
        }
    }
}
