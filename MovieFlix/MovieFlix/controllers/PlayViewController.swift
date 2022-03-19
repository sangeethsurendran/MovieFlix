//
//  PlayViewController.swift
//  MovieFlix
//
//  Created by sangeeth on 18/03/2022.
//

import UIKit
import Alamofire
class PlayViewController: UIViewController {
    
    var image: UIImage?
    var url: String?
    var imageCache = NSCache<AnyObject, AnyObject>()
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //getImage()
        loadImage(urlString: url!)
    }
    
    func loadImage(urlString: String) {
        
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
            imageView.image = self.image
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Couldn't download image: ", error)
                return
            }
            
            guard let data = data else { return }
            let imageData = UIImage(data: data)
            self.imageCache.setObject(imageData!, forKey: urlString as AnyObject)
            
            DispatchQueue.main.async {
                self.image = imageData
                self.imageView.image = self.image
            }
        }.resume()

    }
    
    func getImage(){
        AF.request(url!, method: .get).response { response in
            switch response.result{
            case .success(let image):
                self.imageView.image = UIImage(data: image!, scale: 1)
            case .failure(let error):
                print("error is",error)
            }
        }
    }

}

//extension UIImageView {
//
//    func loadImage(urlString: String) {
//
//        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
//            self.image = cacheImage
//            return
//        }
//
//        guard let url = URL(string: urlString) else { return }
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                print("Couldn't download image: ", error)
//                return
//            }
//
//            guard let data = data else { return }
//            let image = UIImage(data: data)
//            imageCache.setObject(image, forKey: urlString as AnyObject)
//
//            DispatchQueue.main.async {
//                self.image = image
//            }
//        }.resume()
//
//    }
//}
