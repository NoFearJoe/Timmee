//
//  EditorContainer.swift
//  Agile diary
//
//  Created by i.kharabet on 06.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol EditorContainerInput: class {
    func setViewController(_ viewController: UIViewController)
}

protocol EditorContainerOutput: class {
    func editingCancelled(viewController: UIViewController)
    func editingFinished(viewController: UIViewController)
}


protocol EditorInput: class {
    var requiredHeight: CGFloat { get }
    func completeEditing(completion: @escaping (Bool) -> Void)
}

extension EditorInput {
    func completeEditing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

final class EditorContainer: UIViewController {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var editorContainer: UIView!
    @IBOutlet private var editorContainerUnderlyingView: RoundedViewWithShadow!
    
    @IBOutlet private var editorContainerHeightConstraint: NSLayoutConstraint!
    
    weak var output: EditorContainerOutput?
    
    private var viewController: UIViewController!
    
    let transitionHandler = FadePresentationTransitionHandler()
    
    @IBAction private func closeButtonPressed() {
        output?.editingCancelled(viewController: viewController)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func doneButtonPressed() {
        completeEditing()
    }
    
    @IBAction private func backgroundViewPressed() {
        completeEditing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = transitionHandler
        
        editorContainer.backgroundColor = UIColor.white // TODO: Theme
        titleLabel.textColor = UIColor.white
        closeButton.tintColor = AppTheme.current.colors.wrongElementColor
        doneButton.tintColor = AppTheme.current.colors.selectedElementColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension EditorContainer: EditorContainerInput {
    
    func setViewController(_ viewController: UIViewController) {
        self.viewController = viewController
        
        setupEditor()
        setEditorTitle(viewController.title ?? "")
    }
    
}

private extension EditorContainer {
    
    func completeEditing() {
        output?.editingFinished(viewController: viewController)
        dismiss(animated: true, completion: nil)
    }
    
}

private extension EditorContainer {
    
    func setupEditor() {
        addChildViewController(viewController)
        editorContainer.addSubview(viewController.view)
        viewController.view.allEdges().toSuperview()
        viewController.didMove(toParentViewController: self)
        
        if let editorInput = viewController as? EditorInput {
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
    }
    
    func setEditorTitle(_ title: String) {
        titleLabel.text = title
    }
    
}
