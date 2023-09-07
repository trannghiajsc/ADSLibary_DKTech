//
//  BannerAds.swift
//  GoogleAds-Framework-InHouse
//
//  Created by VietDA on 02/08/2023.
//

import Foundation
import GoogleMobileAds
import SkeletonView

 class BannerAds {
     init(){
         //heightForBanner()
         
     }
    var bannerView: GADBannerView!
     var isFirstReloadBanner: Bool = false
     var safeAreaBottom: CGFloat = 0
     var heightBanner: CGFloat = 50
     var isLoadTestMode: Bool = false
     let idTestMode = "ca-app-pub-3940256099942544/2934735716"
     func addBannerViewToView(vc:UIViewController?, bgSkeletonView: UIView?, adSize: GADAdSize, adUnitID: String, loadTestMode: Bool = false, bgBanner: UIView?) {
         self.isLoadTestMode = loadTestMode
         var idBanner = adUnitID
         if loadTestMode {
             idBanner = self.idTestMode
         }
        guard let vc = vc,
              let bgBanner = bgBanner
         else {return}
         bannerView = GADBannerView(adSize: adSize)
         bannerView.layer.borderWidth = 1
         bannerView.layer.borderColor = UIColor.black.cgColor
         bannerView.translatesAutoresizingMaskIntoConstraints = false
         bgBanner.addSubview(bannerView)
        setupSkeletonBanner(vc: vc, bgSkeletonView: bgSkeletonView)
         NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: bgBanner.bottomAnchor),
            bannerView.trailingAnchor.constraint(equalTo: bgBanner.trailingAnchor),
            bannerView.leadingAnchor.constraint(equalTo: bgBanner.leadingAnchor),
            bannerView.topAnchor.constraint(equalTo: bgBanner.topAnchor),
         ])
        
        bannerView.adUnitID = idBanner
        bannerView.rootViewController = vc
        bannerView.delegate = vc as? any GADBannerViewDelegate
         DispatchQueue.global().async {
             self.bannerView.load(GADRequest())
         }
    }
     
     func reloadBannerView(vc:UIViewController?, bgSkeletonView: UIView?, adUnitID: String) -> Bool {
         var idBanner = adUnitID
         if self.isLoadTestMode {
             idBanner = self.idTestMode
         }
         if !isFirstReloadBanner {
             isFirstReloadBanner = true
             bannerView.adUnitID = idBanner
             bannerView.rootViewController = vc
             bannerView.delegate = vc as? any GADBannerViewDelegate
             DispatchQueue.global().async {
                 self.bannerView.load(GADRequest())
             }
             return true
         }else {
             bgSkeletonView?.isHidden = true
             bannerView.isHidden = true
             return false
         }
     }
     func reloadBanner(bgSkeletonView: UIView?) {
         if NetworkManager.shared.isConnected() {
             bgSkeletonView?.isHidden = false
             DispatchQueue.global().async {
                 self.bannerView.load(GADRequest())
             }
         }
     }
