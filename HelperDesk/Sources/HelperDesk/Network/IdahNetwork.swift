//
//  MoyaNetwork+Extension.swift
//  PMM-iOS
//
//  Created by keyu on 2023/6/15.
//

import Foundation
import Moya
import Combine

struct IdahNetwork {
    static let provider: MoyaProvider<MultiTarget> = {
        var plugins: [PluginType] = [RequestHeaderConfigurationPlugin.shared]
//#if DEBUG
        plugins.append(SimpleNetworkLoggerPlugin())
//#endif
        plugins.append(RequestErrorHandlingPlugin())
        let provider = MoyaProvider<MultiTarget>(plugins: plugins)
        return provider
    }()
    
    // 用来防止mockprovider释放
    private static var _mockProvider: MoyaProvider<MultiTarget>!
    
    static func mockProvider(_ reponseType: MockResponseType) -> MoyaProvider<MultiTarget> {
        let plugins = [NetworkLoggerPlugin(configuration: .init(logOptions: .successResponseBody))]
        let endpointClosure: (MultiTarget) -> Endpoint
        switch reponseType {
            case .success(let data):
                endpointClosure = { (target: MultiTarget) -> Endpoint in
                    return Endpoint(url: URL(target: target).absoluteString, sampleResponseClosure: { .networkResponse(200, data ?? target.sampleData) }, method: target.method, task: target.task, httpHeaderFields: target.headers)
                }
            case .failure(let error):
                endpointClosure = { (target: MultiTarget) -> Endpoint in
                    return Endpoint(url: URL(target: target).absoluteString, sampleResponseClosure: { .networkError(error ?? NSError(domain: "mock error", code: -1)) }, method: target.method, task: target.task, httpHeaderFields: target.headers)
                }
        }
        let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.delayedStub(2), plugins: plugins)
        _mockProvider = provider
        return provider
    }
    
    enum MockResponseType {
        case success(Data?)
        case failure(NSError?)
    }
    
    enum ProviderType {
        case normal
        case mockSuccess(Data?)
        case mockFailure(NSError?)
    }
    
    @discardableResult
    static func decodableRequest<T: DecodableTargetType>(providerType: ProviderType = .normal, _ target: T, callbackQueue: DispatchQueue? = nil, completion: @escaping (_ result: Result<T.ResultType, Error>) -> ()) -> Moya.Cancellable {
        let provider: MoyaProvider<MultiTarget>
        switch providerType {
            case .normal:
                provider = self.provider
            case .mockSuccess(let data):
                provider = self.mockProvider(.success(data))
            case .mockFailure(let error):
                provider = self.mockProvider(.failure(error))
        }
        return provider.decodableRequest(target, callbackQueue: callbackQueue, completion: completion)
    }
    
//    static func decodableRequest<T: DecodableTargetType>(providerType: ProviderType = .normal, _ target: T, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<T.ResultType, Error> {
//        let provider: MoyaProvider<MultiTarget>
//        switch providerType {
//            case .normal:
//                provider = self.provider
//            case .mockSuccess(let data):
//                provider = self.mockProvider(.success(data))
//            case .mockFailure(let error):
//                provider = self.mockProvider(.failure(error))
//        }
//        return provider.decodableRequest(target, callbackQueue: callbackQueue)
//    }
    
    @discardableResult
    static func request<T: TargetType>(providerType: ProviderType = .normal, _ target: T, callbackQueue: DispatchQueue? = nil, completion: @escaping (_ result: Result<Data, Error>) -> ()) -> Moya.Cancellable {
        let provider: MoyaProvider<MultiTarget>
        switch providerType {
            case .normal:
                provider = self.provider
            case .mockSuccess(let data):
                provider = self.mockProvider(.success(data))
            case .mockFailure(let error):
                provider = self.mockProvider(.failure(error))
        }
        return provider.request(MultiTarget(target), callbackQueue: callbackQueue) { result in
            switch result {
                case .success(let rsp):
                    completion(.success(rsp.data))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
