//
//  UIImageView+FirebaseStorage.swift
//  Agile diary
//
//  Created by Илья Харабет on 26/02/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import FirebaseStorage
import TasksKit

public extension UIImageView {
    
    private static var imageLoadingTaskKey = "image_loading_task_key"
    private var imageLoadingTask: StorageDownloadTask? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.imageLoadingTaskKey) as? StorageDownloadTask
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.imageLoadingTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private static var imageReferenceKey = "image_loading_task_key"
    private var imageReference: StorageReference? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.imageLoadingTaskKey) as? StorageReference
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.imageReferenceKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func cancelImageLoadingTask() {
        imageLoadingTask?.cancel()
    }
    
    public final func setImage(firebasePath: String) {
        let reference = Storage.storage().reference(withPath: firebasePath)
        setImage(reference: reference)
    }
    
    public final func setImage(reference: StorageReference) {
        if let cachedImage = ImageCache.shared.load(reference: reference) {
            image = cachedImage
        } else {
            if imageReference != reference {
                cancelImageLoadingTask()
            }
            
            imageLoadingTask = reference.getData(maxSize: 1024 * 1024) { [weak self] data, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    ImageCache.shared.save(imageData: data, reference: reference)
                    
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: data)
                    }
                }
                self?.imageLoadingTask = nil
            }
        }
    }
    
}

fileprivate final class ImageCache {
    
    static let shared = ImageCache()
    
    private let filesService = FilesService(directory: "ImageCache")
    
    private let syncQueue = DispatchQueue(label: "image_cache_sync_queue",
                                          qos: .utility,
                                          attributes: .concurrent)
    
    func save(imageData: Data, reference: StorageReference) {
        syncQueue.async(flags: .barrier) {
            self.filesService.saveFileInCaches(withName: reference.name, contents: imageData)
        }
    }
    
    func load(reference: StorageReference) -> UIImage? {
        return syncQueue.sync {
            guard let data = self.filesService.getFileFromCaches(withName: reference.name) else { return nil }
            return UIImage(data: data)
        }
    }
    
}
