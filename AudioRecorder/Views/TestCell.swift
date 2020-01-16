//
//  TestCell.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 16.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit

protocol TestCellDelegate: class {
    func actionButtonDidTapped(toPlay: Bool, fileUrl: String)
}

final class TestCell: UITableViewCell {
    
    var record: Record! {
        didSet {
            nameLabel.text = record.name
            dateLabel.text = record.date.toDateString()
            durationLabel.text = record.duration?.toTimeString()
        }
    }
    
    weak var delegate: ListCellDelegate?
    
    var isPlaying = false {
        didSet {
            let image = isPlaying ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play")
            actionButton.setImage(image, for: .normal)
        }
    }
    
    private let padding: CGFloat = 16
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = .black
        button.widthAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "12 Jan"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "12:12:12"
        label.widthAnchor.constraint(equalToConstant: 64).isActive = true
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @objc
    private func handleAction() {
        isPlaying.toggle()
        delegate?.actionButtonDidTapped(toPlay: isPlaying, fileUrl: record.fileUrl)
    }
    
    private func setupViews() {
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        let infoStackView = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        let overallStackView = UIStackView(arrangedSubviews: [actionButton, infoStackView, durationLabel])
        overallStackView.spacing = 16
        overallStackView.alignment = .center
        addSubview(overallStackView)
        overallStackView.fillSuperview(.init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
//    private func setupSeparatorView() {
//        let separatorView = UIView()
//        separatorView.backgroundColor = UIColor(white: 0.6, alpha: 0.5)
//        addSubview(separatorView)
//        separatorView.addConstraints(leading: nameLabel.leadingAnchor, trailing: trailingAnchor, top: nil, bottom: bottomAnchor, size: .init(width: 0, height: 0.5))
//    }
    
    override func prepareForReuse() {
        actionButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
