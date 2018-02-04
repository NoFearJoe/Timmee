//
//  MainTopViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol MainTopViewControllerOutput: class {
    func currentListChanged(to list: List)
    func listCreated()
    func willShowLists()
}

final class MainTopViewController: UIViewController {

    @IBOutlet fileprivate weak var overlayView: UIView!
    @IBOutlet fileprivate weak var controlPanel: ControlPanel!
    
    @IBOutlet fileprivate weak var listsViewContainer: BarView!
    
    @IBOutlet fileprivate weak var listsViewHeightConstrint: NSLayoutConstraint!
    
    weak var output: MainTopViewControllerOutput?
    weak var editingInput: ListRepresentationEditingInput?
    
    private weak var listsViewInput: ListsViewInput!
    
    fileprivate var isListsVisible: Bool = true {
        didSet {
            listsViewInput.resetRevealedCells()
        }
    }
    
    fileprivate var isAnimationInProgress = false
    
    fileprivate var isGroupEditing: Bool = false
    
    fileprivate var isPickingList: Bool = false {
        didSet {
            listsViewInput.setPickingList(isPickingList)
        }
    }
    fileprivate var pickingListCompletion: ((List) -> Void)?
    
    fileprivate let swipeTableActionsProvider = ListsSwipeTableActionsProvider()
    
    var passthrowView: PassthrowView {
        return view as! PassthrowView
    }
    
    
    @IBAction fileprivate func didPressSettingsButton() {
        hideLists(animated: true, force: true)

        let viewController = ViewControllersFactory.settings
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction fileprivate func didPressSearchButton() {
        hideLists(animated: true, force: true)
        
        let viewController = ViewControllersFactory.search
        SearchAssembly.assembly(with: viewController)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction fileprivate func didPressEditButton() {
        controlPanel.setGroupEditingButtonEnabled(false)
        editingInput?.toggleGroupEditing()
        
        hideLists(animated: true, force: true)
    }
    
    @IBAction fileprivate func didPressOverlayView() {
        hideLists(animated: true)
    }
    
    @IBAction fileprivate func didPressControlPanel() {
        guard !isGroupEditing || isPickingList else { return }
        isListsVisible ? hideLists(animated: true) : showLists(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideLists(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controlPanel.applyAppearance()
        listsViewContainer.barColor = AppTheme.current.middlegroundColor
        
        listsViewInput.resetRevealedCells()
        
        updateListsViewHeight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateListsViewHeight()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedListsViewController" {
            guard let listsViewController = segue.destination as? ListsViewController else { return }
            listsViewController.output = self
            listsViewInput = listsViewController
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func showLists(animated: Bool) {
        guard !isListsVisible && !isAnimationInProgress else { return }
        
        output?.willShowLists()
        
        listsViewInput.reloadLists()
        
        passthrowView.shouldPassTouches = false
        overlayView.isHidden = false
        
        listsViewContainer.isHidden = false
        
        controlPanel.hideControls(animated: animated)
        
        if animated {
            isAnimationInProgress = true
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: {
                self.overlayView.backgroundColor = AppTheme.current.backgroundColor
                self.listsViewContainer.transform = .identity
            }) { _ in
                self.isListsVisible = true
                self.isAnimationInProgress = false
            }
        } else {
            overlayView.backgroundColor = AppTheme.current.backgroundColor
            self.listsViewContainer.transform = .identity
            isListsVisible = true
        }
    }
    
    func hideLists(animated: Bool, force: Bool = false) {
        guard (isListsVisible && !isAnimationInProgress) || force else { return }
        
        isPickingList = false
        
        controlPanel.showControls(animated: animated)
        
        if animated {
            isAnimationInProgress = true
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseIn],
                           animations: {
                self.overlayView.backgroundColor = .clear
                self.listsViewContainer.transform = CGAffineTransform(translationX: 0, y: self.listsViewContainer.frame.height)
            }) { _ in
                self.overlayView.isHidden = true
                self.isListsVisible = false
                self.listsViewContainer.isHidden = true
                self.passthrowView.shouldPassTouches = true
                self.isAnimationInProgress = false
            }
        } else {
            view.backgroundColor = .clear
            overlayView.isHidden = true
            listsViewContainer.transform = CGAffineTransform(translationX: 0, y: self.listsViewContainer.frame.height)
            listsViewContainer.isHidden = true
            isListsVisible = false
            passthrowView.shouldPassTouches = true
        }
    }

}

extension MainTopViewController: ListsViewOutput {
    
    func didSelectList(_ list: List) {
        controlPanel.showList(list)
        output?.currentListChanged(to: list)
        hideLists(animated: true)
    }
    
    func didPickList(_ list: List) {
        pickingListCompletion?(list)
        hideLists(animated: true)
    }
    
    func didUpdateList(_ list: List) {
        controlPanel.showList(list)
        output?.currentListChanged(to: list)
    }
    
    func didAskToAddList() {
        self.showListEditor(with: nil)
    }
    
    func didAskToAddSmartList() {
        // TODO
    }
    
    func didAskToEditList(_ list: List) {
        self.showListEditor(with: list)
    }
    
}

extension MainTopViewController: ListEditorOutput {

    func listCreated() {
        hideLists(animated: false)
        output?.listCreated()
    }

}

extension MainTopViewController: ListRepresentationEditingOutput {
    
    func groupEditingWillToggle(to isEditing: Bool) {
        if isEditing {
            isGroupEditing = true
        }
    }
    
    func groupEditingToggled(to isEditing: Bool) {
        isGroupEditing = isEditing
        controlPanel.setGroupEditingButtonEnabled(true)
        controlPanel.changeGroupEditingState(to: isEditing)
    }
    
    func didAskToShowListsForMoveTasks(completion: @escaping (List) -> Void) {
        isPickingList = true
        pickingListCompletion = completion
        showLists(animated: true)
    }
    
    func setGroupEditingVisible(_ isVisible: Bool) {
        controlPanel.setGroupEditingVisible(isVisible)
    }
    
}

fileprivate extension MainTopViewController {

    func updateListsViewHeight() {
        var listsViewHeight = view.frame.height - 52
        if #available(iOS 11.0, *) {
            listsViewHeight -= view.safeAreaInsets.top
        }
        listsViewHeightConstrint.constant = listsViewHeight
    }
    
    func showListEditor(with list: List?) {
        let listEditorView = ViewControllersFactory.listEditor
        listEditorView.loadViewIfNeeded()
        
        let listEditorInput = ListEditorAssembly.assembly(with: listEditorView)
        listEditorInput.output = self
        listEditorInput.setList(list)
        
        present(listEditorView, animated: true, completion: nil)
    }

}

final class ListsSeparatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(AppTheme.current.panelColor.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 2, lengths: [4, 4])
        
        context.move(to: CGPoint(x: 0, y: 0.5))
        context.addLine(to: CGPoint(x: rect.width, y: 0.5))
        context.strokePath()
    }
    
}
