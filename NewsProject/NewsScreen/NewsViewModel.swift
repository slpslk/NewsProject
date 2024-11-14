//
//  NewsViewModel.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 13.11.2024.
//

import Foundation
import Combine

final class NewsViewModel {
    @Published var searchText: String = ""
    @Published var sortingType: Sorting = .publishedAt
    @Published var cells: [NewsTableCellViewModel] = []
    
    private var news: [News] = []
    private var cancellables = Set<AnyCancellable>()
    private let newsService = NewsService()
    private var pageNumber = 1
    
    init() {
        setupBindings()
    }
    
    func getNews() {
        self.newsService.fetchNews(searchText: searchText, page: pageNumber, sort: sortingType)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                     self?.cells = [.init(type: .notFound)]
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] news in
                self?.handleFetchedNews(news)
            })
            .store(in: &self.cancellables)
    }
}

private extension NewsViewModel {
    func setupBindings() {
        bindSearchText()
        bindSortingType()
    }
    
    func bindSearchText() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter {$0.count > 2}
            .sink { [weak self] text in
                self?.searchText = text
                self?.resetPagination()
                self?.getNews()
            }
            .store(in: &cancellables)
    }
    
    func bindSortingType() {
        $sortingType
            .removeDuplicates()
            .sink { [weak self] sort in
                if !(self?.news.isEmpty ?? true) {
                    self?.sortingType = sort
                    self?.resetPagination()
                    self?.getNews()
                }
            }
            .store(in: &cancellables)
    }
    
    func resetPagination() {
        pageNumber = 1
        news.removeAll()
        cells.removeAll()
    }
    func handleFetchedNews(_ news: [News]) {
            if cells.contains(where: { $0.isNotFound }) || pageNumber == 1 {
                cells.removeAll()
            }
            self.news.append(contentsOf: news)
            cells.append(contentsOf: news.map { NewsTableCellViewModel(type: .news($0)) })
            pageNumber += 1
        }
}
