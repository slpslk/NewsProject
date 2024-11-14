//
//  DropDownPicker.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 14.11.2024.
//

import Foundation
import UIKit
import Combine

final class DropDownPicker: UIView {
    
    private var itemSubject = PassthroughSubject<Sorting, Never>()

    private let items: [Sorting]
    
    private lazy var textField: UITextField = {
        let text = UITextField()
        text.borderStyle = .roundedRect
        text.delegate = self
        text.placeholder = "Сортировка"
        text.addTarget(self, action: #selector(textFieldTapped), for: .touchDown)
        return text
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.isHidden = true
        return table
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 4
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(tableView)
        return stack
    }()
    
    init(frame: CGRect, items: [Sorting]) {
        self.items = items
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var itemPublisher: AnyPublisher<Sorting, Never> {
        return itemSubject.eraseToAnyPublisher()
    }
}

private extension DropDownPicker {
    func setupUI() {
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(items.count * 40))
        ])
    }
    
    @objc func textFieldTapped() {
        toggleDropdown()
    }
    
    func toggleDropdown() {
        tableView.isHidden = !tableView.isHidden
    }
}

extension DropDownPicker: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row].title()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.text = items[indexPath.row].title()
        itemSubject.send(items[indexPath.row])
        toggleDropdown()
    }
}

extension DropDownPicker: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}
