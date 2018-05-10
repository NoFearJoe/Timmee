//
//  TaskEditorAudioNotePresenter.swift
//  Timmee
//
//  Created by i.kharabet on 10.05.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

enum AudioNoteState {
    case notRecorded
    case recording
    case recorded
    case playing
}

protocol TaskEditorAudioNotePresenterInput: class {
    func updateAudioNoteField()
}

protocol TaskEditorAudioNotePresenterOutput: class {
    var task: Task! { get }
}

final class TaskEditorAudioNotePresenter {
    
    weak var output: TaskEditorAudioNotePresenterOutput!
    weak var view: TaskEditorAudioNoteViewInput!
    
    private let audioPlayerService = ServicesAssembly.shared.audioPlayerService
    private let audioRecordService = ServicesAssembly.shared.audioRecordService
    
    private var isRecordingAudioNote = false
    private var isPlayingAudioNote = false
    
    private var audioNote: Data? {
        return audioRecordService.getRecordedAudio(fileName: output.task.id)
    }
    
}

extension TaskEditorAudioNotePresenter: TaskEditorAudioNotePresenterInput {
    
    func updateAudioNoteField() {
        if isPlayingAudioNote {
            view.setAudioNoteState(.playing)
        } else {
            view.setAudioNoteState(audioNote == nil ? (isRecordingAudioNote ? .recording : .notRecorded) : .recorded)
        }
    }
    
}

extension TaskEditorAudioNotePresenter: TaskEditorViewAudioNoteOutput {
    
    func audioNoteTouched() {
        if isPlayingAudioNote {
            audioPlayerService.stop()
            isPlayingAudioNote = false
            updateAudioNoteField()
        } else if isRecordingAudioNote {
            audioRecordService.stopRecording()
        } else {
            if audioNote == nil {
                audioRecordService.setupRecordingSession { [weak self] success in
                    guard let `self` = self, success else { return }
                    self.isRecordingAudioNote = true
                    self.updateAudioNoteField()
                    self.audioRecordService.startRecording(outputFileName: self.output.task.id, completion: { [weak self] _, _  in
                        guard let `self` = self else { return }
                        self.isRecordingAudioNote = false
                        self.updateAudioNoteField()
                    })
                }
            } else {
                audioPlayerService.play(fileName: output.task.id) { [weak self] in
                    self?.isPlayingAudioNote = false
                    self?.updateAudioNoteField()
                }
                isPlayingAudioNote = true
                updateAudioNoteField()
            }
        }
    }
    
    func audioNoteCleared() {
        if isPlayingAudioNote {
            audioPlayerService.stop()
            isPlayingAudioNote = false
        } else if isRecordingAudioNote {
            audioRecordService.cancelRecording()
            isRecordingAudioNote = false
        }
        audioRecordService.removeRecordedAudio(fileName: output.task.id)
        updateAudioNoteField()
    }
    
}
