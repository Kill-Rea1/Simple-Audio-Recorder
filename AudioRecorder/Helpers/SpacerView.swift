//
//  SpacerView.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 16.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit

class SpacerView: UIView {
    let size: CGFloat
    
    init(size: CGFloat) {
        self.size = size
        super.init(frame: .zero)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: size, height: size)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
