//
//  NotFoundCell.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 14.11.2024.
//

import Foundation
import UIKit

final class NotFoundCell: UITableViewCell {
    enum Constants {
        static let titleText = "Ничего не найдено"
        static let subtitleText = "К сожалению, по данному запросу не нашлось статей :("
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = Colors.darkGray
        label.numberOfLines = 0
        label.text = Constants.titleText
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = Colors.lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Constants.subtitleText
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
}

private extension NotFoundCell {

    func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

