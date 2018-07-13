//
//  TemporaryActionPanelViewController.swift
//  Timmee
//
//  Created by i.kharabet on 11.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum TemporaryAction {
    
    /// Отмена последнего действия (удаление задачи, перенос и т.д.)
    case rollback
    
    /// Переход к списку (после переноса в него задач)
    case showList(List)
}

protocol TemporaryActionPanelInput: class {
    func show(action: TemporaryAction, deadline: TimeInterval)
}

protocol TemporaryActionPanelOutput: class {
    func didSelectAction(_ action: TemporaryAction)
}

final class TemporaryActionPanelViewController: UIViewController, TemporaryActionPanelInput {
    
    @IBOutlet private var titleLabel: UILabel!
    
    weak var output: TemporaryActionPanelOutput?
    
    var action: TemporaryAction! {
        didSet {
            setupAction(action: action)
        }
    }
    
    @IBAction private func handleTap() {
        output?.didSelectAction(action)
        hide(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0
        view.isHidden = true
        view.isUserInteractionEnabled = false
        titleLabel.textColor = AppTheme.current.tintColor
    }
    
    func show(action: TemporaryAction, deadline: TimeInterval) {
        self.action = action
        
        view.isHidden = false
        view.isUserInteractionEnabled = true
        
        let animations = {
            self.view.alpha = 1
        }
        
        let completion: (Bool) -> Void = { finished in
            guard finished else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                self.hide(animated: true)
            }
        }
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn, animations: animations, completion: completion)
    }
    
    private func hide(animated: Bool) {
        view.isUserInteractionEnabled = false
        
        let animations = {
            self.view.alpha = 0
            self.view.isHidden = true
        }
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    
    private func setupAction(action: TemporaryAction) {
        switch action {
        case .rollback:
            titleLabel.text = "cancel_last_action".localized
            view.backgroundColor = AppTheme.current.yellowColor
        case let .showList(list):
            titleLabel.text = "go_to_list".localized + " " + list.title
            view.backgroundColor = AppTheme.current.yellowColor
        }
    }
    
}
