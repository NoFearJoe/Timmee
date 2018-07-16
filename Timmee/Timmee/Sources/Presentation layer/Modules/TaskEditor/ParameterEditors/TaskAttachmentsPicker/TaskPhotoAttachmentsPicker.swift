//
//  TaskPhotoAttachmentsPicker.swift
//  Timmee
//
//  Created by i.kharabet on 15.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import Foto

protocol TaskPhotoAttachmentsPickerInput: class {
    func setSelectedPhotos(_ photoNames: [String])
}

protocol TaskPhotoAttachmentsPickerOutput: class {
    func didSelectPhotos(_ photos: [Photo])
    func maxSelectedPhotosCountReached()
}

final class TaskPhotoAttachmentsPicker: UIViewController {
    
    weak var output: TaskPhotoAttachmentsPickerOutput?
    weak var container: TaskParameterEditorOutput?
    
    var maxPhotos: Int {
        return ProVersionPurchase.shared.isPurchased() ? 15 : 5
    }
    
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    fileprivate var album = Album<Photo>(type: AlbumType.composite)
    fileprivate var photos: [Photo] = []
    
    fileprivate var selectedPhotos: [Photo] = []
    fileprivate var selectedPhotoNames: [String] = []
    
    fileprivate var _cellSize: CGSize?
    fileprivate var cellSize: CGSize {
        if let size = _cellSize {
            return size
        }
        _cellSize = calculateSizeForPhotoCell(collectionView: collectionView)
        return _cellSize!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        album.objectsRetrieved = { [weak self] photos in
            guard let `self` = self else { return }
            
            self.photos = photos
            
            if !self.selectedPhotoNames.isEmpty {
                self.selectedPhotos += self.photos.filter { photo in
                    return self.selectedPhotoNames.contains(photo.name)
                        && !self.selectedPhotos.contains(where: { $0.name == photo.name })
                }
                self.selectedPhotoNames = []
            }
            
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        container?.closeButton.setImage(#imageLiteral(resourceName: "cross"), for: .normal)
        
        album.fetchByCreationDate()
    }
    
}

extension TaskPhotoAttachmentsPicker: TaskPhotoAttachmentsPickerInput {
    
    func setSelectedPhotos(_ photoNames: [String]) {
        selectedPhotoNames = photoNames
    }
    
}

extension TaskPhotoAttachmentsPicker: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "TakePhotoCell", for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            
            if let photo = photos.item(at: indexPath.item - 1) {
                photo.loadImage(size: cellSize, contentMode: .aspectFill, completion: { image in
                    DispatchQueue.main.async {
                        cell.image = image
                    }
                })
                
                cell.isPicked = selectedPhotos.contains(photo)
            }
            
            return cell
        }
    }
    
}

extension TaskPhotoAttachmentsPicker: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            showTakePhotoController()
        } else if let photo = photos.item(at: indexPath.item - 1) {
            if selectedPhotos.contains(photo) {
                selectedPhotos.remove(object: photo)
            } else {
                guard selectedPhotos.count < maxPhotos else {
                    output?.maxSelectedPhotosCountReached()
                    return
                }
                selectedPhotos.append(photo)
            }
            
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
}

extension TaskPhotoAttachmentsPicker: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    fileprivate func calculateSizeForPhotoCell(collectionView: UICollectionView) -> CGSize {
        let size = collectionView.frame.width / 3
        return CGSize(width: size, height: size)
    }
    
}

extension TaskPhotoAttachmentsPicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return UIScreen.main.bounds.height * 0.6
    }
    
    func completeEditing(completion: @escaping (Bool) -> Void) {
        output?.didSelectPhotos(selectedPhotos)
        completion(true)
    }
    
}

extension TaskPhotoAttachmentsPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // TODO: Save
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

private extension TaskPhotoAttachmentsPicker {
    
    func showTakePhotoController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let controller = UIImagePickerController()
            controller.allowsEditing = false
            controller.sourceType = .camera
            controller.cameraCaptureMode = .photo
            controller.cameraDevice = .rear
            controller.cameraFlashMode = .auto
            controller.showsCameraControls = true
            controller.modalPresentationStyle = .fullScreen
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        } else {
            // TODO: Show alert "No camera"
        }
    }
    
}


final class PhotoCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var selectedForegroundView: UIView! {
        didSet {
            selectedForegroundView.backgroundColor = AppTheme.current.blueColor.withAlphaComponent(0.5)
        }
    }
    @IBOutlet private var selectedIndicator: UIImageView! {
        didSet {
            selectedIndicator.tintColor = AppTheme.current.backgroundTintColor
        }
    }
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var isPicked: Bool = false {
        didSet {
            selectedForegroundView.isHidden = !isPicked
            selectedIndicator.isHidden = !isPicked
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
        isPicked = false
    }
    
}

final class TakePhotoCell: UICollectionViewCell {}
