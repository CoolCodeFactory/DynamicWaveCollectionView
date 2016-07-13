//
//  CollectionViewCell.swift
//  DynamicWaveCollectionView
//
//  Created by Dmitry Utmanov on 09/07/16.
//  Copyright © 2016 Dmitry Utmanov. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 10.0
        containerView.layer.masksToBounds = true
    }
}
