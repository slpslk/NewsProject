//
//  Sorting.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 14.11.2024.
//

import Foundation

enum Sorting: String{
    case publishedAt
    case popularity
    
    func title() -> String {
        switch self {
        case .publishedAt:
            return "по дате"
        case .popularity:
            return "по популярности"
        }
    }
}
