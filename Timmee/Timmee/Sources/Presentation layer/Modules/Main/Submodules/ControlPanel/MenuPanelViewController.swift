//
//  MenuPanelViewController.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol MenuPanelInput: class {
    func showList(_ list: List)
    func setGroupEditingButtonEnabled(_ isEnabled: Bool)
    func setGroupEditingButtonVisible(_ isVisible: Bool)
    func changeGroupEditingState(to isEditing: Bool)
    
    func showControls(animated: Bool)
    func hideControls(animated: Bool)
}

protocol MenuPanelOutput: class {
    func didPressGroupEditingButton()
    func didPressOnPanel()
}

final class MenuPanelViewController: UIViewController {
    
    weak var output: MenuPanelOutput!
    
    @IBOutlet private var menuPanel: ControlPanel!
    
    @IBAction private func didPressSettingsButton() {
        let viewController = ViewControllersFactory.settings
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction private func didPressSearchButton() {
        let viewController = ViewControllersFactory.search
        SearchAssembly.assembly(with: viewController)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction private func didPressEditButton() {
        menuPanel.setGroupEditingButtonEnabled(false)
        output.didPressGroupEditingButton()
    }
    
    @IBAction private func didPressControlPanel() {
        output.didPressOnPanel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuPanel.applyAppearance()
    }
    
}

extension MenuPanelViewController: MenuPanelInput {
    
    func showList(_ list: List) {
        menuPanel.showList(list)
    }
    
    func setGroupEditingButtonEnabled(_ isEnabled: Bool) {
        menuPanel.setGroupEditingButtonEnabled(isEnabled)
    }
    
    func setGroupEditingButtonVisible(_ isVisible: Bool) {
        menuPanel.setGroupEditingVisible(isVisible)
    }
    
    func changeGroupEditingState(to isEditing: Bool) {
        menuPanel.changeGroupEditingState(to: isEditing)
    }
    
    func showControls(animated: Bool) {
        menuPanel.showControls(animated: animated)
    }
    
    func hideControls(animated: Bool) {
        menuPanel.hideControls(animated: animated)
    }
    
}
