//
//  UpcomingTests.swift
//  UpcomingTests
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import XCTest

class MockPostersService: PostersService {
    let image = UIImage()
    func fetchPosterFor(movie: Movie, width: CGFloat, callback: @escaping (Result<UIImage>) -> Void) {
        callback(.success(image))
    }

    func fetchBackdropFor(movie: Movie, width: CGFloat, callback: @escaping (Result<UIImage>) -> Void) {
        callback(.success(image))
    }
}

class UpcomingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMoviesListViewModel() {
        let testExpectation = expectation(description: "test movies list view model")

        let service = TMDBService()

        let viewModel = UpcomingMoviesListViewModel<TMDBUpcomingMoviesResponse>(moviesService: service, postersService: service, searchStarter: nil)

        viewModel.onMoviesListUpdated = { viewModel in
            dump(viewModel.movies)
            testExpectation.fulfill()
            XCTAssert(viewModel.movies.count > 0)
        }

        viewModel.update()
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testMovieViewModel() {
        let movieData: JSONDictionary = [
                "poster_path": "/pTpxQB1N0waaSc3OSn0e9oc8kx9.jpg",
                "adult": false,
                "overview": "Eighties teenager Marty McFly is accidentally sent back in time to 1955, inadvertently disrupting his parents' first meeting and attracting his mother's romantic interest. Marty must repair the damage to history by rekindling his parents' romance and - with the help of his eccentric inventor friend Doc Brown - return to 1985.",
                "release_date": "1985-07-03",
                "genre_ids": [
                12,
                35,
                878,
                10751
                ],
                "id": 105,
                "original_title": "Back to the Future",
                "original_language": "en",
                "title": "Back to the Future",
                "backdrop_path": "/x4N74cycZvKu5k3KDERJay4ajR3.jpg",
                "popularity": 8.215055,
                "vote_count": 3506,
                "video": false,
                "vote_average": 7.77
        ]

        do {
            let movie = try Movie(container: movieData)
            let movieService = TMDBService()
            let viewModel = MovieViewModel(movie: movie, moviesService: movieService, postersService: MockPostersService())
            XCTAssert(viewModel.title == "Back to the Future")
        } catch (let error) {
            XCTFail("\(error)")
        }
    }
    
}
