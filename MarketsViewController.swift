//
//  MarketsViewController.swift
//  Market
//
//  Created by Igor Trukhin on 21/01/2019.
//  Copyright (c) 2019 Igor Trukhin. All rights reserved.
//

import UIKit
import IGListKit

protocol MarketsViewControllerProtocol: class {
    
    func displayMarkets(viewModel: Markets.FetchMarkets.ViewModel)
    
}

final class MarketsViewController: UIViewController {
    
    let interactor: MarketsInteractorProtocol
    let router: MarketsRouterProtocol
    
    private var state: Markets.ViewControllerState
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let collectionView = ListCollectionView(frame: .zero)
    
    private lazy var items = [Presentable]()
    
    init(interactor: MarketsInteractorProtocol,
         router: MarketsRouterProtocol,
         initialState: Markets.ViewControllerState = .loading) {
        self.interactor = interactor
        self.router = router
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        adapter.collectionView = collectionView
        adapter.dataSource = self
        configureNavbar()
        display(newState: state)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureNavbar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = nil
    }
    
}

// MARK: - ListAdapterDataSource

extension MarketsViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return items
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is SectorPerformanceViewModel:
            return SectorsPerformanceSectionControllers()
        case is MarketMostActiveViewModel:
            let sc = MarketMostActiveSectionController()
            sc.didTapSymbol = { [weak self] symbol in
                self?.router.routeTo(symbol)
            }
            return sc
        case is MarketGainersViewModell:
            return MarketGainersSectionController()
        case is MarketLosersViewModel:
            return MarketLosersSectionController()
        case is MarketInfocusViewModel:
            return MarketInfocusSectionController()
        default:
            #warning("TODO")
            return CompanyNewsSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
}

// MARK: - MarketsViewControllerProtocol

extension MarketsViewController: MarketsViewControllerProtocol {
    
    func displayMarkets(viewModel: Markets.FetchMarkets.ViewModel) {
        display(newState: viewModel.state)
    }
    
}

// MARK: - State updating

private extension MarketsViewController {
    
    func display(newState: Markets.ViewControllerState) {
        state = newState
        
        switch state {
        case .loading:
            applyLoadingState()
        case .result(let viewModels):
            applyResultState(result: viewModels)
        case .empty(let emptyMessage):
            applyEmptyState(message: emptyMessage)
        case .error(let errorMessage):
            applyErrorState(message: errorMessage)
        }
    }
    
    func applyLoadingState() {
        let request = Markets.FetchMarkets.Request()
        interactor.fetchMarkets(request: request)
    }
    
    func applyResultState(result: [Presentable]) {
        self.items = result
        self.adapter.reloadData { _ in }
    }
    
    func applyEmptyState(message: String) {
        #warning("TODO")
    }
    
    func applyErrorState(message: String) {
        #warning("TODO")
    }
    
}
