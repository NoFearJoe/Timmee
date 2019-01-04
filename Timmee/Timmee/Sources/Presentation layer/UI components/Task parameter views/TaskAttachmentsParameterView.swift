//
//  TaskAttachmentsParameterView.swift
//  Timmee
//
//  Created by i.kharabet on 12.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskAttachmentsParameterView: TaskParameterView {
    
    var didSelectAttachment: ((String) -> Void)?
    var didRemoveAttachment: ((String) -> Void)?
    
    @IBOutlet fileprivate var attachmentsCollectionView: UICollectionView!
    @IBOutlet fileprivate var placeholderLabel: UILabel! {
        didSet {
            placeholderLabel.text = "no_attachments".localized
            placeholderLabel.textColor = AppTheme.current.secondaryTintColor
            placeholderLabel.isHidden = true
        }
    }
    
    fileprivate var attachments: [String] = []
    
    override func setFilled(_ isFilled: Bool, animated: Bool) {
        super.setFilled(isFilled, animated: animated)
        attachmentsCollectionView.isHidden = !isFilled
        guard !isHidden else { return }
        heightConstraint.constant = isFilled ? 128 : originalHeight
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setAttachments(_ attachments: [String]) {
        self.attachments = attachments
        attachmentsCollectionView.reloadData()
        
        placeholderLabel.isHidden = !attachments.isEmpty
    }
    
}

extension TaskAttachmentsParameterView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskAttachmentCell", for: indexPath) as! TaskAttachmentCell
        
        // TODO: Make via Kingfisher
        if let attachmentName = attachments.item(at: indexPath.item) {
            cell.onRemove = { [unowned self] in
                self.didRemoveAttachment?(attachmentName)
            }
            
            DispatchQueue.global().async {
                if let data = FilesService().getFileFromDocuments(withName: attachmentName) {
                    DispatchQueue.main.async {
                        cell.image = UIImage(data: data)
                    }
                }
            }
        }
        
        return cell
    }
    
}

extension TaskAttachmentsParameterView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let attachmentName = attachments.item(at: indexPath.item) {
            didSelectAttachment?(attachmentName)
        }
    }
    
}

extension TaskAttachmentsParameterView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.height
        return CGSize(width: size, height: size)
    }
    
}

extension TaskAttachmentsParameterView {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view?.isDescendant(of: attachmentsCollectionView) == false
    }
    
}


final class TaskAttachmentCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var removeButton: UIButton! {
        didSet {
            removeButton.tintColor = AppTheme.current.backgroundTintColor
            removeButton.backgroundColor = AppTheme.current.redColor
        }
    }
    
    var onRemove: (() -> Void)?
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    @IBAction func remove() {
        onRemove?()
    }
    
}
