//
//  PlayerCell.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 16.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlayerCellDelegate: class {
    func deleteRecord()
}

final class PlayerCell: UITableViewCell {
    
    // MARK:- Delegate
    func animate(to alpha: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.2, animations: {
            self.overallStackView.alpha = alpha
        }) { _ in
            if alpha == 0 {
                do {
                    try self.audioSession.setActive(false)
                    self.audioSession = nil
                    self.audioPlayer = nil
                } catch let err {
                    print("Failed to stop session: ", err)
                }
            }
        }
    }
    
    func changeSessionActivity(_ active: Bool = false) {
        if audioSession == nil { return }
        do {
            audioPlayer.stop()
            try audioSession.setActive(active)
            if active {
                try audioSession.setCategory(.playback)
            }
        } catch let err {
            print("Failed to change session: ", err)
        }
    }
    
    // MARK:- Properties
    static let buttonSize = CGSize(width: 48, height: 48)
    weak var delegate: PlayerCellDelegate?
    private var isPlaying = false {
        didSet {
            let image = isPlaying ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play")
            playPauseButton.setImage(image, for: .normal)
        }
    }
    var record: Record! {
        didSet {
            durationTimeLabel.text = "-\(record.duration!.toTimeString())"
            DispatchQueue.main.async {
                self.preparePlayer()
            }
        }
    }
    private var audioSession: AVAudioSession!
    private var audioPlayer: AVAudioPlayer!
    
    // MARK:- UI Elements
    private let currentTimeSlider: UISlider = {
        let slider = UISlider()
        slider.thumbTintColor = #colorLiteral(red: 0.3999576569, green: 0.4000295997, blue: 0.3999481499, alpha: 1)
        slider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        slider.minimumTrackTintColor = #colorLiteral(red: 0.3999576569, green: 0.4000295997, blue: 0.3999481499, alpha: 1)
        slider.maximumValue = 1
        return slider
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = .black
        button.setSize(PlayerCell.buttonSize)
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "fastforward15"), for: .normal)
        button.tintColor = .black
        button.setSize(PlayerCell.buttonSize)
        return button
    }()
    
    private let backwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "rewind15"), for: .normal)
        button.tintColor = .black
        button.setSize(PlayerCell.buttonSize)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setSize(PlayerCell.buttonSize)
        button.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        button.tintColor = .red
        return button
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "00:00"
        label.textColor = .darkGray
        return label
    }()
    
    private let durationTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "12:12"
        label.textColor = .darkGray
        return label
    }()
    
    private var overallStackView: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    // MARK:- Private Methods
    private func setupViews() {
        playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(handleBackward), for: .touchUpInside)
        currentTimeSlider.addTarget(self, action: #selector(handleSliderChanged), for: .valueChanged)
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        
        selectionStyle = .none
        backgroundColor = .silver
        
        let timeStackView = UIStackView(arrangedSubviews: [currentTimeLabel, UIView(), durationTimeLabel])
        timeStackView.alignment = .center
        let buttonsStackView = UIStackView(arrangedSubviews: [SpacerView(size: 48), UIView(), backwardButton, playPauseButton, forwardButton, UIView(), deleteButton])
        buttonsStackView.distribution = .equalSpacing
        overallStackView = UIStackView(arrangedSubviews: [
            currentTimeSlider,
            timeStackView,
            SpacerView(size: 24),
            buttonsStackView,
            UIView()
        ])
        overallStackView.axis = .vertical
        addSubview(overallStackView)
        overallStackView.fillSuperview(.init(top: 8, left: 16, bottom: 0, right: 16))
        overallStackView.alpha = 0
    }
    
    private func setupSession() {
        if audioSession != nil { return }
        audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(true)
            try audioSession.setCategory(.playback, mode: .default)
        } catch let err {
            print("Failed to start session: ", err)
        }
    }
    
    private func preparePlayer() {
        setupSession()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: FileManager.getDocumentsPath().appendingPathComponent(record.fileUrl))
            audioPlayer.delegate = self
            audioPlayer.volume = 1
            audioPlayer.prepareToPlay()
        } catch let err{
            print("Failed to prepare player: ", err)
        }
    }
    
    private func observe() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let currentTimeSeconds = self.audioPlayer.currentTime
                let percentage = currentTimeSeconds / self.record.duration!
                DispatchQueue.main.async { [unowned self] in
                    self.currentTimeSlider.value = Float(percentage)
                    self.currentTimeLabel.text = currentTimeSeconds.toTimeString()
                    self.durationTimeLabel.text = "-\((self.record.duration! - currentTimeSeconds).toTimeString())"
                }
            } while self.audioPlayer.isPlaying
        }
    }
    
    @objc
    private func handleDelete() {
        delegate?.deleteRecord()
    }
    
    @objc
    private func handleSliderChanged() {
        let percentage = currentTimeSlider.value
        let seekTime = Double(percentage) * record.duration!
        audioPlayer.currentTime = seekTime
        observe()
    }
    
    @objc
    private func handlePlayPause() {
        if !isPlaying {
            changeSessionActivity(true)
            audioPlayer.play()
            observe()
            isPlaying = true
        } else {
            audioPlayer.pause()
            isPlaying = false
        }
    }
    
    @objc
    private func handleForward() {
        seekToCurrentTime(delta: 15)
    }
    
    @objc
    private func handleBackward() {
        seekToCurrentTime(delta: -15)
    }
    
    private func seekToCurrentTime(delta: Int) {
        audioPlayer.currentTime += Double(delta)
        observe()
    }
    
    override func prepareForReuse() {
        currentTimeSlider.value = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print("deinit")
    }
}

// MARK:- Extension
extension PlayerCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
