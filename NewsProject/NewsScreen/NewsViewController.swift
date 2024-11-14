//
//  NewsViewController.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 13.11.2024.
//

import Foundation
import UIKit
import Combine

final class NewsViewController: UIViewController {
    
    private let viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController()
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Поиск"
        return search
    }()
    
    private let sortingOptions: [Sorting] = [.publishedAt, .popularity]
    
    private lazy var sortingPicker: DropDownPicker = {
        let picker = DropDownPicker(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 0,
                                                  height: 40),
                                    items: sortingOptions)
        return picker
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.register(NewsCell.self, forCellReuseIdentifier: String(describing: NewsCell.self))
        tableView.register(NotFoundCell.self, forCellReuseIdentifier: String(describing: NotFoundCell.self))
        
        return tableView
    }()
    
    private let titleAttributes = [NSAttributedString.Key.foregroundColor: Colors.darkGray]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(sortingPicker)
        view.addSubview(tableView)

        setupNavigationBar()
        setupUI()
        setupBindings()
        setupGestureToDismissKeyboard()
    }
}

private extension NewsViewController {
    func setupNavigationBar() {
        title = "Поиск новостей"
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupUI() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        sortingPicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sortingPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortingPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sortingPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            sortingPicker.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortingPicker.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func reloadTable(){
        tableView.reloadData()
    }
    
    func setupBindings() {
        bindTableToNews()
        bindSearchController()
        bindSortingPicker()
    }
    
    func bindTableToNews() {
        viewModel.$cells
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadTable()
            }
            .store(in: &cancellables)
    }
    
    func bindSearchController() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.viewModel.searchText = text
            }
            .store(in: &cancellables)
    }
    
    func bindSortingPicker() {
        sortingPicker.itemPublisher
            .sink(receiveValue: { [weak self] value in
                self?.viewModel.sortingType = value
            })
            .store(in: &cancellables)
    }
    
    func setupGestureToDismissKeyboard() {
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         tapGesture.cancelsTouchesInView = false
         view.addGestureRecognizer(tapGesture)
     }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        searchController.searchBar.endEditing(true)
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = viewModel.cells[indexPath.row]
        
        switch viewModel.type {
        case .news(let newsInfo):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsCell.self)) as? NewsCell else {
                return UITableViewCell()
            }
            cell.viewModel = newsInfo
            return cell
        case .notFound:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotFoundCell.self)) as? NotFoundCell else {
                return UITableViewCell()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.cells.count - 1 &&  !viewModel.cells[indexPath.row].isNotFound {
              viewModel.getNews()
          }
      }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsViewModel = viewModel.cells[indexPath.row]
        if case let .news(newsInfo) = newsViewModel.type {
            let newsPage = NewsPageViewController(news: newsInfo)
            navigationController?.pushViewController(newsPage, animated: true)
        }
    }
}
