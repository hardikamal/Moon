//
//  ImageCardCollectionViewCell.swift
//  MainMoonViewSamples
//
//  Created by Evan Noble on 5/1/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import UIKit
import Material

struct TopBarData {
    let imageName: String
    let barName: String
    let location: String
}

class ImageCardCollectionViewCell: UICollectionViewCell {
    fileprivate var card: ImageCard!
    
    /// Content area.
    fileprivate var imageView: UIImageView!
    
    /// Toolbar views.
    fileprivate var toolbar: Toolbar!
    fileprivate var moreButton: IconButton!
    
    func initializeCollectionViewWith(data: TopBarData) {
        
        prepareImageViewWith(imageName: data.imageName)
        prepareMoreButton()
        prepareToolbarWith(title: data.barName, subtitle: data.location)
        preparePresenterCard()
    }

}

extension ImageCardCollectionViewCell {
    fileprivate func prepareImageViewWith(imageName: String) {
        imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = UIImage(named: imageName)?.resize(toWidth: self.width)
    
    }
    
    fileprivate func prepareMoreButton() {
        moreButton = IconButton(image: Icon.cm.moreHorizontal, tintColor: Color.blueGrey.base)
    }
    
    fileprivate func prepareToolbarWith(title: String, subtitle: String) {
        toolbar = Toolbar(rightViews: [moreButton])
        toolbar.backgroundColor = nil
        
        toolbar.title = title
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.textAlignment = .center
        
        toolbar.detail = subtitle
        toolbar.detailLabel.textColor = .white
        toolbar.detailLabel.textAlignment = .center
    }
    
    fileprivate func preparePresenterCard() {
        card = ImageCard()
        
        card.toolbar = toolbar
        card.toolbarEdgeInsetsPreset = .square2
        
        card.imageView = imageView
        
        self.layout(card).horizontally(left: 0, right: 0).center()
    }
}
