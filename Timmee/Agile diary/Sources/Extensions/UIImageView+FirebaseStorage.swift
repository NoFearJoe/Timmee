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
            objc_setAssociatedObject(self, &UIImageView.imageLoadingTaskKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
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
            imageLoadingTask = reference.getData(maxSize: 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    ImageCache.shared.save(imageData: data, reference: reference)
                    
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
}

fileprivate final class ImageCache {
    
    static let shared = ImageCache()
    
    private let syncQueue = DispatchQueue(label: "image_cache_sync_queue",
                                          qos: .utility,
                                          attributes: .concurrent)
    
    func save(imageData: Data, reference: StorageReference) {
        syncQueue.async(flags: .barrier) {
            let filename = "\(reference.fullPath.hashValue)\(reference.name)"
            let imageCacheDirectory = "image_cache"
            FilesService().saveFileInCaches(withName: imageCacheDirectory + "/" + filename, contents: imageData)
        }
    }
    
    func load(reference: StorageReference) -> UIImage? {
        return syncQueue.sync {
            let filename = "\(reference.fullPath.hashValue)\(reference.name)"
            let imageCacheDirectory = "image_cache"
            guard let data = FilesService().getFileFromCaches(withName: imageCacheDirectory + "/" + filename) else { return nil }
            return UIImage(data: data)
        }
    }
    
}
