//
//  AddNewImageViewController.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import UIKit
import Sketch

final class AddNewImageViewController: BaseViewController {

    @IBOutlet private weak var sketchView: SketchView!
    @IBOutlet private weak var customToolbar: UIToolbar!
    
    private var viewModel = AddNewImageViewModel()
    
    private var coreDataMangaer = CoreDataManager.shared
    var lessonID: String?
    var lessonImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolbar()
        navigationItem.title = R.string.localizable.drawView()
        navigationItem.leftBarButtonItem = createBarButtonItem(image: UIImage.chevronBackwardCircle, select: #selector(back))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = lessonID, let image = lessonImage else { return }
        viewModel.loadLessonImageData.send((id, image))
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIGraphicsBeginImageContextWithOptions(sketchView.frame.size, false, 0.0)
        guard let graphicsGetCurrentContext = UIGraphicsGetCurrentContext() else { return }
        graphicsGetCurrentContext.interpolationQuality = .high
    }
    
    override func bind() {
        viewModel.lessonImage.sink { [weak self] image in
            guard let self = self else { return }
            guard let lessonImage = image else { return }
            self.sketchView.loadImage(image: lessonImage, drawMode: .scale)
        }.store(in: &subscriptions)
        
        viewModel.toolType.sink { [weak self] tooType in
            guard let self = self else { return }
            self.sketchView.drawTool = tooType
        }.store(in: &subscriptions)
        
        viewModel.penType.sink { [weak self] penType in
            guard let self = self else { return }
            self.sketchView.drawingPenType = penType
        }.store(in: &subscriptions)
        
        viewModel.lineColor.sink { [weak self] lineColor in
            guard let self = self else { return }
            self.sketchView.lineColor = lineColor
        }.store(in: &subscriptions)
        
        viewModel.lineAlpha.sink { [weak self] lineAlpha in
            guard let self = self else { return }
            self.sketchView.lineAlpha = lineAlpha
        }.store(in: &subscriptions)
        
        viewModel.lineWidth.sink { [weak self] lineWidth in
            guard let self = self else { return }
            self.sketchView.lineWidth = lineWidth
        }.store(in: &subscriptions)
        
        viewModel.stampImage.sink { [weak self] stampImage in
            guard let self = self else { return }
            self.sketchView.stampImage = stampImage
        }.store(in: &subscriptions)
        
        viewModel.action.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case let .colorTableShow(color):
                guard let colorTableVC = R.storyboard.colorTable.colorTable() else { return }
                colorTableVC.delegate = self
                colorTableVC.objectColor = color
                let screenSize = UIScreen.main.bounds.size
                self.openPopUpController(popUpController: colorTableVC, sourceView: self.customToolbar, rect: CGRect(x: screenSize.width / 3.2, y: 0, width: screenSize.width / 3, height: screenSize.height / 5), arrowDirections: .down, canOverlapSourceViewRect: true)
            case let .objectTableShow(object):
                guard let objectTableVC = R.storyboard.objectTable.objectTable() else { return }
                objectTableVC.delegate = self
                objectTableVC.objectType = object
                let screenSize = UIScreen.main.bounds.size
                self.openPopUpController(popUpController: objectTableVC, sourceView: self.customToolbar, rect: CGRect(x: screenSize.width / 8.3, y: 0, width: screenSize.width / 3, height: screenSize.height / 4), arrowDirections: .down, canOverlapSourceViewRect: true)
            case .undo:
                self.sketchView.undo()
            case .saved:
                self.navigationController?.popViewController(animated: true)
            case .back:
                self.navigationController?.popViewController(animated: true)
            }
        }.store(in: &subscriptions)
        
        viewModel.imageSaveError.sink { [weak self] _ in
            guard let self = self else { return }
            self.warningAlertView(withTitle: R.string.localizable.dataProcessingError())
        }.store(in: &subscriptions)
    }
    
    func configureToolbar() {
        customToolbar.isTranslucent = false
        customToolbar.barTintColor = UIColor.lightGray
        customToolbar.barStyle = .default
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var buttonItems: [UIBarButtonItem] = []
        
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveButtonItem.tintColor = .black
        buttonItems.append(saveButtonItem)
        buttonItems.append(flexibleSpace)
        buttonItems.append(flexibleSpace)
        let undoButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: #selector(undo))
        undoButtonItem.tintColor = .black
        buttonItems.append(undoButtonItem)
        buttonItems.append(flexibleSpace)
        let objectButtonItem = UIBarButtonItem(image: UIImage(systemName: "hand.draw"), style: .plain, target: self, action: #selector(objectTable))
        objectButtonItem.tintColor = .black
        buttonItems.append(objectButtonItem)
        buttonItems.append(flexibleSpace)
        let colorButtonItem = UIBarButtonItem(image: UIImage(systemName: "paintpalette"), style: .plain, target: self, action: #selector(colorTable))
        colorButtonItem.tintColor = .black
        buttonItems.append(colorButtonItem)
        buttonItems.append(flexibleSpace)

        customToolbar.setItems(buttonItems, animated: true)
    }
    
    @objc
    func back() {
        viewModel.backButtonPressed.send()
    }
    @objc
    func save() {
        let size = sketchView.frame
        sketchView.draw(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let savingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        viewModel.saveButtonPressed.send(savingImage)
    }
    @objc
    func undo() {
        viewModel.undoButtonPressed.send()
        sketchView.undo()
    }
    @objc
    func colorTable() {
        viewModel.colorTableButtonPressed.send()
    }
    @objc
    func objectTable() {
        viewModel.objectTableButtonPressed.send()
    }
}

extension AddNewImageViewController: ColorTableViewControllerDelegate {
    func ColorTableViewController(colorTableViewController: ColorTableViewController, didSelectColor: ObjectColor) {
        viewModel.didSelectColor.send(didSelectColor)
        colorTableViewController.dismiss(animated: true)
    }
}

extension AddNewImageViewController: ObjectTableViewControllerDelegate {
    func ObjectTableViewController(objectTableViewController: ObjectTableViewController, didSelectObject: ObjectType) {
        viewModel.didSelectObject.send(didSelectObject)
        objectTableViewController.dismiss(animated: true)
    }
}
