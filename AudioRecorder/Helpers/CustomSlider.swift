//
//  CustomSlider.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 16.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    private var image: UIImage! {
        didSet {
            setThumbImage(image, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = #imageLiteral(resourceName: "thumb")
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
