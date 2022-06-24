//
//  NewLessonViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

protocol NewLessonViewControllerDelegate: AnyObject {
    func didSaveLessonData(_ newLessonViewController: NewLessonViewController)
}

final class NewLessonViewController: BaseViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageLabel: UILabel!
    @IBOutlet private weak var stepLabel: UILabel!
    
    @IBOutlet private weak var lessonNameTextField: UITextField!
    @IBOutlet private weak var addImageButton: UIButton!
    @IBOutlet private weak var editImageButton: UIButton!
    @IBOutlet private weak var addStepButton: UIButton!
    @IBOutlet private weak var editStepButton: UIButton!
    
    @IBOutlet private var mainTableView: UITableView!
    @IBOutlet private var imageButtonsAreaView: UIView!
    
    private let viewModel = NewLessonViewModel()
    private var coreDataMangaer = CoreDataManager.shared
    
    var lessonData: Lesson?

    weak var delegate: NewLessonViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeLabels()
        lessonNameTextField.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(R.nib.stepTableViewCell)
        
        mainTableView.tableFooterView = UIView()
        addImageButton.isSelected = false
        editImageButton.isHidden = true
        
        lessonNameTextField.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationItem.leftBarButtonItem = self.createBarButtonItem(image: UIImage.trashCircle, select: #selector(deleteData), color: .red)
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(image: UIImage.checkmarkCircle, select: #selector(save))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.lessonData.send(lessonData)
    }
    
    override func bind() {
        viewModel.lessonTitleText
            .assign(to: \.text, on: lessonNameTextField)
            .store(in: &subscriptions)
        
        viewModel.loadView.sink { [weak self] _ in
            guard let self = self else { return }
            self.mainTableView.reloadData()
        }.store(in: &subscriptions)
        
        viewModel.imageButtonIsOn.sink { [weak self] isOn in
            guard let self = self else { return }
            self.addImageButton.isSelected = isOn
            self.addImageButton.tintColor = isOn ? .systemRed : .systemBlue
        }.store(in: &subscriptions)
        
        viewModel.editImageButtonIsHidden
            .assign(to: \.isHidden, on: editImageButton)
            .store(in: &subscriptions)
        
        viewModel.editStepButtonIsOn.sink { [weak self] isOn in
            guard let self = self else { return }
            self.editStepButton.isSelected = isOn
            self.mainTableView.setEditing(isOn, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.showAlert.sink { [weak self] alert in
            guard let self = self else { return }
            switch alert {
            case .deleteImage:
                self.destructiveAlertView(withTitle: R.string.localizable.areYouSure(), cancelString: R.string.localizable.cancel(), destructiveString: R.string.localizable.delete()) {
                    self.viewModel.deleteImageConfirmed.send()
                }
            case .titleEmpty:
                self.warningAlertView(withTitle: R.string.localizable.theTitleIsBlank())
            case .titleStringCountOver:
                self.warningAlertView(withTitle: R.string.localizable.theNumberOfCharactersIsExceeded())
            case .dataProcessingError:
                self.warningAlertView(withTitle: R.string.localizable.dataProcessingError())
            }
        }.store(in: &subscriptions)
        
        viewModel.imageDeleted.sink { [weak self] _ in
            guard let self = self else { return }
            self.infoAlertViewWithTitle(title: R.string.localizable.imageDeleted())
        }.store(in: &subscriptions)
        
        viewModel.dataDeleted.sink { [weak self] _ in
            guard let self = self else { return }
            self.infoAlertViewWithTitle(title: R.string.localizable.dataDeleted(), message: "") {
                self.viewModel.transition.send(.deleted)
            }
        }.store(in: &subscriptions)
        
        viewModel.dataSaved.sink { [weak self] _ in
            guard let self = self else { return }
            self.infoAlertViewWithTitle(title: R.string.localizable.dataSaved(), message: "") {
                self.viewModel.transition.send(.saved)
            }
        }.store(in: &subscriptions)
        
        viewModel.scrollStepTable.sink { [weak self] _ in
            guard let self = self else { return }
            self.mainTableView.scrollToRow(at: IndexPath(row: self.viewModel.lessonStepData.value.count - 1, section: 0), at: .top, animated: true)
        }.store(in: &subscriptions)
        
        viewModel.transition.sink { [weak self] transition in
            guard let self = self else { return }
            switch transition {
            case let .addEditImage(lesson):
                guard let id = lesson.id else { return }
                guard let addNewImageVC = R.storyboard.addNewImage.addNewImage() else { return }
                addNewImageVC.lessonImage = lesson.getImage()
                addNewImageVC.lessonID = id.uuidString
                self.navigationController?.pushViewController(addNewImageVC, animated: true)
            case .saved:
                guard let safeDelegate = self.delegate else { return }
                safeDelegate.didSaveLessonData(self)
                self.navigationController?.popViewController(animated: true)
            case .deleted:
                self.navigationController?.popViewController(animated: true)
            }
        }.store(in: &subscriptions)
    }
    private func localizeLabels() {
        titleLabel.text = R.string.localizable.title()
        imageLabel.text = R.string.localizable.image()
        stepLabel.text = R.string.localizable.steps()
        addImageButton.setTitle(R.string.localizable.addImage(), for: .normal)
        addImageButton.setTitle(R.string.localizable.delete(), for: .selected)
        editImageButton.setTitle(R.string.localizable.editImage(), for: .normal)
        addStepButton.setTitle(R.string.localizable.addStep(), for: .normal)
        editStepButton.setTitle(R.string.localizable.edit(), for: .normal)
        editStepButton.setTitle(R.string.localizable.done(), for: .selected)
        lessonNameTextField.placeholder = R.string.localizable.pleaseEnterATitle()
    }

    @IBAction private func addImageButtonPressed(_ sender: UIButton) {
        viewModel.imageButtonPressed.send(sender.isSelected)
    }
    @IBAction private func editImageButtonPressed(_ sender: UIButton) {
        viewModel.editImageButtonPressed.send()
    }
    @IBAction private func addStepButtonPressed(_ sender: UIButton) {
        viewModel.addStepButtonPressed.send()
    }
    @IBAction private func editStepButtonPressed(_ sender: UIButton) {
        viewModel.editStepButtonPressed.send(sender.isSelected)
    }
    @objc
    func deleteData() {
        destructiveAlertView(withTitle: R.string.localizable.dataWillBeDeleted(), cancelString: R.string.localizable.cancel(), destructiveString: R.string.localizable.delete()) {
            self.viewModel.deleteData.send()
        }
    }
    @objc
    func save() {
        self.viewModel.textFieldDidEndEditing.send(lessonNameTextField.text)
        viewModel.saveData.send()
    }
    
    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            mainTableView.contentInset = .zero
        } else {
            mainTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        mainTableView.scrollIndicatorInsets = mainTableView.contentInset
    }
}

extension NewLessonViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.viewModel.textFieldDidEndEditing.send(textField.text)
    }
}

extension NewLessonViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lessonStepData.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.stepTableViewCell, for: indexPath)! // swiftlint:disable:this force_unwrapping
        cell.delegate = self
        if let step = viewModel.lessonStepData.value.first(where: { $0.orderNum == indexPath.row }) {
            cell.setup(index: indexPath.row, stepData: step)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.lessonStepDidDelete.send(indexPath)
    }
}

extension NewLessonViewController: StepTableViewCellDelegate {
    func stepTableViewCell(_ stepTableViewCell: StepTableViewCell, willEditTextForRowAt: Int?) {
        guard let cellIndex = willEditTextForRowAt else { return }
        mainTableView.scrollToRow(at: IndexPath(row: cellIndex, section: 0), at: .top, animated: true)
        guard let view = imageButtonsAreaView else { return }
        view.isHidden = true
    }
    func stepTableViewCell(_ stepTableViewCell: StepTableViewCell, didEditText newText: String) {
        guard let lessonStep = stepTableViewCell.stepData else { return }
        viewModel.lessonStepDidEndEditing.send((lessonStep, newText))
        guard let view = imageButtonsAreaView else { return }
        view.isHidden = false
    }
}
