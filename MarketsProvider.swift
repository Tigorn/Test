//
//  MarketsProvider.swift
//  Market
//
//  Created by Igor Trukhin on 21/01/2019.
//  Copyright (c) 2019 Igor Trukhin. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift

protocol MarketsProviderProtocol {
    
    func createMarketRequestsNew() -> Promise<[Promise<StockObject>]>
    
}

final class MarketsProvider {
    
    private let networkService: MarketsNetworkServiceProtocol
    private let parseService: ParseHandler
    private let persistenceService: MarketsPersistenceServiceProtocol
    
    init(networkService: MarketsNetworkServiceProtocol,
        persistenceService: MarketsPersistenceServiceProtocol) {
        self.networkService = networkService
        self.persistenceService = persistenceService
        
        self.parseService = ParseService()
    }
    
    enum MarketsProviderError: Error {
        case convertToStockObjectFailure
    }
    
}

extension MarketsProvider: MarketsProviderProtocol {
    
    func createMarketRequestsNew() -> Promise<[Promise<StockObject>]> {
        return Promise { seal in
            let requests = Markets.EndpointConfiguration.allCases.map(fetchCachedEndpointNew)
            seal.fulfill(requests)
        }
    }
    
    private func fetchCachedEndpointNew(_ endpoint: Markets.EndpointConfiguration) -> Promise<StockObject> {
        return firstly {
            persistenceService.fetchNew(endpoint.storableType, uid: endpoint.uid)
            }.then {
                self.persistenceService.checkIfExpiredNew($0, expireMinutes: endpoint.expiredTime)
            }.recover { error in
                self.recoverActions(recoverError: error, endpoint)
        }
    }
    
    private func recoverActions(recoverError: Error, _ endpoint: Markets.EndpointConfiguration) -> Promise<StockObject> {
        return self.networkService.fetchMarketEndpointNew(endpoint.getAPIRoute())
            .then {
                self.convertDataToModel($0, decodableType: endpoint.decodableType)
            }.then {
                self.convertModelToRealm($0, uid: endpoint.uid)
            }.then { stockObj in
                self.persistenceService.cacheNew(stockObj, endpoint: endpoint)
            }
    }
    
    private func convertDataToModel(_ data: Data, decodableType: Convertible.Type) -> Promise<Convertible> {
        return Promise { seal in
            let model = try decodableType.init(from: data)
            seal.fulfill(model)
        }
    }
    
    private func convertModelToRealm(_ model: Convertible, uid: UniqueIdentifier) -> Promise<StockObject> {
        return Promise { seal in
            guard let stockObject = model.toRealmObject(with: uid) as? StockObject else {
                return seal.reject(MarketsProviderError.convertToStockObjectFailure)
            }
            seal.fulfill(stockObject)
        }
    }
    
}
