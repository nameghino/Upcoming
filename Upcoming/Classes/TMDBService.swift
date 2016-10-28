//
//  TMDBService.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation

enum TMDBServiceError: Error {
    case noJSONData
}

private extension String {
    static let TMDBAPIKey = "1f54bd990f1cdfb230adb312546d765d"
}



class TMDBService: NSObject, PagedMoviesService {
    private let apiKey: String = String.TMDBAPIKey
    private let baseURL: URL

    init(baseURLString: String = "https://api.themoviedb.org/3/") {
        guard let baseURL = URL(string: baseURLString) else {
            fatalError("Base URL string for the TMDB Service is invalid")
        }
        self.baseURL = baseURL
    }

    func fetchUpcomingMovies(page: Int, callback: @escaping (Result<UpcomingMoviesPagedResponse>) -> Void) {
        let endpoint = "movie/upcoming"
        let url = baseURL.appendingPathComponent(endpoint)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("Could not extract components from given base URL")
        }

        components.queryItems = [
            URLQueryItem(name: "api_key", value: self.apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        guard let target = components.url else {
            fatalError("Could not build target URL")
        }

        print("hitting \(target.absoluteString)")

        let request = URLRequest(url: target)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                callback(.error(error!))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                fatalError("response is not an HTTPURLResponse")
            }

            guard let data = data else {
                callback(.error(TMDBServiceError.noJSONData))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
                if (200..<300) ~= response.statusCode {
                    let moviesResponse = try TMDBUpcomingMoviesResponse(container: json)
                    callback(.success(moviesResponse))
                } else {
                    let errorResponse = try TMDBServiceErrorResponse(container: json)
                    callback(.error(errorResponse))
                }
            } catch (let error) {
                callback(.error(error))
            }
        }
        task.resume()
    }
}

struct TMDBServiceErrorResponse: Error, JSONDecodable {
    private(set) var message: String
    private(set) var code: Int

    init(container: JSONDictionary) throws {
        message = try "status_message" <- container
        code = try "status_code" <- container
    }
}

struct TMDBUpcomingMoviesResponse: JSONDecodable, UpcomingMoviesPagedResponse {
    private(set) var page: Int
    private(set) var results: [Movie] = []
    private(set) var totalPages: Int
    private(set) var totalResults: Int
    
    init(container: JSONDictionary) throws {
        page = try "page" <- container
        totalPages = try "total_pages" <- container
        totalResults = try "total_results" <- container

        let resultArray: [JSONDictionary] = try "results" <- container
        results = try resultArray.map { try Movie(container: $0) }
    }

    var pageCount: Int { return totalPages }
    var currentPage: Int { return page }
    var movies: [Movie] { return results }
}
