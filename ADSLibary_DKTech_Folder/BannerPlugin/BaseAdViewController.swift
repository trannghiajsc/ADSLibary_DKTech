//
//  BaseAdView.swift
//  bannerplugin
//
//  Created by Hung Pham on 5/6/23.
//

import Foundation
import UIKit

class BaseAdViewController : UIViewController {
    
    private let refreshRateSec: Int?
    
    private var nextRefreshTime: Int64 = 0
    private var isPausedOrDestroy = false
    private var currentRefreshWork: DispatchWorkItem? = nil

    required init?(coder: NSCoder) {
        // Should not be used from storyboard or xib
        fatalError("init(coder:) has not been implemented")
    }
    
    init(refreshRateSec: Int?) {
        self.refreshRateSec = refreshRateSec
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func loadAd() {
        log(message: "LoadAd ...")
        
        nextRefreshTime = 0 // Not allow scheduling until ad request is done
        stopBannerRefreshScheduleIfNeed()
        
        loadAdInternal {
            log(message:"On load ad done ...")
            self.calculateNextBannerRefresh()
            if (!self.isPausedOrDestroy) {
                self.scheduleNextBannerRefreshIfNeed()
            }
        }
    }
    
    internal func loadAdInternal(onDone: @escaping () -> Void) {
        fatalError("loadAdInternal(onDone:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        onResume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onPause()
    }
    
    @objc func appMovedToBackground() {
        onPause()
    }
    
    @objc func appMovedToForeground() {
        onResume()
    }
    
    private func onResume() {
        isPausedOrDestroy = false
        scheduleNextBannerRefreshIfNeed()
    }
    
    private func onPause() {
        isPausedOrDestroy = true
        stopBannerRefreshScheduleIfNeed()
    }
    
    private func calculateNextBannerRefresh() {
        if (refreshRateSec == nil) {
            return
        }
        nextRefreshTime = getCurrentMillis() + Int64((refreshRateSec ?? 0) * 1000)
    }
    
    private func scheduleNextBannerRefreshIfNeed() {
        if (refreshRateSec == nil) {
            return
        }
        if (nextRefreshTime <= 0) {
            return
        }
        
        let delay = max(0, nextRefreshTime - getCurrentMillis())
        
        stopBannerRefreshScheduleIfNeed()
        log(message:"Ads are scheduled to show in \(delay) mils")
        
        currentRefreshWork = DispatchWorkItem(block: {
            self.loadAd()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay)), execute: currentRefreshWork!)
    }
    
    private func stopBannerRefreshScheduleIfNeed() {
        currentRefreshWork?.cancel()
        currentRefreshWork = nil
    }
    
    class Factory {
        static func getAdView(
            adUnitId: String,
            bannerType: BannerPlugin.BannerType,
            refreshRateSec: Int?,
            cbFetchIntervalSec: Int
        ) -> BaseAdViewController {
            switch (bannerType) {
            case BannerPlugin.BannerType.Adaptive,
                BannerPlugin.BannerType.Standard,
                BannerPlugin.BannerType.CollapsibleBottom,
                BannerPlugin.BannerType.CollapsibleTop: return BannerAdViewController(
                    adUnitId: adUnitId,
                    bannerType: bannerType,
                    refreshRateSec: refreshRateSec,
                    cbFetchIntervalSec: cbFetchIntervalSec
                )
            }
        }
    }
}
