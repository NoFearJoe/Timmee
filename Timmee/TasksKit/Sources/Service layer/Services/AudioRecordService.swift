//
//  AudioRecordService.swift
//  TasksKit
//
//  Created by Илья Харабет on 29.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import AVFoundation

public protocol AudioRecordServiceInput: class {
    func setupRecordingSession(completion: @escaping (Bool) -> Void)
    func startRecording(outputFileName: String, completion: @escaping (URL?, Bool) -> Void)
    func stopRecording()
    func cancelRecording()
    func getRecordedAudio(fileName: String) -> Data?
    func removeRecordedAudio(fileName: String)
}

final class AudioRecordService: NSObject, AudioRecordServiceInput {
    
    private var recorder: AVAudioRecorder?
    
    private var recorderSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    private let recordsDirectory: URL = FilesService.URLs.documents!.appendingPathComponent("AudioRecords", isDirectory: true)
    
    private var recordingCompletion: ((URL?, Bool) -> Void)?
    
    func startRecording(outputFileName: String, completion: @escaping (URL?, Bool) -> Void) {
        do {
            recordingCompletion = completion
            let outputFileURL = recordsDirectory.appendingPathComponent(outputFileName + ".m4a")
            createAudioRecordsDirectoryIfNeeded()
            recorder = try AVAudioRecorder(url: outputFileURL, settings: recorderSettings)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            completion(nil, false)
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }
    
    func cancelRecording() {
        recorder?.stop()
        recorder?.deleteRecording()
        recorder = nil
    }
    
    func getRecordedAudio(fileName: String) -> Data? {
        return FileManager.default.contents(atPath: getPathToAudioFile(named: fileName))
    }
    
    func setupRecordingSession(completion: @escaping (Bool) -> Void) {
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord,
                                                                mode: AVAudioSession.Mode.default,
                                                                options: [])
            }
            try AVAudioSession.sharedInstance().setActive(true)
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    completion(allowed)
                }
            }
        } catch {
            completion(false)
        }
    }
    
    func removeRecordedAudio(fileName: String) {
        try? FileManager.default.removeItem(atPath: getPathToAudioFile(named: fileName))
    }
    
    private func getPathToAudioFile(named name: String) -> String {
        var fileName = name
        if !fileName.hasSuffix(".m4a") {
            fileName += ".m4a"
        }
        return recordsDirectory.appendingPathComponent(fileName).path
    }
    
    private func createAudioRecordsDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: recordsDirectory.path) {
            try? FileManager.default.createDirectory(atPath: recordsDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
}

extension AudioRecordService: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingCompletion?(recorder.url, flag)
        recordingCompletion = nil
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        recordingCompletion?(nil, false)
        recordingCompletion = nil
    }
    
}
