//
//  RequestPlugin.swift
//  PMM-iOS
//
//  Created by keyu on 2023/9/23.
//

import Foundation
import Moya
import Alamofire

struct RequestErrorWrapper {
    let moyaError: MoyaError

    var afError: AFError? {
        if case .underlying(let error as AFError, _) = moyaError {
            return error
        }
        return nil
    }

    var nsError: NSError? {
        if case .underlying(let error as NSError, _) = moyaError {
            return error
        } else if let afError {
            return afError.underlyingError as? NSError
        }
        return nil
    }

    var isRequestCancelled: Bool {
        if case .explicitlyCancelled = afError {
            return true
        }
        return false
    }

    var defaultErrorMessage: String? {
        if nsError?.code == NSURLErrorTimedOut {
            return "加载数据失败，请稍后重试"
        } else if nsError?.code == NSURLErrorNotConnectedToInternet {
            return "无网络连接，请检查网络"
        } else {
            return "加载数据失败，请稍后重试"
        }
    }
}

protocol RequestErrorHandlable {
    var errorHandlingType: RequestErrorHandlingPlugin.RequestErrorHandlingType { get }
}

extension RequestErrorHandlable {
    var errorHandlingType: RequestErrorHandlingPlugin.RequestErrorHandlingType {
        .all
    }
}

public final class RequestErrorHandlingPlugin {
    enum RequestErrorHandlingType {
        enum FilterResult {
            case handledByPlugin(message: String?)
            case shouldNotHandledByPlugin
        }

        case connectionError // 现在包括超时和断网错误
        case all
        case allWithFilter(filter: (RequestErrorWrapper) -> FilterResult)

        func handleError(_ error: RequestErrorWrapper, handler: (_ shouldHandle: Bool, _ message: String?) -> Void) {
            switch self {
            case .connectionError:
                if error.nsError?.code == NSURLErrorTimedOut {
                    handler(true, error.defaultErrorMessage)
                } else if error.nsError?.code == NSURLErrorNotConnectedToInternet {
                    handler(true, error.defaultErrorMessage)
                }
            case .all:
                handler(true, error.defaultErrorMessage)
            case .allWithFilter(let filter):
                switch filter(error) {
                case .handledByPlugin(let messsage):
                    handler(true, messsage ?? error.defaultErrorMessage)
                case .shouldNotHandledByPlugin:
                    handler(false, nil)
                }
            }
            handler(false, nil)
        }
    }
}

extension RequestErrorHandlingPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.timeoutInterval = 30
        return request
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        let requestErrorHandleSubject: RequestErrorHandlable?
        if let multiTarget = target as? MultiTarget {
            requestErrorHandleSubject = multiTarget.target as? RequestErrorHandlable
        } else {
            requestErrorHandleSubject = target as? RequestErrorHandlable
        }

        guard let requestErrorHandleSubject, case .failure(let moyaError) = result else { return }

        let errorWrapper = RequestErrorWrapper(moyaError: moyaError)
        if errorWrapper.isRequestCancelled {
            return
        }

        requestErrorHandleSubject.errorHandlingType.handleError(errorWrapper) { shouldHandle, message in
            if shouldHandle, let message, !message.isEmpty {
                IdahProgressHUD.toastHUDOnWindow(message)
            }
        }
    }
}
