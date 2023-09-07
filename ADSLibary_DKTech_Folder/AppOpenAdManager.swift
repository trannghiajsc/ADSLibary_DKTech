//
//  AppOpenAdManager.swift
//  GoogleAds-Framework-InHouse
//
//  Created by Pham Van Thai on 27/07/2023.
//

import UIKit
import GoogleMobileAds

// Public protocol for the delegate
protocol AppOpenAdManagerDelegate: AnyObject {
  /// Method to be invoked when an app open ad is complete (i.e. dismissed or fails to show).
  func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AppOpenAdManager)
    func appWillOpenAds(_ appOpenAdManager: AppOpenAdManager, isSuccess: Bool)
}

class AppOpenAdManager: NSObject {
  /// Ad references in the app open beta will time out after four hours,
  /// but this time limit may change in future beta versions. For details, see:
  /// https://support.google.com/admob/answer/9341964?hl=en
  let timeoutInterval: TimeInterval = 4 * 3_600
  /// The app open ad.
  var appOpenAd: GADAppOpenAd?
  /// Maintains a reference to the delegate.
  weak var appOpenAdManagerDelegate: AppOpenAdManagerDelegate?
  /// Keeps track of if an app open ad is loading.
  var isLoadingAd = false
  /// Keeps track of if an app open ad is showing.
  var isShowingAd = false
  /// Keeps track of the time when an app open ad was loaded to discard expired ad.
  var loadTime: Date?
    
  var overlayView: UIView?

  var isFirtsLoadAOA: Bool = false
    let idAOA = "ca-app-pub-3940256099942544/5662855259"
    var isLoadTestMode: Bool = false
    
  static let shared = AppOpenAdManager()

  private func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
    // Check if ad was loaded more than n hours ago.
    if let loadTime = loadTime {
      return Date().timeIntervalSince(loadTime) < timeoutInterval
    }
    return false
  }

  private func isAdAvailable() -> Bool {
    // Check if ad exists and can be shown.
    return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: timeoutInterval)
  }

  private func appOpenAdManagerAdDidComplete() {
    // The app open ad is considered to be complete when it dismisses or fails to show,
    // call the delegate's appOpenAdManagerAdDidComplete method if the delegate is not nil.
    appOpenAdManagerDelegate?.appOpenAdManagerAdDidComplete(self)
  }

    private func appWillOpenAds(isSuccess: Bool) {
        appOpenAdManagerDelegate?.appWillOpenAds(self, isSuccess: isSuccess)
    }
    func loadAd(loadTestMode: Bool = false) {
        self.isLoadTestMode = loadTestMode
        // Do not load ad if there is an unused ad or one is already loading.
        if isLoadingAd || isAdAvailable() {
            return
        }
        isLoadingAd = true
        var idAOA1 = AdMobConstants.AOA_SPLASH_BU
        var idAOA2 = AdMobConstants.AOA_SPLASH_2_BU
        if loadTestMode {
            idAOA1 = self.idAOA
            idAOA2 = self.idAOA
        }else {
            if let id1 = APIManager.shared.adIDs[AdMobConstants.AOA_SPLASH],
               let id2 = APIManager.shared.adIDs[AdMobConstants.AOA_SPLASH_2]
            {
                idAOA1 = id1
                idAOA2 = id2
            }
        }
    GADAppOpenAd.load(
        withAdUnitID: idAOA1,
      request: GADRequest(),
      orientation: UIInterfaceOrientation.portrait
    ) { ad, error in
      self.isLoadingAd = false
        if error != nil {
          if !self.isFirtsLoadAOA {
              self.isFirtsLoadAOA = true
              GADAppOpenAd.load(
                  withAdUnitID: idAOA2,
                request: GADRequest(),
                orientation: UIInterfaceOrientation.portrait
              ) { ad, error in
                self.isLoadingAd = false
                if let error = error {
                  self.appOpenAd = nil
                  self.loadTime = nil
                  print("App open ad failed to load with error: \(error.localizedDescription).")
                    self.appWillOpenAds(isSuccess: false)
                  return
                }

                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
                print("App open ad loaded successfully.")
                  self.appWillOpenAds(isSuccess: true)
              }
          }
      }else {
          self.appOpenAd = ad
          self.appOpenAd?.fullScreenContentDelegate = self
          self.loadTime = Date()
          print("App open ad loaded successfully.")
          self.appWillOpenAds(isSuccess: true)
      }
    }
  }

  func showAdIfAvailable(viewController: UIViewController) {
    // If the app open ad is already showing, do not show the ad again.
    if isShowingAd {
      print("App open ad is already showing.")
      return
    }
    // If the app open ad is not available yet but it is supposed to show,
    // it is considered to be complete in this example. Call the appOpenAdManagerAdDidComplete
    // method and load a new ad.
    if !isAdAvailable() {
      print("App open ad is not ready yet.")
      appOpenAdManagerAdDidComplete()
      loadAd(loadTestMode: self.isLoadTestMode)
      return
    }
    if let ad = appOpenAd {
      print("App open ad will be displayed.")
      isShowingAd = true
        
      ad.present(fromRootViewController: viewController)
        overlayView = UIView(frame: viewController.view.bounds)
        overlayView?.backgroundColor = UIColor.gray
        viewController.view.addSubview(overlayView!)
    }
  }
}

extension AppOpenAdManager: GADFullScreenContentDelegate {
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("App open ad is will be presented.")
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad was dismissed.")
    appOpenAdManagerAdDidComplete()
      //loadAd(loadTestMode: self.isLoadTestMode)
  }
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        overlayView?.removeFromSuperview()
    }
  func ad(
    _ ad: GADFullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad failed to present with error: \(error.localizedDescription).")
      overlayView?.removeFromSuperview()
    appOpenAdManagerAdDidComplete()
    //loadAd(loadTestMode: self.isLoadTestMode)
  }
}
