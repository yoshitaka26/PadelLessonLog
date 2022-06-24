//
//  SettingTableViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/13.
//

import UIKit

final class SettingTableViewController: UITableViewController {
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var licenseLabel: UILabel!
    @IBOutlet private weak var versionTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeLabels()
        // アプリバージョン
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage.chevronBackwardCircle, select: #selector(back))
    }
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
    private func localizeLabels() {
        licenseLabel.text = R.string.localizable.license()
        versionTitleLabel.text = R.string.localizable.version()
    }
}
