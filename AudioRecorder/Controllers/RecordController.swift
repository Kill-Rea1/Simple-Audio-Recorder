//
//  RecordController.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit
import AVFoundation

final class RecordController: UIViewController {
    
    // MARK:- SessionFlowDelegate
    weak var delegate: SessionFlowDelegate?
    
    func sessionHasChanged() {
        if recordingSession == nil { return }
        do {
            audioRecorder?.stop()
            recordViewModel.isRecording = false
            try recordingSession.setActive(false)
            recordingSession = nil
        } catch let err {
            print("Failed to stop session: ", err)
        }
    }
    
    // MARK:- Properties
    private let padding: CGFloat = 16
    var newRecord: Record?
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder?
    private let recordViewModel = RecordViewModel()
    private var topConstaint: NSLayoutConstraint!
    private var isMicrophoneAllowed = false
    private var path = ""
    
    // MARK:- UI Elements
    private var overallStackView: UIStackView!
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "In order to use the recording you must allow access to the microphone in the settings!"
        label.backgroundColor = .white
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.textColor = .red
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        view.alpha = 0
        return view
    }()
    
    private let nameTextField: CustomTextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter Name..."
        tf.backgroundColor = .white
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.cornerRadius = 32
        tf.setSize(.init(width: 0, height: 64))
        tf.font = .systemFont(ofSize: 18)
        tf.setupShadow(opacity: 0.23, radius: 5, offset: .zero, color: .black)
        tf.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        tf.returnKeyType = .done
        return tf
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 32)
        label.setSize(.init(width: 0, height: 38))
        return label
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        button.setSize(.init(width: 64, height: 64))
        button.backgroundColor = .white
        button.layer.cornerRadius = 32
        button.tintColor = .black
        button.setupShadow(opacity: 0.23, radius: 5, offset: .zero, color: .black)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "recordButton"), for: .normal)
        button.tintColor = .red
        button.setSize(.init(width: 96, height: 96))
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 48
        button.backgroundColor = .silver
        button.setupShadow(opacity: 0.23, radius: 8, offset: .zero, color: .black)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        button.setSize(.init(width: 64, height: 64))
        button.backgroundColor = .white
        button.layer.cornerRadius = 32
        button.tintColor = .black
        button.setupShadow(opacity: 0.23, radius: 5, offset: .zero, color: .black)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleStop), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if recordingSession != nil {
            recordingSession.requestRecordPermission { [unowned self] (allowed) in
                DispatchQueue.main.async {
                    if allowed {
                        self.nameTextField.isEnabled = true
                    } else {
                        print("Failed to get access to microphone")
                        self.containerView.alpha = 1
                        self.warningLabel.alpha = 1
                    }
                }
            }
        } else {
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .silver
        setupViews()
        setupViewModelObserving()
        setupTapGesture()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.spacing = 16
        } else {
            overallStackView.spacing = 44
        }
        if #available(iOS 11, *) { return }
        let topSafeArea = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
        topConstaint.constant = topSafeArea + padding
    }
    
    // MARK:- Private Methods
    
    private func animateWarningLabel(to alpha: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.containerView.alpha = alpha
            self.warningLabel.alpha = alpha
        })
    }
    
    private func setupSession()  {
        if recordingSession != nil { recordingSession = nil }
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] (allowed) in
                self.isMicrophoneAllowed = allowed
                DispatchQueue.main.async {
                    if allowed {
                        self.nameTextField.isEnabled = true
                    } else {
                        print("Failed to get access to microphone")
                        self.animateWarningLabel(to: 1)
                    }
                }
            }
        } catch let err {
            print("Failed to start session: ", err)
        }
    }
    
    private func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc
    private func handleTap() {
        view.endEditing(true)
    }
    
    @objc
    private func handlePause() {
        guard let recorder = audioRecorder else { return }
        if recorder.isRecording {
            audioRecorder?.pause()
            recordViewModel.isPaused = true
        } else {
            audioRecorder?.record()
            recordViewModel.isPaused = false
        }
    }
    
    @objc
    private func handlePlay() {
        if audioRecorder == nil {
            startRecording()
            playButton.isUserInteractionEnabled = false
        }
    }
    
    @objc
    private func handleStop() {
        if audioRecorder != nil {
            finishRecording(success: true)
            playButton.isUserInteractionEnabled = true
        }
    }
    
    private func startRecording() {
        do {
            delegate?.startRecording()
            setupSession()
            if !isMicrophoneAllowed { return }
            path = "recording-\(randomString(length: 10)).m4a"
            let fileUrl = FileManager.getDocumentsPath().appendingPathComponent(path)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderBitRateKey: 320000,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: fileUrl, settings: settings)
            audioRecorder?.delegate = self
            recordViewModel.isRecording = true
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            observe()
        } catch let err {
            print("Failed to start recording: ", err)
            finishRecording(success: false)
        }
    }
    
    private func observe() {
        if audioRecorder != nil && audioRecorder?.isRecording ?? false {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(1)) {
                while self.audioRecorder?.isRecording ?? false {
                    self.recordViewModel.recordingTime = self.audioRecorder?.currentTime
                    self.audioRecorder?.updateMeters()
                    self.recordViewModel.power = self.audioRecorder?.averagePower(forChannel: 0)
                }
            }
        }
    }
    
    private func finishRecording(success: Bool) {
        guard let name = nameTextField.text else { return }
        newRecord = Record(name: name, fileUrl: path, date: Date())
        recordViewModel.isRecording = false
        newRecord?.duration = audioRecorder?.currentTime
        audioRecorder?.stop()
        audioRecorder = nil
        recordViewModel.name = nil
        nameTextField.text = nil
        if success {
            Record.saveRecord(record: newRecord!)
            delegate?.stoppedRecording()
        }
    }
    
    @objc
    private func handleTextFieldChange() {
        recordViewModel.name = nameTextField.text
    }
    
    private func setupViewModelObserving() {
        recordViewModel.bindableIsValid.bind { [unowned self] (isValid) in
            guard let isValid = isValid else { return }
            self.playButton.isEnabled = isValid
        }
        recordViewModel.bindableIsPaused.bind { [unowned self] (isPaused) in
            guard let isPaused = isPaused else { return }
            let image = isPaused ? #imageLiteral(resourceName: "play") : #imageLiteral(resourceName: "pause")
            self.pauseButton.setImage(image, for: .normal)
        }
        recordViewModel.bindableIsRecording.bind { [unowned self] (isRecording) in
            guard let isRecording = isRecording else { return }
            self.pauseButton.isEnabled = isRecording
            self.stopButton.isEnabled = isRecording
            self.nameTextField.isEnabled = !isRecording
            self.nameTextField.textColor = isRecording ? .lightGray : .black
            if !isRecording {
                self.durationLabel.text = "00:00"
                self.playButton.transform = .identity
            }
        }
        recordViewModel.bindableTime.bind { [unowned self] time in
            guard let time = time else { return }
            DispatchQueue.main.async {
                self.durationLabel.text = time
            }
        }
        recordViewModel.bindablePower.bind { [unowned self] (scale) in
            guard let scale = scale else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    self.playButton.transform = CGAffineTransform(scaleX: scale, y: scale)
                })
            }
        }
    }
    
    private func setupWarningLabel() {
        containerView.addSubview(warningLabel)
        warningLabel.centerInSuperview()
        warningLabel.addConstraints(leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, top: nil, bottom: nil, padding: .init(top: 0, left: 58, bottom: 0, right: 58))
        view.addSubview(containerView)
        containerView.fillSuperview()
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    @objc
    private func handleDismiss() {
        animateWarningLabel(to: 0)
    }
    
    private func setupViews() {
        nameTextField.delegate = self
        let buttonsStackView = UIStackView(arrangedSubviews: [pauseButton, playButton, stopButton])
        buttonsStackView.spacing = 16
        buttonsStackView.alignment = .center
        buttonsStackView.distribution = .equalCentering
        
        overallStackView = UIStackView(arrangedSubviews: [
            durationLabel,
            nameTextField,
            buttonsStackView
        ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 44
        
        view.addSubview(overallStackView)
        if #available(iOS 11, *) {
            overallStackView.addConstraints(leading: view.leadingAnchor, trailing: view.trailingAnchor, top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, padding: .init(top: padding, left: padding * 2, bottom: 0, right: padding * 2))
        } else {
            let topSafeArea = UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 0)
            topConstaint = overallStackView.topAnchor.constraint(equalTo: view.topAnchor)
            overallStackView.addConstraints(leading: view.leadingAnchor, trailing: view.trailingAnchor, top: nil, bottom: nil, padding: .init(top: 0, left: padding * 2, bottom: 0, right: padding * 2))
            topConstaint.constant = topSafeArea + padding
            topConstaint.isActive = true
        }
        
        setupWarningLabel()
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}


// MARK:- Extension
extension RecordController: AVAudioRecorderDelegate, UITextFieldDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(success: false)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
