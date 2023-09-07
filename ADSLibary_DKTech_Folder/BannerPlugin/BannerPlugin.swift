//
//  BannerPlugin.swift
//  bannerplugin
//
//  Created by Hung Pham on 5/6/23.
//

import Foundation
import UIKit

class BannerPlugin {
    
    static let LOG_ENABLED = true
    
    class Config {
        var defaultAdUnitId: String
        var defaultBannerType: BannerType
        
        /**
         * Remote config key to retrieve banner config data remotely
         * */
        var configKey: String? = nil
        
        /**
         * Banner refresh rate, in seconds. Pub are recommended to disable auto refresh from dashboard
         * Most of the case this is used to refresh a collapsible banner manually
         * */
        var defaultRefreshRateSec: Int? = nil
        
        /**
         * In seconds, indicate minimum time b/w 2 collapsible banner requests.
         * Only works with BannerType.CollapsibleTop or BannerType.CollapsibleBottom
         * If it is the time to send ad request but the duration to last request collapsible banner < cbFetchInterval,
         * Adaptive banner will be shown instead.
         * */
        var defaultCBFetchIntervalSec: Int = 180
        
        var loadAdAfterInit = true
        
        required init(defaultAdUnitId: String, defaultBannerType: BannerType) {
            self.defaultAdUnitId = defaultAdUnitId
            self.defaultBannerType = defaultBannerType
        }
    }
    
    enum BannerType {
        case Standard,
             Adaptive,
             CollapsibleTop,
             CollapsibleBottom
    }
    
    private let rootViewController: UIViewController
    private let adContainer: UIView
    private let config: Config
    
    private var adViewController: BaseAdViewController? = nil
    
    required init(rootViewController: UIViewController, adContainer: UIView, config: Config) {
        self.rootViewController = rootViewController
        self.adContainer = adContainer
        self.config = config
        
        initViewAndConfig()
        
        if (config.loadAdAfterInit) {
            loadAd()
        }
    }
    
    static func fetchAndActivateRemoteConfig() {
        RemoteConfigManager.shared.fetchAndActivate()
    }
    
    private func initViewAndConfig() {
        var adUnitId = config.defaultAdUnitId
        var bannerType = config.defaultBannerType
        var cbFetchIntervalSec = config.defaultCBFetchIntervalSec
        var refreshRateSec: Int? = config.defaultRefreshRateSec
        
        if let key = config.configKey {
            let bannerConfig = RemoteConfigManager.shared.getBannerConfig(key: key)
            
            adUnitId = bannerConfig?.adUnitId ?? adUnitId
            switch (bannerConfig?.type) {
            case RemoteConfigManager.BannerConfig.TYPE_STANDARD: bannerType = BannerType.Standard
            case RemoteConfigManager.BannerConfig.TYPE_ADAPTIVE: bannerType = BannerType.Adaptive
            case RemoteConfigManager.BannerConfig.TYPE_COLLAPSIBLE_TOP: bannerType = BannerType.CollapsibleTop
            case RemoteConfigManager.BannerConfig.TYPE_COLLAPSIBLE_BOTTOM: bannerType = BannerType.CollapsibleBottom
            default:  break
            }
            refreshRateSec = bannerConfig?.refreshRateSec ?? refreshRateSec
            cbFetchIntervalSec = bannerConfig?.cbFetchIntervalSec ?? cbFetchIntervalSec
            
            log(message: "bannerConfig = \(String(describing: bannerConfig))")
        }
        
        log(message: "adUnitId = \(adUnitId) " +
            " - bannerType = \(bannerType) " +
            " - refreshRateSec = \(String(describing: refreshRateSec)) " +
            " - cbFetchIntervalSec = \(cbFetchIntervalSec)"
        )
        
        adViewController = BaseAdViewController.Factory.getAdView(
            adUnitId: adUnitId,
            bannerType: bannerType,
            refreshRateSec: refreshRateSec,
            cbFetchIntervalSec: cbFetchIntervalSec
        )
        
        if (adViewController == nil) {
            return
        }
        
        let adViewController = adViewController!
        let adView = adViewController.view!
        
        rootViewController.addChild(adViewController)
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        adContainer.addSubview(adView)
        adContainer.addConstraints([
            NSLayoutConstraint(item: adView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: adContainer,
                               attribute: .top, multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: adView,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: adContainer,
                               attribute: .left, multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: adView,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: adContainer,
                               attribute: .right, multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: adView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: adContainer,
                               attribute: .bottom, multiplier: 1,
                               constant: 0),
        ])
        
        adViewController.didMove(toParent: rootViewController)
    }
    
    func loadAd() {
        adViewController?.loadAd()
    }
}

func getCurrentMillis() -> Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
}

func log(message: String) {
    if (BannerPlugin.LOG_ENABLED) {
        print("BannerPlugin: " + message)
    }
}
