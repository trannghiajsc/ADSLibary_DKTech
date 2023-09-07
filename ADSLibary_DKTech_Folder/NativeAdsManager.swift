//
//  NativeAdsManager.swift
//  GoogleAds-Framework-InHouse
//
//  Created by Pham Van Thai on 26/07/2023.
//

import Foundation
import UIKit
import GoogleMobileAds
import SkeletonView

enum TypeAds {
    case buttonTop
    case buttonBottom
}

 class NativeAdsManager {
    private var heightConstraint: NSLayoutConstraint?
    private var isBackupAdLoading: Bool = false
    private let idTestMode = "ca-app-pub-3940256099942544/2521693316"
    private var isLoadTestMode: Bool = false
     init() {
    }
    
     func adLoaderValue(vc: UIViewController?, backgroundNativeView: UIView?, adsNativeId: String?, nativeAdView: inout GADNativeAdView?, adLoader: inout GADAdLoader?, skeletonView: UIView?, borderBGWidth: CGFloat = 0.5, borderBGColor: CGColor?, bgColorNativeAds: UIColor?, colorButton: UIColor?, cornerRadius: CGFloat = 5, typeAds: TypeAds = .buttonBottom, loadTestMode: Bool = false) -> GADAdLoader? {
         var nibNameAds = "NativeAdViewTop"
         self.isLoadTestMode = loadTestMode
         var idNative = adsNativeId ?? ""
         if typeAds == .buttonBottom {
             nibNameAds = "NativeAdViewBottom"
         }
        guard
            let nibObjects = Bundle.main.loadNibNamed(nibNameAds, owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            assert(false, "Could not load nib file for adView")
            return adLoader
        }
        nativeAdView = adView
        guard let nativeAdView = nativeAdView else {
            return adLoader
        }
        nativeAdView.backgroundColor = bgColorNativeAds
        nativeAdView.callToActionView?.backgroundColor = colorButton
        nativeAdView.callToActionView?.layer.cornerRadius = cornerRadius
        setAdView(nativeView: nativeAdView, bgNativeView: backgroundNativeView, skeletonView: skeletonView, vc: vc, borderBGWidth: borderBGWidth, borderBGColor: borderBGColor)
         if loadTestMode {
             idNative = self.idTestMode
         }
        adLoader = GADAdLoader(adUnitID: idNative, rootViewController: vc, adTypes: [.native], options: nil)
        return adLoader
    }
    
    private func setAdView(nativeView: GADNativeAdView?, bgNativeView: UIView?, skeletonView: UIView?, vc: UIViewController?, borderBGWidth: CGFloat?, borderBGColor: CGColor? ) {
        // Remove the previous ad view.
        guard let nativeView = nativeView, let bgNativeView = bgNativeView, let borderBGWidth = borderBGWidth, let borderBGColor = borderBGColor, let skeletonView = skeletonView else {
            return
        }
        bgNativeView.addSubview(nativeView)
        nativeView.isHidden = true
        nativeView.translatesAutoresizingMaskIntoConstraints = false
        bgNativeView.layer.borderWidth = borderBGWidth
        bgNativeView.layer.borderColor = borderBGColor
        setupSkeleton(skeletonView: skeletonView , nativeAdsView: bgNativeView)
        
        //bgNativeView.addSubview(nativeView)
        nativeView.translatesAutoresizingMaskIntoConstraints = false
        let topNativeAdView = nativeView.topAnchor.constraint(equalTo: bgNativeView.topAnchor)
        let leadingNativeAdView = nativeView.leadingAnchor.constraint(equalTo: bgNativeView.leadingAnchor)
        let trailingNativeAdView = nativeView.trailingAnchor.constraint(equalTo: bgNativeView.trailingAnchor)
        let bottomNativeAdView = nativeView.bottomAnchor.constraint(equalTo: bgNativeView.bottomAnchor)
        NSLayoutConstraint.activate([topNativeAdView, leadingNativeAdView, trailingNativeAdView, bottomNativeAdView])
        let adLabel = UILabel()
        adLabel.text = "ad"
        adLabel.font = UIFont(name: <#T##String#>, size: <#T##CGFloat#>)
    }
    
    private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
    private func setupSkeleton( skeletonView : UIView?, nativeAdsView: UIView?) {
        
        guard let skeletonView = skeletonView, let nativeAdsView = nativeAdsView else {return}
        nativeAdsView.addSubview(skeletonView)
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        let bottom = skeletonView.bottomAnchor.constraint(equalTo: nativeAdsView.bottomAnchor)
        let top = skeletonView.topAnchor.constraint(equalTo: nativeAdsView.topAnchor)
        let trailing = skeletonView.trailingAnchor.constraint(equalTo: nativeAdsView.trailingAnchor)
        let leading = skeletonView.leadingAnchor.constraint(equalTo: nativeAdsView.leadingAnchor)
        NSLayoutConstraint.activate([bottom, top, trailing, leading])
        skeletonView.isSkeletonable = true
        skeletonView.showAnimatedGradientSkeleton()
        
        skeletonView.backgroundColor = .white
        let section1 = UIView()
        section1.backgroundColor = .white
        section1.layer.cornerRadius = 5
        section1.clipsToBounds = true
        skeletonView.addSubview(section1)
        section1.translatesAutoresizingMaskIntoConstraints = false
        let trailingSection1 = section1.trailingAnchor.constraint(equalTo: skeletonView.trailingAnchor,constant: -12)
        let topSection1 = section1.topAnchor.constraint(equalTo: skeletonView.topAnchor,constant: 6)
        let centerSection1 = section1.leadingAnchor.constraint(equalTo: skeletonView.leadingAnchor, constant: 12)
        let heightSection1 = section1.heightAnchor.constraint(equalToConstant: 120)
        NSLayoutConstraint.activate([topSection1, centerSection1, heightSection1, trailingSection1])
        section1.isSkeletonable = true
        section1.showAnimatedGradientSkeleton()
        
        let section2 = UIView()
        section2.backgroundColor = .white
        section2.layer.cornerRadius = 5
        section2.clipsToBounds = true
        skeletonView.addSubview(section2)
        section2.translatesAutoresizingMaskIntoConstraints = false
        let topSection2 = section2.topAnchor.constraint(equalTo: section1.bottomAnchor,constant: 12)
        let leadingSection2 = section2.leadingAnchor.constraint(equalTo: skeletonView.leadingAnchor,constant: 12)
        let trailingSection2 = section2.widthAnchor.constraint(equalToConstant: 80)
        let heightSection2 = section2.heightAnchor.constraint(equalToConstant: 80)
        NSLayoutConstraint.activate([topSection2, leadingSection2, trailingSection2, heightSection2])
        section2.isSkeletonable = true
        section2.showAnimatedGradientSkeleton()
        
        let section3 = UIView()
        section3.backgroundColor = .white
        section3.clipsToBounds = true
        skeletonView.addSubview(section3)
        section3.translatesAutoresizingMaskIntoConstraints = false
        let topSection3 = section3.topAnchor.constraint(equalTo: section1.bottomAnchor,constant: 12)
        let leadingSection3 = section3.leadingAnchor.constraint(equalTo: section2.trailingAnchor,constant: 22)
        let trailingSection3 = section3.trailingAnchor.constraint(equalTo: skeletonView.trailingAnchor,constant: -62)
        let heightSection3 = section3.heightAnchor.constraint(equalToConstant: 15)
        NSLayoutConstraint.activate([topSection3, leadingSection3, trailingSection3, heightSection3])
        section3.isSkeletonable = true
        section3.showAnimatedGradientSkeleton()
        
        let section4 = UIView()
        section4.backgroundColor = .white
        section4.clipsToBounds = true
        skeletonView.addSubview(section4)
        section4.translatesAutoresizingMaskIntoConstraints = false
        let topSection4 = section4.topAnchor.constraint(equalTo: section3.bottomAnchor,constant: 8)
        let leadingSection4 = section4.leadingAnchor.constraint(equalTo: section2.trailingAnchor,constant: 22)
        let trailingSection4 = section4.trailingAnchor.constraint(equalTo: skeletonView.trailingAnchor,constant: -12)
        let heightSection4 = section4.heightAnchor.constraint(equalToConstant: 15)
        NSLayoutConstraint.activate([topSection4, leadingSection4, trailingSection4, heightSection4])
        section4.isSkeletonable = true
        section4.showAnimatedGradientSkeleton()
        nativeAdsView.addSubview(skeletonView)
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        
        let section5 = UIView()
        section5.backgroundColor = .white
        section5.layer.cornerRadius = 2
        section5.clipsToBounds = true
        skeletonView.addSubview(section5)
        section5.translatesAutoresizingMaskIntoConstraints = false
        let topSection5 = section5.topAnchor.constraint(equalTo: section2.bottomAnchor,constant: 12)
        let leadingSection5 = section5.leadingAnchor.constraint(equalTo: skeletonView.leadingAnchor,constant: 12)
        let trailingSection5 = section5.trailingAnchor.constraint(equalTo: skeletonView.trailingAnchor,constant: -12)
        let heightSection5 = section5.heightAnchor.constraint(equalToConstant: 20)
        NSLayoutConstraint.activate([topSection5, leadingSection5, trailingSection5, heightSection5])
        section5.isSkeletonable = true
        section5.showAnimatedGradientSkeleton()
        
        let section6 = UIView()
        section6.backgroundColor = .white
        section6.clipsToBounds = true
        skeletonView.addSubview(section6)
        section6.translatesAutoresizingMaskIntoConstraints = false
        let topSection6 = section6.topAnchor.constraint(equalTo: section5.bottomAnchor,constant: 12)
        let leadingSection6 = section6.leadingAnchor.constraint(equalTo: skeletonView.leadingAnchor,constant: 12)
        let trailingSection6 = section6.trailingAnchor.constraint(equalTo: skeletonView.trailingAnchor,constant: -82)
        let heightSection6 = section6.heightAnchor.constraint(equalToConstant: 14)
        NSLayoutConstraint.activate([topSection6, leadingSection6, trailingSection6, heightSection6])
        section6.isSkeletonable = true
        section6.showAnimatedGradientSkeleton()
        
        let section7 = UIView()
        section7.backgroundColor = .white
        section7.layer.cornerRadius = 2
        section7.clipsToBounds = true
        skeletonView.addSubview(section7)
        section7.translatesAutoresizingMaskIntoConstraints = false
        let topSection7 = section7.topAnchor.constraint(equalTo: section4.bottomAnchor,constant: 16)
        let leadingSection7 = section7.leadingAnchor.constraint(equalTo: section2.trailingAnchor,constant: 22)
        let trailingSection7 = section7.trailingAnchor.constraint(equalTo: skeletonView.trailingAnchor,constant: -112)
        let heightSection7 = section7.heightAnchor.constraint(equalToConstant: 20)
        NSLayoutConstraint.activate([topSection7, leadingSection7, trailingSection7, heightSection7])
        section7.isSkeletonable = true
        section7.showAnimatedGradientSkeleton()
    }
    
     func showDataNativeAds(nativeAd: GADNativeAd?, nativeView: GADNativeAdView?, vc: UIViewController?, skeletonView: UIView?, textColor: UIColor?){
        guard let nativeAd = nativeAd, let vc = vc, let nativeView = nativeView, let skeletonView = skeletonView else {return}
        nativeAd.delegate = vc as? any GADNativeAdDelegate
        nativeView.isHidden = false
        skeletonView.isHidden = true
        heightConstraint?.isActive = false
        (nativeView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeView.headlineView as? UILabel)?.textColor = textColor
        nativeView.mediaView?.mediaContent = nativeAd.mediaContent
        
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            
            mediaContent.videoController.delegate = vc as? any GADVideoControllerDelegate
            print("Ad contains a video asset.")
        } else {
            print("Ad does not contain a video.")
        }
        
        (nativeView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeView.bodyView as? UILabel)?.textColor = textColor
        nativeView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeView.starRatingView?.isHidden = nativeAd.starRating == nil
        (nativeView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        (nativeView.advertiserView as? UILabel)?.textColor = textColor
        nativeView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        nativeView.callToActionView?.isUserInteractionEnabled = false
        
        nativeView.nativeAd = nativeAd
        
    }
    
     func getHeightAds(nativeAd: GADNativeAd?, widthScreen: CGFloat?) -> CGFloat {
        guard let nativeAd = nativeAd, let widthScreen = widthScreen else {
            return 0
        }
        var countHeight: CGFloat = 0
        let width = widthScreen - 88
        var heightHeadline = UILabel.textHeight(withWidth: width, font: UIFont.systemFont(ofSize: 12), text: nativeAd.headline ?? "")
        if heightHeadline > 14.5 {
            heightHeadline = heightHeadline - 14.5
        }else {
            heightHeadline = 0
        }
        
        var bodyHeight =  UILabel.textHeight(withWidth: UIScreen.main.bounds.width - 78, font: UIFont.systemFont(ofSize: 12), text: nativeAd.body ?? "")
        
        if bodyHeight > 14.5 {
            bodyHeight = bodyHeight - 14.5
        }else {
            bodyHeight = 0
        }
        countHeight = bodyHeight + heightHeadline
        if countHeight > 10 {
            countHeight = 294 + countHeight
            return countHeight
        }
        return 300
    }
    
     func adLoaderBackup(nativeView: GADNativeAdView?, vc: UIViewController?, backupAdNativeID: String?, skeletonView: UIView?, adLoader: inout GADAdLoader?, heightNativeAdsConstraint: inout NSLayoutConstraint?) {
        guard let nativeView = nativeView, let vc = vc, let skeletonView = skeletonView else {return}
         var backupAdNativeID = backupAdNativeID ?? ""
         if self.isLoadTestMode {
             backupAdNativeID = self.idTestMode
         }
        if !isBackupAdLoading {
            isBackupAdLoading = true
            adLoader = GADAdLoader(adUnitID: backupAdNativeID, rootViewController: vc, adTypes: [.native], options: nil)
            adLoader?.delegate = vc as? any GADAdLoaderDelegate
            adLoader?.load(GADRequest())
           
        }else {
            heightNativeAdsConstraint?.constant = 0
            nativeView.isHidden = true
            skeletonView.isHidden = true
        }
    }
}
