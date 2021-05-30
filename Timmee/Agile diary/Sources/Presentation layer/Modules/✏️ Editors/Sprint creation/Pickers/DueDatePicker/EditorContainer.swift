//
//  EditorContainer.swift
//  Agile diary
//
//  Created by i.kharabet on 06.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

protocol EditorContainerInput: AnyObject {
    func setViewController(_ viewController: UIViewController)
}

protocol EditorContainerOutput: AnyObject {
    func editingCancelled(viewController: UIViewController)
    func editingFinished(viewController: UIViewController)
}


protocol EditorInput: AnyObject {
    var requiredHeight: CGFloat { get }
    func completeEditing(completion: @escaping (Bool) -> Void)
}

extension EditorInput {
    func completeEditing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

protocol DynamicHeightEditorInput: AnyObject {
    var onChangeHeight: ((CGFloat) -> Void)? { get set }
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
        closeButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = transitionHandler
        
        editorContainer.backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.textColor = AppTheme.current.colors.foregroundColor
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
        addChild(viewController)
        editorContainer.addSubview(viewController.view)
        viewController.view.allEdges().toSuperview()
        viewController.didMove(toParent: self)
        
        if let editorInput = viewController as? EditorInput {
            editorContainerHeightConstraint.constant = editorInput.requiredHeight
        }
        
        if let dynamicHeightEditorInput = viewController as? DynamicHeightEditorInput {
            dynamicHeightEditorInput.onChangeHeight = { [weak self] height in
                UIView.animate(withDuration: 0.15) {
                    self?.editorContainerHeightConstraint.constant = height
                }
            }
        }
    }
    
    func setEditorTitle(_ title: String) {
        titleLabel.text = title
    }
    
}
