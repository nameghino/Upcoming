//
//  TMDBService.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation
import UIKit

enum TMDBServiceError: Error {
    case noJSONData
    case unknownResponse
    case noImageData
    case serviceNotConfigured
}

private extension String {
    static let TMDBAPIKey = "1f54bd990f1cdfb230adb312546d765d"
}

class TMDBService: NSObject {
    fileprivate struct TMDBServiceConfiguration: JSONDecodable {
        let imageConfiguration: TMDBPostersServiceConfiguration

        init(container: JSONDictionary) throws {
            let imageConfigurationDictionary: JSONDictionary = try "images" <- container
            imageConfiguration = try TMDBPostersServiceConfiguration(container: imageConfigurationDictionary)
        }
    }


    fileprivate struct TMDBPostersServiceConfiguration: JSONDecodable {
        let baseURL: URL
        let secureBaseURL: URL
        let backdropSizes: [String]
        let posterSizes: [String]
        let stillSizes: [String]

        init(container: JSONDictionary) throws {
            guard
                let baseURL = URL(string: (try "base_url" <- container)),
                let secureBaseURL = URL(string: (try "secure_base_url" <- container))
                else {
                    throw JSONDecodableError.transformError("url")
            }

            self.baseURL = baseURL
            self.secureBaseURL = secureBaseURL
            backdropSizes = try "backdrop_sizes" <- container
            posterSizes = try "poster_sizes" <- container
            stillSizes = try "still_sizes" <- container
        }
    }


    fileprivate let apiKey: String = String.TMDBAPIKey
    fileprivate let baseURL: URL
    fileprivate var serviceConfiguration: TMDBServiceConfiguration? = nil
    fileprivate var onServiceConfigured: ((Void) -> Void)? = nil

    var isConfigured: Bool { return serviceConfiguration != nil }

    init(baseURLString: String = "https://api.themoviedb.org/3/") {
        guard let baseURL = URL(string: baseURLString) else {
            fatalError("Base URL string for the TMDB Service is invalid")
        }
        self.baseURL = baseURL
        super.init()
        configureService()
    }

    fileprivate func requestFor(endpoint: String, method: String = "GET", parameters: [String : String] = [:]) -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("Could not extract components from given base URL")
        }

        var queryItems: [URLQueryItem] = parameters.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
        queryItems.append(URLQueryItem(name: "api_key", value: self.apiKey))
        components.queryItems = queryItems

        guard let target = components.url else {
            fatalError("Could not build target URL")
        }

        return URLRequest(url: target)
    }

    fileprivate static func processResponse<T: JSONDecodable>(data: Data?, response: URLResponse?, error: Error?) -> Result<T> {
        guard error == nil else {
            return .error(error!)
        }

        guard let response = response as? HTTPURLResponse else {
            fatalError("response is not an HTTPURLResponse")
        }

        guard let data = data else {
            return .error(TMDBServiceError.noJSONData)
        }

        do {
            let container = try JSONSerialization.jsonObject(with: data, options: [])

            if let json = container as? T.Container, (200..<300) ~= response.statusCode {
                let response = try T.init(container: json)
                return .success(response)
            } else if let json = container as? TMDBServiceErrorResponse.Container {
                let errorResponse = try TMDBServiceErrorResponse(container: json)
                return .error(errorResponse)
            } else {
                return .error(TMDBServiceError.unknownResponse)
            }
        } catch (let error) {
            return .error(error)
        }
    }

    func submit<T: JSONDecodable>(request: URLRequest, callback: @escaping (Result<T>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let result = TMDBService.processResponse(data: data, response: response, error: error) as Result<T>
            callback(result)
        }
        task.resume()
    }

    fileprivate func configureService() {
        let request = requestFor(endpoint: "configuration")
        submit(request: request) { [weak self] (result: Result<TMDBServiceConfiguration>) -> Void in
            guard let sself = self else { return }
            if case .success(let sc) = result {
                sself.serviceConfiguration = sc
                let genresRequest = sself.requestFor(endpoint: "genre/movie/list")
                sself.submit(request: genresRequest) { (genres: Result<TMBDGenresResponse>) in
                    sself.onServiceConfigured?()
                }
            }
        }
    }
}

extension TMDBService: PagedMoviesService {
    func fetchUpcomingMovies<T: MoviesPagedResponse>(page: Int, callback: @escaping (Result<T>) -> Void) {
        let parameters: [String : String] = [
            "page": "\(page)"
        ]
        let request = requestFor(endpoint: "movie/upcoming", parameters: parameters)
        submit(request: request, callback: callback)
    }

