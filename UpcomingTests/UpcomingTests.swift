//
//  UpcomingTests.swift
//  UpcomingTests
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import XCTest

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

        let service: PagedMoviesService = TMDBService()
        let viewModel = MoviesListViewModel(service: service)

        viewModel.onMoviesListUpdated = { viewModel in
            dump(viewModel.movies)
            testExpectation.fulfill()
        }

        viewModel.update()
        waitForExpectations(timeout: 10.0, handler: nil)
    }

}
