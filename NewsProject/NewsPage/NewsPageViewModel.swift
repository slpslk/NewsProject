//
//  NewsPageViewModel.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 13.11.2024.
//

import Foundation

final class NewsPageViewModel {
    let title: String
    let publishedAt: String?
    let author: String?
    let description: String?
    
    init(news: News) {
        self.title = news.title
        self.publishedAt = news.publishedAt
        self.author = news.author
        self.description = news.description
    }
}
