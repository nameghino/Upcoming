//
//  File.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

protocol MoviesPagedResponse: JSONDecodable {
    var movies: [Movie] { get }
    var currentPage: Int { get }
    var pageCount: Int { get }
    var moreAvailable: Bool { get }
}

extension MoviesPagedResponse {
    var moreAvailable: Bool {  return currentPage == pageCount }
}

protocol CastResponse: JSONDecodable {
    var cast: [MovieCharacter] { get }
}

protocol MoviesService {
    func fetchCast(movie: Movie, callback: @escaping (Result<[MovieCharacter]>) -> Void)
}

protocol PagedMoviesService: MoviesService {
    func fetchUpcomingMovies<T: MoviesPagedResponse>(page: Int, callback: @escaping (Result<T>) -> Void)
    func search<T: MoviesPagedResponse>(query: String, page: Int, callback: @escaping (Result<T>) -> Void)
}
