//
//  MoviesListViewModel.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation
import UIKit

class MoviesListViewModel<T: MoviesPagedResponse>: NSObject {
    let moviesService: PagedMoviesService
    let postersService: PostersService
    let viewController: UIViewController

    internal(set) var movies: [MovieViewModel] = [] {
        didSet {
            onMoviesListUpdated?(self)
        }
    }

    var pageToFetch: Int = 1
    internal(set) var done: Bool = false

    var onError: ((Error) -> Void)? = nil
    var onMoviesListUpdated: ((MoviesListViewModel) -> Void)? = nil

    var leftBarButtonItem: UIBarButtonItem? { return nil }
    var rightBarButtonItem: UIBarButtonItem? { return nil }
    var title: String { return "" }

    init(moviesService: PagedMoviesService, postersService: PostersService, viewController: UIViewController) {
        self.moviesService = moviesService
        self.postersService = postersService
        self.viewController = viewController
    }

    func update() { }
}
