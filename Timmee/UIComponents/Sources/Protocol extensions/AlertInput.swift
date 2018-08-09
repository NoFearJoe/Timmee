//
//  AlertInput.swift
//  Timmee
//
//  Created by i.kharabet on 11.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public enum AlertAction {
    case ok(String)
    case cancel
}

public protocol AlertInput: class {
    func showAlert(title: String?, message: String?, actions: [AlertAction], completion: ((AlertAction) -> Void)?)
}

public extension AlertInput where Self: UIViewController {
    public func showAlert(title: String?, message: String?, actions: [AlertAction], completion: ((AlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            switch action {
            case let .ok(title):
                alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                    completion?(action)
                })
            case .cancel:
                alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel) { _ in
                    completion?(action)
                })
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}
