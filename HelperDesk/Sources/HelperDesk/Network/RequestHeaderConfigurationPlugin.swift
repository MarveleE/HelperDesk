//
//  HeaderConfigurationPlugin.swift
//  PMM-iOS
//
//  Created by keyu on 2023/7/15.
//

import Foundation
import Moya

public final class RequestHeaderConfigurationPlugin: PluginType {

    static let shared: RequestHeaderConfigurationPlugin = RequestHeaderConfigurationPlugin()

    var header: [String: String] = [:]

    // MARK: Plugin

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.allHTTPHeaderFields?.merge(header) { (_, new) in new }
        return request
    }

    func setAuthorization(_ token: String) {
        header["Authorization"] = token
    }
}
