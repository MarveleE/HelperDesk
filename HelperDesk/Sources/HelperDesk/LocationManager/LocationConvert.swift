//
//  LocationConvert.swift
//  PMM-iOS
//
//  Created by 陈凝 on 2023/7/6.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    /// 地球坐标 WGC-84 转为为火星坐标 GCJ-02（限中国境内）
    /// - CLLocationManager 获取的是地球坐标，但地图上显示的需要火星坐标
    /// - 通过 CLLocationManager 获取到中国境内地理坐标，若需要在地图上显示，则需要转换为火星坐标
    var wgc84ToGCJ02: CLLocationCoordinate2D {
        if isLocatedInChina {
            let a = 6378245.0
            let ee = 0.00669342162296594323

            var adjustedLatitude = transformedLatitude
            var adjustedLongitude = transformedLongitude

            let radLat = latitude / 180.0 * .pi
            let magic: Double = {
                let temp = sin(radLat)
                let result = 1 - ee * temp * temp
                return result
            }()
            let sqrtMagic = sqrt(magic)

            adjustedLatitude = (adjustedLatitude * 180.0) / ((a * (1.0 - ee)) / (magic * sqrtMagic) * .pi)
            adjustedLongitude = (adjustedLongitude * 180.0) / (a / sqrtMagic * cos(radLat) * .pi)

            let result = CLLocationCoordinate2D(latitude: latitude + adjustedLatitude,
                                                longitude: longitude + adjustedLongitude)
            print("before: \(self)")
            print("after: \(result)")
            return result
        }
        return self
    }

    /// 坐标是否落在中国境内
    private var isLocatedInChina: Bool {
        // 范围：
        // 经度 longitude：73.66~135.05
        // 纬度 latitude: 3.86~53.55
        return (73.66 ... 135.05 ~= longitude) && (3.86 ... 53.55 ~= latitude)
    }

    private var transformedLatitude: Double {
        let x = longitude - 105.0
        let y = latitude - 35.0
        var result = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        result += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        result += (20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0
        result += (160.0 * sin(y / 12.0 * .pi) + 320.0 * sin(y * .pi / 30.0)) * 2.0 / 3.0
        return result
    }

    private var transformedLongitude: Double {
        let x = longitude - 105.0
        let y = latitude - 35.0
        var result = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        result += (20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0
        result += (20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0
        result += (150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0
        return result
    }
}
