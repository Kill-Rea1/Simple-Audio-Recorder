//
//  Bindable.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}
