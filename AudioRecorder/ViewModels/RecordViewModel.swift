//
//  RecordViewModel.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit

class RecordViewModel {
    var name: String? { didSet { checkValidity() } }
    var isRecording: Bool = false { didSet { bindableIsRecording.value = isRecording } }
    var recordingTime: Double? { didSet { updateTime() } }
    var power: Float? { didSet { updatePower() } }
    var isPaused = false { didSet { bindableIsPaused.value = isPaused } }
    
    var bindableIsValid = Bindable<Bool>()
    var bindableIsRecording = Bindable<Bool>()
    var bindableTime = Bindable<String>()
    var bindablePower = Bindable<CGFloat>()
    var bindableIsPaused = Bindable<Bool>()
    
    fileprivate func checkValidity() {
        let isValid = name?.isEmpty == false
        self.bindableIsValid.value = isValid
    }
    
    fileprivate func updateTime() {
        self.bindableTime.value = recordingTime?.toTimeString()
    }
    
    fileprivate func updatePower() {
        guard let power = power else { return }
        let powerDelta = CGFloat((50 + power) * 2 / 100)
        let compute: CGFloat = 0.8 + powerDelta
        let scale = CGFloat.maximum(compute, 0.8)
        self.bindablePower.value = scale
    }
}
