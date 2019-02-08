//
//  SprintsViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 08.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class SprintsViewController: BaseViewController {
    
    @IBOutlet private var sprintsView: UICollectionView!
    
    private let sprintsService = ServicesAssembly.shared.sprintsService
    
    private var sprints: [Sprint] = []
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare() {
        super.prepare()
        title = "my_sprints".localized
    }
    
    override func refresh() {
        super.refresh()
        reloadSprints()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
    }
    
    private func reloadSprints() {
        sprints = sprintsService.fetchSprints()
        sprintsView.reloadData()
    }
    
}

extension SprintsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sprints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SprintCell", for: indexPath) as! SprintCell
        if let sprint = sprints.item(at: indexPath.item) {
            cell.configure(sprint: sprint)
        }
        return cell
    }
    
}

extension SprintsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedSprint = sprints.item(at: indexPath.item) else { return }
    }
    
}

extension SprintsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
}
