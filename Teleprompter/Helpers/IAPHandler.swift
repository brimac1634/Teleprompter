//
//  IAPHandler.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 29/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit
import StoreKit

class IAPHelper: NSObject {
    
    typealias ProductsRequestCompletionHandler = (_ products: [SKProduct]?) -> ()
    
    private let productIdentifiers: Set<String>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    init(prodIds: Set<String>) {
        productIdentifiers = prodIds
        super.init()
    }

    
}

extension IAPHelper {
    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsRequestCompletionHandler?(response.products)
        productsRequestCompletionHandler = .none
        productsRequest = .none
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(.none)
        productsRequestCompletionHandler = .none
        productsRequest = .none
    }
    
}
