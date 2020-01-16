//
//  ListCell.swift
//  AudioRecorder
//
//  Created by Кирилл Иванов on 15.01.2020.
//  Copyright © 2020 Ivanoff Kirill. All rights reserved.
//

import UIKit

protocol ListCellDelegate: class {
    func actionButtonDidTapped(toPlay: Bool, fileUrl: String)
}

final class ListCell: UITableViewCell {
    
    // MARK:- Properties
    var record: Record! {
        didSet {
            nameLabel.text = record.name
            dateLabel.text = record.date.toDateString()
            durationLabel.text = record.duration?.toTimeString()
        }
    }
    weak var delegate: ListCellDelegate?
    private let padding: CGFloat = 16
    
    // MARK:- UI Elements
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
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
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    // MARK:- Private Methods
    private func setupViews() {
        backgroundColor = .silver
        let infoStackView = UIStackView(arrangedSubviews: [dateLabel, UIView(), durationLabel])
        infoStackView.spacing = 8
        let overallStackView = UIStackView(arrangedSubviews: [nameLabel, infoStackView])
        overallStackView.spacing = 16
        overallStackView.axis = .vertical
        addSubview(overallStackView)
        overallStackView.fillSuperview(.init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
