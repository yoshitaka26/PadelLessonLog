//
//  UIViewController+Common.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/10.
//

import UIKit

extension UIViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func createBarButtonItem(image: UIImage, select: Selector?, color: UIColor? = .colorNavBarButton) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.isExclusiveTouch = true
        if let safeSelect = select {
            button.addTarget(self, action: safeSelect, for: .touchDown)
        }
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
    
    func openReplaceWindow(windowNavigation: UIViewController) {
        let selectWindowContentSize = CGSize(width: 400, height: 600)
        let windowRect = CGRect(x: view.center.x, y: 0,
                                width: selectWindowContentSize.width,
                                height: selectWindowContentSize.height)
        windowNavigation.modalPresentationStyle = .popover
        windowNavigation.preferredContentSize = windowRect.size
        windowNavigation.popoverPresentationController?.delegate = self
        windowNavigation.popoverPresentationController?.sourceView = view
        windowNavigation.popoverPresentationController?.sourceRect = windowRect
        windowNavigation.popoverPresentationController?.permittedArrowDirections = []
        windowNavigation.popoverPresentationController?.canOverlapSourceViewRect = false
        present(windowNavigation, animated: true, completion: nil)
    }
    
    func openPopUpController(popUpController: UIViewController, sourceView: UIView, rect: CGRect, arrowDirections: UIPopoverArrowDirection, canOverlapSourceViewRect: Bool) {
        popUpController.modalPresentationStyle = .popover
        popUpController.preferredContentSize = rect.size
        popUpController.popoverPresentationController?.delegate = self
        popUpController.popoverPresentationController?.sourceView = sourceView
        popUpController.popoverPresentationController?.sourceRect = CGRect(x: rect.minX, y: -5, width: sourceView.frame.size.width, height: 0)
        popUpController.popoverPresentationController?.permittedArrowDirections = arrowDirections
        popUpController.popoverPresentationController?.canOverlapSourceViewRect = canOverlapSourceViewRect
        present(popUpController, animated: true, completion: nil)
    }
    
    public func modalToTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            let topViewController = getTopPresentedViewController(rootViewController)
            topViewController.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    public func closeModal() {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            if let presented = rootViewController.presentedViewController {
                presented.dismiss(animated: false, completion: { [weak self] in
                    self?.closeModal()
                })
            }
        }
    }
    
    func getTopPresentedViewController(_ viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return getTopPresentedViewController(presentedViewController)
        } else {
            return viewController
        }
    }
    func destructiveAlertView(withTitle: String?, message: String? = nil, cancelString: String? = nil, cancelBlock: (() -> Void)? = nil, destructiveString: String? = nil, destructiveBlock: (() -> Void)? = nil) {
        UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
            .addCancelAction(title: cancelString, handler: cancelBlock)
            .addDestructiveAction(title: destructiveString, handler: destructiveBlock)
            .show(in: self)
    }
    
    func confirmationAlertView(withTitle: String?,
                               message: String? = nil,
                               cancelString: String? = nil,
                               cancelBlock: (() -> Void)? = nil,
                               confirmString: String? = nil,
                               confirmBlock: (() -> Void)? = nil) {
        UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
            .addCancelAction(title: cancelString, handler: cancelBlock)
            .addOkAction(title: confirmString, handler: confirmBlock)
            .show(in: self)
    }
    
    func textInputAlertView(withTitle: String?,
                            message: String? = nil,
                            cancelString: String? = nil,
                            cancelBlock: (() -> Void)? = nil,
                            placeholder: String? = nil,
                            textFieldBlock: ((UITextField) -> Void)? = nil,
                            confirmString: String? = nil,
                            confirmBlock: ((UITextField) -> Void)? = nil) {
        UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
         .addCancelAction(title: cancelString, handler: cancelBlock)
         .addTextFieldAction(placeholder: placeholder, handler: textFieldBlock)
         .addOkActionWithTextField(title: confirmString, handler: confirmBlock)
         .show(in: self)
    }
    func warningAlertView(withTitle: String?, message: String? = nil, action: (() -> Void)? = nil) {
        UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
            .addCancelAction(title: "OK", handler: action)
            .show(in: self)
    }
    // 表示とともにタイマーをセットする
    func infoAlertViewWithTitle(title: String, message: String? = nil, afterDismiss: (() -> Void)? = nil) {
        let infoAlert = InfoAlertView(title: title, message: message, preferredStyle: .alert)
        infoAlert.afterDismiss = afterDismiss
        infoAlert.show(in: self) {
            infoAlert.timerStart()
        }
    }
}