//     func reloadBanner(bgSkeletonView: UIView?, heightBannerAdsConstraint: inout NSLayoutConstraint) {
//         if NetworkManager.shared.isConnected() {
//             heightBannerAdsConstraint.constant = 50
//             bgSkeletonView?.isHidden = false
//             DispatchQueue.global().async {
//                 self.bannerView.load(GADRequest())
//             }
//         }else {
//             heightBannerAdsConstraint.constant = 0
//         }
//     }
     
     private func heightForBanner() {
         let window = UIApplication.shared.windows.first
        safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
         if safeAreaBottom > 14 {
             safeAreaBottom = -14
             heightBanner = 36
         }
     }
     
    private func setupSkeletonBanner(vc: UIViewController?, bgSkeletonView: UIView?){
        guard let vc = vc, let bgSkeletonView = bgSkeletonView  else{return}
        bgSkeletonView.backgroundColor = .white
        vc.view.addSubview(bgSkeletonView)
        bgSkeletonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgSkeletonView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            bgSkeletonView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            bgSkeletonView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            bgSkeletonView.heightAnchor.constraint(equalToConstant: 50)
        ])
        bgSkeletonView.isSkeletonable = true
        bgSkeletonView.showAnimatedGradientSkeleton()
        
        let section1 = UIView()
        section1.backgroundColor = .white
        bgSkeletonView.addSubview(section1)
        section1.translatesAutoresizingMaskIntoConstraints = false
        let topSection1 = section1.topAnchor.constraint(equalTo: bannerView.topAnchor)
        let leadingSection1 = section1.leadingAnchor.constraint(equalTo: bgSkeletonView.leadingAnchor)
        let trailingSection1 = section1.trailingAnchor.constraint(equalTo: bgSkeletonView.trailingAnchor)
        let bottomSection1 = section1.bottomAnchor.constraint(equalTo: bgSkeletonView.bottomAnchor)
        NSLayoutConstraint.activate([topSection1, leadingSection1, trailingSection1, bottomSection1])
        
        
        let section2 = UIView()
        section2.backgroundColor = .gray
        bgSkeletonView.addSubview(section2)
        section2.translatesAutoresizingMaskIntoConstraints = false
        let topSection2 = section2.leadingAnchor.constraint(equalTo: section1.leadingAnchor, constant: 12)
        let leadingSection2 = section2.topAnchor.constraint(equalTo: section1.topAnchor, constant: 6)
        //let trailingSection2 = section2.trailingAnchor.constraint(equalTo: bgSkeletonView.trailingAnchor,constant: -12)
        let bottomSection2 = section2.heightAnchor.constraint(equalToConstant: 40)
        let widthSection2 = section2.widthAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([topSection2, leadingSection2, widthSection2, bottomSection2])
        section2.isSkeletonable = true
        section2.showAnimatedGradientSkeleton()
        
        
        let section3 = UIView()
        section3.backgroundColor = .gray
        bgSkeletonView.addSubview(section3)
        section3.translatesAutoresizingMaskIntoConstraints = false
        let topSection3 = section3.topAnchor.constraint(equalTo: section2.topAnchor, constant: 0)
        let leadingSection3 = section3.leadingAnchor.constraint(equalTo: section2.trailingAnchor,constant: 12)
        let trailingSection3 = section3.trailingAnchor.constraint(equalTo: bgSkeletonView.trailingAnchor,constant: -12)
        let bottomSection3 = section3.heightAnchor.constraint(equalToConstant: 12)
        NSLayoutConstraint.activate([topSection3, leadingSection3, trailingSection3, bottomSection3])
        section3.isSkeletonable = true
        section3.showAnimatedGradientSkeleton()
        
        let section4 = UIView()
        section4.backgroundColor = .gray
        bgSkeletonView.addSubview(section4)
        section4.translatesAutoresizingMaskIntoConstraints = false
        let topSection4 = section4.topAnchor.constraint(equalTo: section3.bottomAnchor, constant: 4)
        let leadingSection4 = section4.leadingAnchor.constraint(equalTo: section2.trailingAnchor,constant: 12)
        let trailingSection4 = section4.widthAnchor.constraint(equalToConstant: 120)
        let bottomSection4 = section4.heightAnchor.constraint(equalToConstant: 12)
        NSLayoutConstraint.activate([topSection4, leadingSection4, trailingSection4, bottomSection4])
        section4.isSkeletonable = true
        section4.showAnimatedGradientSkeleton()
        
        let section5 = UIView()
        section5.backgroundColor = .gray
        bgSkeletonView.addSubview(section5)
        section5.translatesAutoresizingMaskIntoConstraints = false
        let topSection5 = section5.topAnchor.constraint(equalTo: section4.bottomAnchor, constant: 4)
        let leadingSection5 = section5.leadingAnchor.constraint(equalTo: section2.trailingAnchor,constant: 12)
        let trailingSection5 = section5.trailingAnchor.constraint(equalTo: bgSkeletonView.trailingAnchor,constant: -62)
        let bottomSection5 = section5.heightAnchor.constraint(equalToConstant: 12)
        NSLayoutConstraint.activate([topSection5, leadingSection5, trailingSection5, bottomSection5])
        section5.isSkeletonable = true
        section5.showAnimatedGradientSkeleton()
        
    }
    
}
