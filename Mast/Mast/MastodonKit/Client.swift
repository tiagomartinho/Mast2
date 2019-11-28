//
//  Client.swift
//  MastodonKit
//
//  Created by Ornithologist Coder on 4/22/17.
//  Copyright © 2017 MastodonKit. All rights reserved.
//

import Foundation

public class Client: NSObject, ClientType, URLSessionTaskDelegate {
    let baseURL: String
//    let session: URLSession
    //    enum Constant: String {
    //        case sessionID = "com.shi.Mast.bgSession"
    //    }
        var session: URLSession = {
            return URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: .main)
        }()
    public var accessToken: String?
    
//    private var observation: NSKeyValueObservation?
//    deinit {
//        observation?.invalidate()
//    }
    
    required public init(baseURL: String, accessToken: String? = nil, session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)) {
        self.baseURL = baseURL
        self.session = session
        self.accessToken = accessToken
    }
    
    public func run<Model>(_ request: Request<Model>, completion: @escaping (Result1<Model>) -> Void) {
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        DispatchQueue.global(qos: .userInitiated).async {
            guard
                let components = URLComponents(baseURL: self.baseURL, request: request),
                let url = components.url
                else {
                    completion(.failure(ClientError.malformedURL))
                    return
            }
            
            let urlRequest = URLRequest(url: url, request: request, accessToken: self.accessToken)
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ClientError.malformedJSON))
                    return
                }
                
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200
                    else {
                        let mastodonError = try? MastodonError.decode(data: data)
                        let error: ClientError = mastodonError.map { .mastodonError($0.description) } ?? .genericError
                        completion(.failure(error))
                        return
                }
                
                guard let model = try? Model.decode(data: data) else {
                    completion(.failure(ClientError.invalidModel))
                    return
                }
                
                completion(.success(model, httpResponse.pagination))
            }
            
//            if GlobalStruct.isImageUploading {
//                self.observation = task.progress.observe(\.fractionCompleted) { progress, _ in
//                    if GlobalStruct.isImageUploading {
//                        GlobalStruct.imagePercentage = progress.fractionCompleted
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: "imagePercentage"), object: self)
//                    } else {
//                        self.observation?.invalidate()
//                    }
//                }
//            } else {
//                self.observation?.invalidate()
//            }
            
            task.resume()
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        if GlobalStruct.isImageUploading {
            GlobalStruct.imagePercentage = uploadProgress
            NotificationCenter.default.post(name: Notification.Name(rawValue: "imagePercentage"), object: self)
        }
    }
}
