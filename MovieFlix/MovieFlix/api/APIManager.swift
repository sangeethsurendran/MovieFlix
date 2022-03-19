//
//  APIManager.swift
//  MovieFlix
//
//  Created by sangeeth on 17/03/2022.
//

import Foundation
import Alamofire


class APIManager : NSObject{
    
    open class func  APIRoot() -> String {
        let root = "https://api.themoviedb.org/3/movie/"
        return root
    }
    
    open class func backDropPath() -> String {
        let root = "https://image.tmdb.org/t/p/original"
        return root
    }
    
    open class func posterPath() -> String {
        let root = "https://image.tmdb.org/t/p/w342"
        return root
    }
}
