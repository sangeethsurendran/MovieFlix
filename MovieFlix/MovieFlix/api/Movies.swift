//
//  Movies.swift
//  MovieFlix
//
//  Created by sangeeth on 17/03/2022.
//

import Foundation
import Alamofire


open class Movies: NSObject {
    let indicator = UIActivityIndicatorView()
    open func getMovies(_ url: String, onCompletion: @escaping (AFDataResponse<Data>) -> Void){
        indicator.startAnimating()
        
        let urlString = "\(APIManager.APIRoot())\(url)"
        print(urlString)
        AF.request(urlString, method: .get).responseData { response in
            onCompletion(response)
            self.indicator.stopAnimating()
        }
    }
    open func getData(_ url: String, onCompletion: @escaping (AFDataResponse<Data>) -> Void){
        indicator.startAnimating()
        
        let urlString = "\(APIManager.backDropPath())\(url)"
        print(urlString)
        AF.request(urlString, method: .get).responseData { response in
            onCompletion(response)
            self.indicator.stopAnimating()
        }

    }
}
