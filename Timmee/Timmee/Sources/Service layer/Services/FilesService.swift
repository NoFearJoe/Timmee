//
//  FilesService.swift
//  Timmee
//
//  Created by i.kharabet on 24.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation

final class FilesService {
    
    fileprivate struct URLs {
        fileprivate static let documents = try? FileManager.default.url(for: .documentDirectory,
                                                                        in: .userDomainMask,
                                                                        appropriateFor: nil,
                                                                        create: true)
        
        fileprivate static let caches = try? FileManager.default.url(for: .cachesDirectory,
                                                                     in: .userDomainMask,
                                                                     appropriateFor: nil,
                                                                     create: true)
    }
        
    // MARK: - Save file
    
    func saveFileInDocuments(withName name: String, contents: Data) {
        guard let documentsURL = URLs.documents else { return }
        saveFile(withName: name, contents: contents, url: documentsURL)
    }
    
    func saveFileInCaches(withName name: String, contents: Data) {
        guard let cachesURL = URLs.caches else { return }
        saveFile(withName: name, contents: contents, url: cachesURL)
    }
    
    // MARK: - Remove file
    
    func removeFileFromDocuments(withName name: String) {
        guard let documentsURL = URLs.documents else { return }
        removeFile(withName: name, url: documentsURL)
    }
    
    func removeFileFromCaches(withName name: String) {
        guard let cachesURL = URLs.caches else { return }
        removeFile(withName: name, url: cachesURL)
    }
    
    // MARK: - Get file
    
    func getFileFromDocuments(withName name: String) -> Data? {
        guard let documentsURL = URLs.documents else { return nil }
        return getFile(withName: name, url: documentsURL)
    }
    
    func getFileFromCaches(withName name: String) -> Data? {
        guard let cachesURL = URLs.caches else { return nil }
        return getFile(withName: name, url: cachesURL)
    }
    
    // MARK: - File existanse
    
    func isFileExistsInDocuments(withName name: String) -> Bool {
        guard let documentsURL = URLs.documents else { return false }
        return isFileExists(withName: name, url: documentsURL)
    }
    
    func isFileExistsInCaches(withName name: String) -> Bool {
        guard let cachesURL = URLs.caches else { return false }
        return isFileExists(withName: name, url: cachesURL)
    }
    
    // MARK: - Private methods
    
    private func saveFile(withName name: String, contents: Data, url: URL) {
        if !FileManager.default.fileExists(atPath: url.appendingPathComponent("Attachments").path) {
            try! FileManager.default.createDirectory(at: url.appendingPathComponent("Attachments"), withIntermediateDirectories: true, attributes: nil)
        }
        
        FileManager.default.createFile(atPath: makeAttachmentsURL(baseURL: url, filename: name).path,
                                       contents: contents,
                                       attributes: nil)
    }
        
    private func removeFile(withName name: String, url: URL) {
        try? FileManager.default.removeItem(at: makeAttachmentsURL(baseURL: url, filename: name))
    }
    
    private func getFile(withName name: String, url: URL) -> Data? {
        return FileManager.default.contents(atPath: makeAttachmentsURL(baseURL: url, filename: name).path)
    }
    
    private func isFileExists(withName name: String, url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: makeAttachmentsURL(baseURL: url, filename: name).path)
    }
    
    
    private func makeAttachmentsURL(baseURL: URL, filename: String) -> URL {
        return baseURL.appendingPathComponent("Attachments").appendingPathComponent(filename)
    }
    
}
