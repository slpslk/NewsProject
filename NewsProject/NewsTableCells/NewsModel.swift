//
//  NewsModel.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 13.11.2024.
//

import Foundation

struct News: Decodable {
    let title: String
    let publishedAt: String
    let author: String?
    let description: String?
}

struct NewsTableCellViewModel {
    enum CellViewModelType {
        case news(News)
        case notFound
    }
    
    var type: CellViewModelType
}

extension NewsTableCellViewModel {
    var isNotFound: Bool {
        if case .notFound = type {
            return true
        }
        return false
    }
}
