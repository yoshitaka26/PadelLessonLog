//
//  DetailViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/04.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(_ detailViewController: DetailViewController, didSelectEdit lesson: Lesson)
}

final class DetailViewController: BaseViewController {

    @IBOutlet private weak var stepTableView: UITableView!
    @IBOutlet private weak var lessonTitleLabel: UILabel!
    @IBOutlet private weak var imageButton: UIButton!
    var lessonData: Lesson?
    
    private let viewModel = DetailViewModel()
    weak var delegate: DetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepTableView.delegate = self
        stepTableView.dataSource = self
        stepTableView.tableFooterView = UIView()

        navigationItem.title = R.string.localizable.detail()
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage.chevronBackwardCircle, select: #selector(back))
        navigationItem.rightBarButtonItem = createBarButtonItem(image: UIImage.pencilTipCropCircleBadgePlus, select: #selector(edit))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.lessonData.send(lessonData)
    }
    
    override func bind() {
        viewModel.loadView.sink { [weak self] lesson in
            guard let self = self else { return }
            self.lessonTitleLabel.text = lesson.title
            self.imageButton.isHidden = !lesson.imageSaved
            self.stepTableView.reloadData()
        }.store(in: &subscriptions)
        
        viewModel.transition.sink { [weak self] transition in
            guard let self = self else { return }
            switch transition {
            case let .imageView(_lessonData):
                guard let vc = R.storyboard.imageView.imageView() else { return }
                vc.lesson = _lessonData
                self.navigationController?.pushViewController(vc, animated: true)
            case let .editView(_lessonData):
                self.dismiss(animated: true) {
                    self.delegate?.detailViewController(self, didSelectEdit: _lessonData)
                }
            case .back:
                self.dismiss(animated: true)
            }
        }.store(in: &subscriptions)
    }
    
    @IBAction private func imageButtonPressed(_ sender: UIButton) {
        viewModel.imageViewButtonPressed.send()
    }
    @objc
    func back() {
        self.viewModel.backButtonPressed.send()
    }
    @objc
    func edit() {
        self.viewModel.editViewButtonPressed.send()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewCellData.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.detailCell, for: indexPath)! // swiftlint:disable:this force_unwrapping
        let stepLabel = cell.contentView.viewWithTag(1) as! UILabel
        for step in viewModel.tableViewCellData.value where step.orderNum == indexPath.row {
            stepLabel.text = step.explication
        }
        return cell
    }
}
