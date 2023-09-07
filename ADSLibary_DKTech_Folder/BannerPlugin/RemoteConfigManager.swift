//
//  RemoteConfigManager.swift
//  bannerplugin
//
//  Created by Hung Pham on 7/6/23.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager {
    
    static let shared = RemoteConfigManager()
    
    private init() {}
    
    func fetchAndActivate() {
        RemoteConfig.remoteConfig().fetchAndActivate()
    }
    
    func getBannerConfig(key: String?) -> BannerConfig? {
        do {
            let data = RemoteConfig.remoteConfig().configValue(forKey: key).dataValue
            return try JSONDecoder().decode(BannerConfig.self, from: data)
        } catch {
            return nil
        }
    }
    
    struct BannerConfig: Decodable {
        static let TYPE_STANDARD = "standard"
        static let TYPE_ADAPTIVE = "adaptive"
        static let TYPE_COLLAPSIBLE_TOP = "collapsible_top"
        static let TYPE_COLLAPSIBLE_BOTTOM = "collapsible_bottom"
        
        enum CodingKeys: String, CodingKey {
            case adUnitId = "ad_unit_id"
            case type = "type"
            case refreshRateSec = "refresh_rate_sec"
            case cbFetchIntervalSec = "cb_fetch_interval_sec"
        }
        
        let adUnitId: String?
        let type: String?
        let refreshRateSec: Int?
        let cbFetchIntervalSec: Int?
    }
}
