//
//  NewsCell.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 13.11.2024.
//

import Foundation
import UIKit


final class NewsCell: UITableViewCell {
    var viewModel: News? {
        didSet {
            updateUI()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = Colors.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = Colors.lightGray
        label.numberOfLines = 0
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        dateLabel.text = nil
    }
}

private extension NewsCell {
    func updateUI() {
        guard let viewModel else {
            return
        }

        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.publishedAt
    }

    func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
