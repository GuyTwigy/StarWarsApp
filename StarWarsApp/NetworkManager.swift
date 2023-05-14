//
//  NetworkManager.swift
//  StarWarsApp
//
//  Created by Guy Twig on 14/05/2023.
//

import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    let baseUrl = "https://swapi.dev/api/"
    
    func getPeople(pageNum: Int, completion: @escaping (PeopleModelData?) -> ()) {
        let peopleApi = baseUrl + "people/"
        let parameters = ["page": pageNum] as [String : Any]
        
        guard let url: URL = URL(string: peopleApi) else {
            completion(nil)
            print("fail to load URL")
            return
        }
        
        AF.request(url, parameters: parameters, encoding: URLEncoding.queryString).responseDecodable(of: PeopleModelData.self) { (response) in
            switch response.result {
            case .success(let result):
                completion(result)
            case .failure(let error):
                print("some indication of failure when trying to decode data error: \(error)")
                completion(nil)
            }
        }
    }
    
    
    
}
