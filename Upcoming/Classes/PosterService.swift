//
//  PosterService.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/31/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation
import UIKit

protocol PostersService {
    func fetchPosterFor(movie: Movie, width: CGFloat, callback: @escaping (Result<UIImage>) -> Void)
    func fetchBackdropFor(movie: Movie, width: CGFloat, callback: @escaping (Result<UIImage>) -> Void)
}