    private func fetchCast(movie: Movie, callback: @escaping (Result<TMDBCreditsResponse>) -> Void) {
        let request = requestFor(endpoint: "movie/\(movie.id)/credits")
        submit(request: request, callback: callback)
    }

    func fetchCast(movie: Movie, callback: @escaping (Result<[MovieCharacter]>) -> Void) {
        fetchCast(movie: movie) { (result: Result<TMDBCreditsResponse>) -> Void in
            switch result {
            case .success(let response):
                callback(.success(response.cast))
            case .error(let error):
                callback(.error(error))
            }
        }
    }

    func search<T: MoviesPagedResponse>(query: String, page: Int, callback: @escaping (Result<T>) -> Void) {
        let parameters: [String : String] = [
            "query": query,
            "page": "\(page)",
            "include_adult": "false"
        ]

        let request = requestFor(endpoint: "search/movie", parameters: parameters)
        submit(request: request, callback: callback)

    }
}

extension TMDBService: PostersService {

    private enum MovieImage {
        case poster(Movie, CGFloat, TMDBServiceConfiguration)
        case backdrop(Movie, CGFloat, TMDBServiceConfiguration)

        private var sizes: [String] {
            switch self {
            case .poster(_, _, let sc):
                return sc.imageConfiguration.posterSizes
            case .backdrop(_, _, let sc):
                return sc.imageConfiguration.backdropSizes
            }
        }

        private var desiredWidth: CGFloat {
            switch self {
            case .poster(_, let width, _):
                return width
            case .backdrop(_, let width, _):
                return width
            }
        }

        private var serviceConfiguration: TMDBServiceConfiguration {
            switch self {
            case .poster(_, _, let sc):
                return sc
            case .backdrop(_, _, let sc):
                return sc
            }
        }

        private var sizeKey: String {
            let widthKey: String = {
                for key in sizes {
                    let keyWidth = key.replacingOccurrences(of: "w", with: "")
                    let size = CGFloat(Float(keyWidth)!)
                    if size > desiredWidth {
                        return key
                    }
                }
                return "original"
            }()
            return widthKey
        }

        private var targetPath: String? {
            switch self {
            case .backdrop(let movie, _, _):
                return movie.backdropPath
            case .poster(let movie, _, _):
                return movie.posterPath
            }
        }

        var url: URL {
            let baseURL = serviceConfiguration.imageConfiguration.secureBaseURL
            guard
                let posterPath = targetPath else { fatalError("movie has no poster") }
            let endpoint = sizeKey.appending(posterPath)
            return baseURL.appendingPathComponent(endpoint)
        }

        var description: String {
            switch self {
            case .backdrop(_, _, _):
                return "backdrop"
            case .poster(_, _, _):
                return "poster"
            }
        }
    }

    private func fetch(imageURL url: URL, callback: @escaping(Result<UIImage>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let posterData = try Data(contentsOf: url)
                guard let image = UIImage(data: posterData) else {
                    callback(.error(TMDBServiceError.noImageData))
                    return
                }
                let result = Result.success(image)
                callback(result)
            } catch (let error) {
                callback(.error(error))
            }
        }
    }

    func fetchPosterFor(movie: Movie, width: CGFloat, callback: @escaping (Result<UIImage>) -> Void) {
        guard let sc = serviceConfiguration else {
            callback(.error(TMDBServiceError.serviceNotConfigured))
            return
        }
        let url = MovieImage.poster(movie, width, sc).url
        NSLog("fetching poster \(url.absoluteString)")
        fetch(imageURL: url, callback: callback)
    }

    func fetchBackdropFor(movie: Movie, width: CGFloat, callback: @escaping (Result<UIImage>) -> Void) {
        guard let sc = serviceConfiguration else {
            callback(.error(TMDBServiceError.serviceNotConfigured))
            return
        }
        let spec = MovieImage.backdrop(movie, width, sc)
        let url = spec.url
        NSLog("fetching \(spec.description) \(url.absoluteString)")
        fetch(imageURL: url, callback: callback)
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

struct TMDBUpcomingMoviesResponse: MoviesPagedResponse {
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

struct TMBDGenresResponse: JSONDecodable {
    private(set) var genres: [Genre]
    
    init(container: JSONDictionary) throws {
        let gs: [JSONDictionary] = try "genres" <- container
        genres = try gs.map { try Genre(container: $0) }
    }
}

struct TMDBCreditsResponse: CastResponse {
    private(set) var cast: [MovieCharacter]

    init(container: JSONDictionary) throws {
        let cast: [JSONDictionary] = try "cast" <- container
        self.cast = try cast.map { try MovieCharacter(container: $0) }.sorted()
    }
}
