//
//  ViewController.swift
//  DynamicWaveCollectionView
//
//  Created by Dmitry Utmanov on 08/07/16.
//  Copyright © 2016 Dmitry Utmanov. All rights reserved.
//

import UIKit
import DynamicWaveCollectionView


let numberOfColumn: Int = 1
let edgeOffset: CGFloat = 10
let minimumInteritemSpacing: CGFloat = 5
let minimumLineSpacing: CGFloat = 5
let colors = [UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1), UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1)]


class ViewController: DynamicWaveCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let collectionViewFlowLayout = collectionView!.collectionViewLayout as! DynamicWaveCollectionViewFlowLayout
        collectionViewFlowLayout.scrollDirection = .Vertical
        // collectionViewFlowLayout.length = 0.0
        // collectionViewFlowLayout.damping = 0.8
        // collectionViewFlowLayout.frequency = 1.0
        // collectionViewFlowLayout.resistance = 1000
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        coordinator.animateAlongsideTransition({ [weak weakSelf = self](viewControllerTransitionCoordinatorContext) in
//            guard let _self = weakSelf else { return }
//            let contentOffset = _self.collectionView!.contentOffset
//            let collectionViewFlowLayout = _self.collectionView!.collectionViewLayout as! DynamicWaveCollectionViewFlowLayout
//            collectionViewFlowLayout.invalidateLayout()
//            _self.collectionView!.setContentOffset(contentOffset, animated: true)
//        }, completion: { [weak weakSelf = self] (viewControllerTransitionCoordinatorContext) in
//            guard let _self = weakSelf else { return }
//            let contentOffset = _self.collectionView!.contentOffset
//            let collectionViewFlowLayout = _self.collectionView!.collectionViewLayout as! DynamicWaveCollectionViewFlowLayout
//            collectionViewFlowLayout.invalidateLayout()
//            _self.collectionView!.setContentOffset(contentOffset, animated: true)
//        })
//    }
}

extension ViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // You must call super to animate selection
        super.collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.width - (edgeOffset * 2) - (minimumInteritemSpacing * CGFloat(numberOfColumn) - 1)
        let cellWidth = floor(width / CGFloat(numberOfColumn))
        return CGSize(width: cellWidth, height: floor(44))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: edgeOffset, left: edgeOffset, bottom: edgeOffset, right: edgeOffset)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width - (edgeOffset * 2)
        return CGSize(width: width, height: 100)
    }
}

extension ViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 400
        case 1:
            return 500
        case 2:
            return 600
        default:
            fatalError("Unexpected state")
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        let colorIndex = indexPath.row % colors.count
        cell.containerView.backgroundColor = colors[colorIndex]
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! HeaderCollectionReusableView
            return headerView
            
        case UICollectionElementKindSectionFooter:
            fatalError("Footer not supproted")
            
        default:
            fatalError("Unknown kind type")
        }
    }
}