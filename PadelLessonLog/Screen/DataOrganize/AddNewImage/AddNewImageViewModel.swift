//
//  AddNewImageViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/08.
//

import Foundation
import Sketch
import Combine

enum AddNewImageViewAction {
    case colorTableShow(ObjectColor)
    case objectTableShow(ObjectType)
    case undo
    case saved
    case back
}

final class AddNewImageViewModel: BaseViewModel {
    
    let colorTableButtonPressed = PassthroughSubject<Void, Never>()
    let objectTableButtonPressed = PassthroughSubject<Void, Never>()
    let undoButtonPressed = PassthroughSubject<Void, Never>()
    let saveButtonPressed = PassthroughSubject<UIImage?, Never>()
    let backButtonPressed = PassthroughSubject<Void, Never>()
    
    let didSelectColor = PassthroughSubject<ObjectColor, Never>()
    let didSelectObject = PassthroughSubject<ObjectType, Never>()
    
    let loadLessonImageData = PassthroughSubject<(String, UIImage), Never>()
    private(set) var  lessonID = CurrentValueSubject<String?, Never>(nil)
    private(set) var  lessonImage = CurrentValueSubject<UIImage?, Never>(nil)
    
    private(set) var objectColor = CurrentValueSubject<ObjectColor, Never>(.black)
    private(set) var objectType = CurrentValueSubject<ObjectType, Never>(.pen)
    
    private(set) var toolType = CurrentValueSubject<SketchToolType, Never>(.pen)
    private(set) var penType = CurrentValueSubject<PenType, Never>(.normal)
    private(set) var lineColor = CurrentValueSubject<UIColor, Never>(.black)
    private(set) var lineAlpha = CurrentValueSubject<CGFloat, Never>(1)
    private(set) var lineWidth = CurrentValueSubject<CGFloat, Never>(4)
    private(set) var stampMode = CurrentValueSubject<Bool, Never>(true)
    private(set) var stampImage = CurrentValueSubject<UIImage?, Never>(nil)
    
    private(set) var action = PassthroughSubject<AddNewImageViewAction, Never>()
    
    private(set) var imageSaveError = PassthroughSubject<Void, Never>()
    
    private var coreDataManager = CoreDataManager.shared
    
    override init() {
        super.init()
        mutate()
    }
    
    func mutate() {
        loadLessonImageData.sink { [weak self] id, image in
            guard let self = self else { return }
            self.lessonID.send(id)
            self.lessonImage.send(image)
        }.store(in: &subscriptions)
        
        colorTableButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.action.send(.colorTableShow(self.objectColor.value))
        }.store(in: &subscriptions)
        
        objectTableButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.action.send(.objectTableShow(self.objectType.value))
        }.store(in: &subscriptions)
        
        undoButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.action.send(.undo)
        }.store(in: &subscriptions)
        
        saveButtonPressed.sink { [weak self] savingImage in
            guard let self = self else { return }
            guard let id = self.lessonID.value else { return }
            guard let image = savingImage else { return }
            let isSaved = self.coreDataManager.updateLessonImage(lessonID: id, image: image)
            if isSaved {
                self.action.send(.saved)
            } else {
                assertionFailure("画像が更新できない")
                self.imageSaveError.send()
            }
        }.store(in: &subscriptions)
        
        backButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.action.send(.back)
        }.store(in: &subscriptions)
        
        stampMode.sink { [weak self] value in
            guard let self = self else { return }
            switch self.lineColor.value {
            case .black:
                self.stampImage.send(value ? R.image.img_ball_black(compatibleWith: .current) : R.image.img_pin_black(compatibleWith: .current))
            case .yellow:
                self.stampImage.send(value ? R.image.img_ball_yellow(compatibleWith: .current) : R.image.img_pin_yellow(compatibleWith: .current))
            case .blue:
                self.stampImage.send(value ? R.image.img_ball_blue(compatibleWith: .current) : R.image.img_pin_blue(compatibleWith: .current))
            case .red:
                self.stampImage.send(value ? R.image.img_ball_red(compatibleWith: .current) : R.image.img_pin_red(compatibleWith: .current))
            default:
                break
            }
        }.store(in: &subscriptions)
        
        didSelectColor.sink { [weak self] color in
            guard let self = self else { return }
            self.objectColor.send(color)
            switch color {
            case .black:
                self.lineColor.send(.black)
                self.stampImage.send(self.stampMode.value ? R.image.img_ball_black(compatibleWith: .current) : R.image.img_pin_black(compatibleWith: .current))
            case .yellow:
                self.lineColor.send(.yellow)
                self.stampImage.send(self.stampMode.value ? R.image.img_ball_yellow(compatibleWith: .current) : R.image.img_pin_yellow(compatibleWith: .current))
            case .blue:
                self.lineColor.send(.blue)
                self.stampImage.send(self.stampMode.value ? R.image.img_ball_blue(compatibleWith: .current) : R.image.img_pin_blue(compatibleWith: .current))
            case .red:
                self.lineColor.send(.red)
                self.stampImage.send(self.stampMode.value ? R.image.img_ball_red(compatibleWith: .current) : R.image.img_pin_red(compatibleWith: .current))
            }
        }.store(in: &subscriptions)
        
        didSelectObject.sink { [weak self] object in
            guard let self = self else { return }
            self.objectType.send(object)
            switch object {
            case .pen:
                self.toolType.send(.pen)
                self.penType.send(.normal)
                self.lineAlpha.send(1)
                self.lineWidth.send(4)
            case .line:
                self.toolType.send(.line)
                self.lineAlpha.send(0.8)
                self.lineWidth.send(4)
            case .arrow:
                self.toolType.send(.arrow)
                self.lineAlpha.send(0.8)
                self.lineWidth.send(4)
            case .ball:
                self.toolType.send(.stamp)
                self.stampMode.send(true)
            case .pin:
                self.toolType.send(.stamp)
                self.stampMode.send(false)
            case .rect:
                self.toolType.send(.rectangleFill)
                self.lineAlpha.send(0.3)
                self.lineWidth.send(2)
            case .fill:
                self.toolType.send(.fill)
            }
        }.store(in: &subscriptions)
    }
}
