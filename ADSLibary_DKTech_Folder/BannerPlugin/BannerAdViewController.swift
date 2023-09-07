//
//  BannerAdView.swift
//  bannerplugin
//
//  Created by Hung Pham on 5/6/23.
//

import Foundation
import GoogleMobileAds

class BannerAdViewController : BaseAdViewController, GADBannerViewDelegate {
    
    private var lastCBRequestTime : Int64 = 0
    
    let adUnitId: String
    private let bannerType: BannerPlugin.BannerType
    private let cbFetchIntervalSec: Int
    
    private let adView: GADBannerView
    private var hasSetAdSize = false
    
    private var onAdLoadDone : (() -> Void)? = nil
    
    required init?(coder: NSCoder) {
        // Should not be used from storyboard or xib
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(adUnitId: String, bannerType: BannerPlugin.BannerType, refreshRateSec: Int?, cbFetchIntervalSec: Int) {
        self.adUnitId = adUnitId
        self.bannerType = bannerType
        self.cbFetchIntervalSec = cbFetchIntervalSec
        
        adView = GADBannerView()
        
        super.init(refreshRateSec: refreshRateSec)        
        
        adView.rootViewController = self
        adView.adUnitID = adUnitId
        
        attachAdViewToMainView(adView: adView)
        
    }
    
    private func attachAdViewToMainView(adView: GADBannerView) {
        adView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adView)
        view.addConstraints(
            [NSLayoutConstraint(item: adView,
                                attribute: .centerY,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .centerY,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: adView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    override func loadAdInternal(onDone: @escaping () -> Void) {
        if (!hasSetAdSize) {
            // Wait until view is rendered
            DispatchQueue.main.async {
                let adSize = self.getAdSize(bannerType: self.bannerType)
                self.adView.adSize = adSize
                
                // Update layout width & height by ad size
                if let rootView = self.view {
                    rootView.addConstraints([
                        NSLayoutConstraint(item: rootView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adSize.size.width),
                        NSLayoutConstraint(item: rootView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: adSize.size.height)
                    ])
                }
                
                self.hasSetAdSize = true
                self.doLoadAd(onDone: onDone)
            }
        } else {
            doLoadAd(onDone: onDone)
        }
    }
    
    private func getAdSize(bannerType: BannerPlugin.BannerType) -> GADAdSize {
        switch (bannerType) {
        case BannerPlugin.BannerType.Standard: return GADAdSizeBanner
        case BannerPlugin.BannerType.Adaptive,
            BannerPlugin.BannerType.CollapsibleBottom,
            BannerPlugin.BannerType.CollapsibleTop: return getAdaptiveSize()
        }
    }
    
    private func getAdaptiveSize() -> GADAdSize {
        var frame: CGRect
        
        if #available(iOS 11.0, *) {
            frame = view.frame.inset(by: view.safeAreaInsets)
        } else {
            frame = view.frame
        }
        
        var viewWidth = frame.size.width
        
        // Fallback to screen width if viewWidth = 0
        if (viewWidth == 0) {
            viewWidth = UIScreen.main.bounds.width
        }
        
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        return adSize
    }
    
    private func doLoadAd(onDone: @escaping () -> Void) {
        var isCollapsibleBannerRequest = false
        
        let adRequest = GADRequest()
        switch (bannerType) {
        case BannerPlugin.BannerType.CollapsibleTop,
            BannerPlugin.BannerType.CollapsibleBottom:
            log(message: "shouldRequestCollapsible() = \(shouldRequestCollapsible())")
            
            if (shouldRequestCollapsible()) {
                let position = bannerType == BannerPlugin.BannerType.CollapsibleTop ? "top" : "bottom"
                let extras = GADExtras()
                extras.additionalParameters = ["collapsible": position]
                adRequest.register(extras)
                isCollapsibleBannerRequest = true
            }
        case .Standard: break
        case .Adaptive: break
        }
        
        if (isCollapsibleBannerRequest) {
            lastCBRequestTime = getCurrentMillis()
        }
        
        onAdLoadDone = onDone
        adView.delegate = self
        adView.load(adRequest)
    }
    
    private func shouldRequestCollapsible() -> Bool {
        return getCurrentMillis() - lastCBRequestTime >= cbFetchIntervalSec * 1000
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        adView.delegate = nil
        onAdLoadDone?()
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        adView.delegate = nil
        onAdLoadDone?()
    }
}
