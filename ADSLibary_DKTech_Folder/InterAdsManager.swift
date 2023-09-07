//
//  InterAdsManager.swift
//  Magnifier Magnifying Glass 10x
//
//  Created by Pham Van Thai on 07/08/2023.
//

import Foundation
import GoogleMobileAds

class InterAdsManager {
     init(){}
    static let shared = InterAdsManager()
    var idInter: String?
    var idInterBu: String?
    var interstitial: GADInterstitialAd?
    
    func setupNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadInter(_:)), name: NSNotification.Name("loadId"), object: nil)
    }
    
    @objc func loadInter(_ notification: Notification) {
        setupInterstitialAds(id: self.idInter ?? "", idBu: self.idInterBu ?? "")
    }
    
    func getInterstitial() -> GADInterstitialAd? {
        setupInterstitialAds(id: self.idInter ?? "", idBu: self.idInterBu ?? "")
        return self.interstitial
    }
    
    func setupInterstitialAds(id: String, idBu: String) {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: AdMobConstants.INTER_MY_PHOTO,
                                   request: request,
                                   completionHandler: { (ad, error) in
                
                if let error = error {
                    print("Failed to load interstitial ad1 with error: \(error.localizedDescription)")
                    GADInterstitialAd.load(withAdUnitID: idBu,
                                           request: request,
                                           completionHandler: {  (ad, error) in
                        if let error = error {
                            print("Failed to load interstitial ad2 with error: \(error.localizedDescription)")
    
                            return
                        }
                        self.interstitial = ad
                    }
                    )
                }else {
                    self.interstitial = ad
                }
            }
            )
        }
    
}
