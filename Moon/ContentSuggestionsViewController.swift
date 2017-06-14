//
//  ContentSuggestionsViewController.swift
//  Moon
//
//  Created by Evan Noble on 6/9/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

typealias SearchSection = AnimatableSectionModel<String, SearchSnapshot>

class ContentSuggestionsViewController: UIViewController, BindableType, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var suggestedUsersLabel: UILabel!
    @IBOutlet weak var suggestedBarsLabel: UILabel!
    
    var viewModel: ContentSuggestionsViewModel!
    
    private let barCollectionCellResuseIdenifier = "BarSnapshotCell"
    private let userCollectionCellReuseIdenifier = "UserSearchCollectionViewCell"
    let barDataSource = RxCollectionViewSectionedAnimatedDataSource<SearchSection>()
    let userDataSource = RxCollectionViewSectionedAnimatedDataSource<SearchSection>()
    private let bag = DisposeBag()
    
    @IBOutlet var suggestedUserColletionView: UICollectionView!
    @IBOutlet var suggestedBarCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestedBarCollectionView.delegate = self
        
        configureDataSource()
        prepareLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBarController?.searchBar.textField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBarController?.searchBar.textField.resignFirstResponder()
    }
    
    func prepareLabels() {
        suggestedUsersLabel.textColor = .lightGray
        suggestedUsersLabel.dividerThickness = 1.8
        suggestedUsersLabel.dividerColor = .moonGrey
        
        suggestedBarsLabel.textColor = .lightGray
        suggestedBarsLabel.dividerThickness = 1.8
        suggestedBarsLabel.dividerColor = .moonGrey
    }
    
    func bindViewModel() {
        viewModel.suggestedBars.drive(suggestedBarCollectionView.rx.items(dataSource: barDataSource)).disposed(by: bag)
        viewModel.suggestedFriends.drive(suggestedUserColletionView.rx.items(dataSource: userDataSource)).disposed(by: bag)
    }
    
    fileprivate func cellsPerRowVertical(cells: Int, collectionView: UICollectionView) -> UICollectionViewFlowLayout {
            let numberOfCellsPerRow: CGFloat = CGFloat(cells)
        
            let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            
            let horizontalSpacing = flowLayout?.scrollDirection == .vertical ? flowLayout?.minimumInteritemSpacing: flowLayout?.minimumLineSpacing
            
            let cellWidth = ((self.view.frame.width) - max(0, numberOfCellsPerRow - 1) * horizontalSpacing!)/numberOfCellsPerRow
            
            flowLayout?.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        return flowLayout!
    }
    
    fileprivate func cellsPerRowHorizontal(cells: Int, collectionView: UICollectionView) -> UICollectionViewFlowLayout {
            let numberOfCellsPerRow: CGFloat = CGFloat(cells)
        
            let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
            let cellWidth = ((self.view.frame.width / 2) - max(0, numberOfCellsPerRow - 1) * 0.1)/numberOfCellsPerRow
            flowLayout?.itemSize = CGSize(width: cellWidth, height: collectionView.frame.size.height)
        
            flowLayout?.minimumInteritemSpacing = 0
            flowLayout?.minimumLineSpacing = 0
            flowLayout?.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        return flowLayout!
    }
    
    fileprivate func configureDataSource() {
        barDataSource.configureCell = {
            [weak self] dataSource, collectionView, indexPath, item in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BarSnapshotCell", for: indexPath)
            
            collectionView.collectionViewLayout = (self?.cellsPerRowVertical(cells: 2, collectionView: collectionView))!
            
            let cellSize = (collectionView.frame.size.height * 0.526)
            cell.frame.size.height = cellSize
            cell.frame.size.width = cellSize
            
            let width = cellSize - 20
            let height = width - 10
            
            let view = BarCollectionView()
            view.frame = CGRect(x: (cellSize / 2) - (width / 2), y: (cellSize / 2) - (height / 2), width: width, height: height)
            view.backgroundColor = .clear
            
            if let strongSelf = self {
               view.initViewWith(bar: item)
            }

            cell.addSubview(view)
            return cell
        }
        
        userDataSource.configureCell = {
            [weak self] dataSource, collectionView, indexPath, item in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserSearchCollectionViewCell", for: indexPath)
            
            collectionView.collectionViewLayout = (self?.cellsPerRowHorizontal(cells: 1, collectionView: collectionView))!
            
            let cellSize = collectionView.frame.size.height * 0.96
            cell.frame.size.height = cellSize
            cell.frame.size.width = cellSize
            
            let height = cell.frame.height - 20
            let width = cell.frame.size.width
            
            let view = UserCollectionView()
            view.frame = CGRect(x: 0, y: 0, width: width, height: height)
            view.backgroundColor = .clear
            
            if let strongSelf = self {
                view.initViewWith(user: item)
            }
            
            cell.addSubview(view)
            return cell
        }
    }
}

extension Reactive where Base : UITableView {}
