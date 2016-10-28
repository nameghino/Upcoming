//
//  File.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

typealias PagedMoviesServiceUpcomingMoviesCallback = (Result<UpcomingMoviesPagedResponse>) -> Void

protocol UpcomingMoviesPagedResponse {
    var movies: [Movie] { get }
    var currentPage: Int { get }
    var pageCount: Int { get }
}

protocol PagedMoviesService {
    func fetchUpcomingMovies(page: Int, callback: @escaping PagedMoviesServiceUpcomingMoviesCallback)
}
