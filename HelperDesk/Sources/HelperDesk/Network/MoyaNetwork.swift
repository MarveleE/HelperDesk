//
//  Moya+extension.swift
//  PMM-iOS
//
//  Created by keyu on 2023/6/15.
//

import Foundation
import Moya
import Combine

public protocol DecodableTargetType: TargetType {
    associatedtype ResultType: Decodable

    var decodeAtKeyPath: String? { get }
}

extension DecodableTargetType {
    public var decodeAtKeyPath: String? { nil }

    public var validationType: ValidationType {
        .successCodes
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension MoyaProvider where Target == MultiTarget {
    public func decodableRequest<T: DecodableTargetType>(_ target: T, callbackQueue: DispatchQueue? = nil, completion: @escaping (_ result: Result<T.ResultType, Error>) -> ()) -> Moya.Cancellable {
        return request(MultiTarget(target), callbackQueue: callbackQueue) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let responseObject = try response.map(T.ResultType.self, atKeyPath: target.decodeAtKeyPath)
                    completion(.success(responseObject))

                } catch let error {
                    completion(.failure(error))
                    self?.logDecodeError(error)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

//    public func decodableRequest<T: DecodableTargetType>(_ target: T, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<T.ResultType, Error> {
//        return requestPublisher(MultiTarget(target), callbackQueue: callbackQueue)
//            .tryMap { response in
//                try response.map(T.ResultType.self, atKeyPath: target.decodeAtKeyPath)
//            }
//            .handleEvents(receiveCompletion: { [weak self] completion in
//                if case .failure(let error) = completion {
//                    self?.logDecodeError(error)
//                }
//            })
//            .eraseToAnyPublisher()
//    }

    private func logDecodeError(_ error: Error) {
        print("===================================================================")
        print("🔴 Decode Error: \(error)")
        print("===================================================================")
    }
}
