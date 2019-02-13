//
//  IAPHandler.swift
//  Teleprompter
//
//  Created by Brian MacPherson on 29/1/2019.
//  Copyright © 2019 Brian MacPherson. All rights reserved.
//

import UIKit
import StoreKit

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}


class IAPHandler: NSObject {
    static let shared = IAPHandler()
    
    let CONSUMABLE_PURCHASE_PRODUCT_ID = ""
    let NON_CONSUMABLE_PURCHASE_PRODUCT_ID = "Remote"
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(index: String){
        if iapProducts.count == 0 { return }
        
        if self.canMakePurchases() {
            let product = iapProducts[0]
            var continue_action = false
            
            for products in iapProducts {
                if (products.productIdentifier == index) {
                    product = products
                    continue_action = true
                    break
                }
            }
            
            if (continue_action != false) {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                
                print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
                productID = product.productIdentifier
            }
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: CONSUMABLE_PURCHASE_PRODUCT_ID,NON_CONSUMABLE_PURCHASE_PRODUCT_ID
        )
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                print(product.localizedDescription + "\nfor just \(price1Str!)")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    break
                    
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
}




//class IAPHelper: NSObject {
//
//    typealias ProductsRequestCompletionHandler = (_ products: [SKProduct]?) -> ()
//
//    private let productIdentifiers: Set<String>
//    private var productsRequest: SKProductsRequest?
//    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
//
//    init(prodIds: Set<String>) {
//        productIdentifiers = prodIds
//        super.init()
//    }
//
//
//}
//
//extension IAPHelper {
//    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
//        productsRequest?.cancel()
//        productsRequestCompletionHandler = completionHandler
//
//        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
//        productsRequest?.delegate = self
//        productsRequest?.start()
//    }
//}
//
//extension IAPHelper: SKProductsRequestDelegate {
//
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        productsRequestCompletionHandler?(response.products)
//        productsRequestCompletionHandler = .none
//        productsRequest = .none
//    }
//
//    func request(_ request: SKRequest, didFailWithError error: Error) {
//        print("Error: \(error.localizedDescription)")
//        productsRequestCompletionHandler?(.none)
//        productsRequestCompletionHandler = .none
//        productsRequest = .none
//    }
//
//}
