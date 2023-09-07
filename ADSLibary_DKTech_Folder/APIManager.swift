//
//  APIManager.swift
//  Lie Detector
//
//  Created by Pham Van Thai on 04/08/2023.
//

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    var adsID: ADS?
    var isLoadSuccess:Bool = false
    var adIDs: [String: String] = [:]
    private init () {}
    
    func fetchDataFromAPI(completion: @escaping (Bool) -> Void) {
        let apiUrl = AdMobConstants.API_URL
        AF.request(apiUrl).responseDecodable(of: ADS.self) { response in
               switch response.result {
               case .success(let adsData):
                   self.adsID = adsData
                   for adID in adsData.data {
                       if let i = adID as Datum?, let keyName = i.name {
                           self.adIDs[keyName] = i.id
                       }
                   }
                   self.isLoadSuccess = true
                   print("dictionnary\(self.adIDs)")
                   AppOpenAdManager.shared.loadAd()
                   OnResumeManager.shared.loadAd()
                   completion(true)
               case .failure(let error):
                   print("Error: \(error.localizedDescription)")
                   completion(false)
                   self.isLoadSuccess = false
               }
           }
    }
}
