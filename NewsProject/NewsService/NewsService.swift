//
//  NewsService.swift
//  NewsProject
//
//  Created by Sofya Avtsinova on 13.11.2024.
//

import Foundation
import Combine

struct NewsResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [News]
}

final class NewsService {
    enum Constants {
        static let baseURL = "https://newsapi.org/v2/everything"
        static let lang = "&language=ru"
        static let pageSize = "&pageSize=20"
        static let apiKey = "780dc03769514ea889d6804486432118"
        static let requestDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        static let outputDateFormat = "d MMMM yyyy HH:mm"
    }
    
    private lazy var requestDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.requestDateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
    
    private let outputFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.outputDateFormat
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    func fetchNews(searchText: String, page: Int = 1, sort: Sorting) -> AnyPublisher<[News], URLFetchError> {
        guard let url = createURL(searchText: searchText, page: page, sort: sort) else {
            return Fail(error: URLFetchError.wrongURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["X-Api-Key": Constants.apiKey]
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLFetchError.wrongURL
                }
                return output.data
            }
            .decode(type: NewsResponse.self, decoder: JSONDecoder())
            .tryMap {
                do {
                    return try self.processResponse($0)
                } catch (let error) {
                    throw error
                }
            }
            .mapError { error in
                self.handleError(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

private extension NewsService {
    func createURL(searchText: String, page: Int, sort: Sorting) -> URL? {
        let queryString = "?q=\(searchText)&page=\(page)&sortBy=\(sort)\(Constants.lang)\(Constants.pageSize)"
        return URL(string: Constants.baseURL + queryString)
    }
    
    func processResponse(_ response: NewsResponse) throws -> [News] {
        guard response.totalResults > 0 else {
            throw URLFetchError.notFoundArticles
        }
        return response.articles.map { formatDate($0) }
    }

    func formatDate(_ article: News) -> News {
        if let date = requestDateFormatter.date(from: article.publishedAt) {
            let modifiedArticle  = News(title: article.title,
                                    publishedAt: outputFormatter.string(from: date),
                                    author: article.author,
                                    description: article.description)
            return modifiedArticle
        }
        return article
    }

    func handleError(_ error: Error) -> URLFetchError {
        error as? URLFetchError ?? .wrongURL
    }
}



    
