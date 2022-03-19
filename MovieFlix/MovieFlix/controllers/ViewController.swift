//
//  ViewController.swift
//  MovieFlix
//
//  Created by sangeeth on 17/03/2022.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UICollectionViewDataSource {
    
    
    @IBOutlet weak var nowPlayingCollectionView: UICollectionView!
    
    var image: UIImage?
    let api = Movies()
    var nowPlaying: NowPlaying!
    var results = [Result]()
    var resultsData = [Result]()
    var cachedImages = [UIImage]()
    private let cache = NSCache<NSNumber, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "MovieFlix"
        
        getMoviesList()
        nowPlayingCollectionView.reloadData()
        
    }
    
    
    @IBAction func didTapDelete(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let alert = UIAlertController(title: "Alert", message: "Proceed to delete.?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.results.remove(at: indexPath.row)
            self.nowPlayingCollectionView.deleteItems(at: [indexPath])
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
        
    }
    
    
    
    func getMoviesList(){
        
        let url = "now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
        
        api.getMovies(url) { response in
            DispatchQueue.main.async {
                if let data = response.data{
                    let json = try? JSONDecoder().decode(NowPlaying.self, from: data)
                    if let results = json?.results{
                        self.results = results
                        self.resultsData = self.results
                        self.nowPlayingCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func loadImage(url: String,completion: @escaping (UIImage?) -> ()) {
        utilityQueue.async {
            if let urlPath = URL(string: url){
                guard let data = try? Data(contentsOf: urlPath) else { return }
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                    return
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if results[indexPath.row].voteCount! < 7{
            let cell = nowPlayingCollectionView.dequeueReusableCell(withReuseIdentifier: "UnPopularCell", for: indexPath) as! UnPopularCell
            cell.deleteBtn.tag = indexPath.item
            cell.deleteBtn.setTitle("", for: .normal)
            cell.imageView.layer.cornerRadius = 5
            cell.titleLabel.text = results[indexPath.item].title
            cell.descriptionLabel.text = results[indexPath.item].overview
            return cell
        }
        let cell = nowPlayingCollectionView.dequeueReusableCell(withReuseIdentifier: "PopularCell", for: indexPath) as! PopularCell
        cell.deleteBtn.tag = indexPath.item
        cell.imageView.layer.cornerRadius = 5
        cell.deleteBtn.setTitle("", for: .normal)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if results[indexPath.item].voteCount! < 7{
            if let cell = cell as? UnPopularCell{
                let itemNumber = NSNumber(value: indexPath.item)
                cachedImages.removeAll()
                if let cachedImage = self.cache.object(forKey: itemNumber) {
                    cachedImages.append(cachedImage)
                } else {
                    let path = "\(APIManager.posterPath())"
                    let url = path+results[indexPath.row].posterPath!
                    self.loadImage(url: url) { [weak self] (image) in
                        guard let self = self, let image = image else { return }
                        self.image = image
                        cell.imageView.image = image
                        self.cache.setObject(image, forKey: itemNumber)
                    }
                }
            }
        }else if let cell = cell as? PopularCell{
            let itemNumber = NSNumber(value: indexPath.item)
            cachedImages.removeAll()
            if let cachedImage = self.cache.object(forKey: itemNumber) {
                cachedImages.append(cachedImage)
            } else {
                let path = "\(APIManager.backDropPath())"
                let url = path+results[indexPath.row].backdropPath!
                self.loadImage(url: url) { [weak self] (image) in
                    guard let self = self, let image = image else { return }
                    self.image = image
                    cell.imageView.image = image
                    self.cache.setObject(image, forKey: itemNumber)
                }
            }
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let play = storyboard?.instantiateViewController(withIdentifier: "PlaySB") as? PlayViewController
        let path = "\(APIManager.posterPath())"
        let urlString = path+results[indexPath.item].posterPath!
        play?.url = urlString
        navigationController?.pushViewController(play!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchBarView", for: indexPath)

             return headerView
         }

         return UICollectionReusableView()

    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width , height: 200 )
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search text is: \(searchBar.text)")
        self.results.removeAll()
        if(!(searchBar.text?.isEmpty)!){
            for item in self.resultsData{
                if((item.title!.lowercased().contains(searchBar.text!.lowercased()))){
                    self.results.append(item)
                }
            }
            
        }else{
            self.results = self.resultsData
        }
        self.nowPlayingCollectionView?.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            self.results = self.resultsData
            self.nowPlayingCollectionView?.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.results = self.resultsData
    }
}


