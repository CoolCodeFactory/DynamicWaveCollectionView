//
//  DynamicWaveCollectionViewController.swift
//  DynamicWaveCollectionView
//
//  Created by Dmitry Utmanov on 10/07/16.
//  Copyright © 2016 Dmitry Utmanov. All rights reserved.
//

import UIKit

public class DynamicWaveCollectionViewController: UICollectionViewController {
    
    public var waveDuration: Double = 0.06
    public var minCellEdgeLength: CGFloat = 30.0
    public var gradientTopAlpha: CGFloat = 0.4 {
        didSet {
            gradientLayer.colors = [UIColor.whiteColor().colorWithAlphaComponent(gradientTopAlpha).CGColor, UIColor.clearColor().CGColor]
        }
    }
    
    var timers = [NSTimer]()
    var gradientLayer: CAGradientLayer!
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewFlowLayout = DynamicWaveCollectionViewFlowLayout()
        collectionView!.setCollectionViewLayout(collectionViewFlowLayout, animated: false)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: collectionView!.frame.size)
        gradientLayer.colors = [UIColor.whiteColor().colorWithAlphaComponent(gradientTopAlpha).CGColor, UIColor.clearColor().CGColor]
        collectionView!.superview!.layer.addSublayer(gradientLayer)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Autolayout doesn't work with layers // viewWillTransitionToSize??
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: collectionView!.frame.size)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Autolayout doesn't work with layers // viewWillTransitionToSize??
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: collectionView!.frame.size)
    }
}

extension DynamicWaveCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        if timers.count > 0 {
            for timer in timers {
                timer.invalidate()
            }
            timers.removeAll()
            
            let collectionViewLayout = self.collectionView!.collectionViewLayout as! DynamicWaveCollectionViewFlowLayout
            collectionViewLayout.downscaleIndexPaths = nil
            self.collectionView!.performBatchUpdates({
                self.collectionView!.collectionViewLayout.invalidateLayout()
            }, completion: { (finished) in
                // ...
            })
        }
    }
    
    public override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        for timer in timers {
            timer.invalidate()
        }
        timers.removeAll()
        
        let collectionViewLayoutAttributes = self.collectionView!.layoutAttributesForItemAtIndexPath(indexPath)!
        let center = collectionViewLayoutAttributes.center
        
        var left = center.x
        var right = center.x
        var top = center.y
        var bottom = center.y
        
        var foundedIndexPaths = Set<NSIndexPath>() // Used as filter
        var indexPaths = [Set<NSIndexPath>]() // NSIndexPaths sorted by zone
        
        // Add indexPath as initial NSIndexPath
        foundedIndexPaths.insert(indexPath)
        indexPaths.append([indexPath])

        // already insert indexPath
        var i = 1
        // Initialize Set
        indexPaths.append(Set<NSIndexPath>())

        // Used for optimization
        let edge = UIEdgeInsets(top: self.collectionView!.contentOffset.y, left: 0, bottom: self.collectionView!.contentOffset.y + self.collectionView!.frame.size.height, right: self.collectionView!.frame.size.width)
        
        // Iterate by zone
        while left > edge.left || right < edge.right || top > edge.top || bottom < edge.bottom {
            if left < edge.left {
                left = edge.left
            }
            if right > edge.right {
                right = edge.right
            }
            if top < edge.top {
                top = edge.top
            }
            if bottom > edge.bottom {
                bottom = edge.bottom
            }
            
            // If NSIndexPaths founded in zone, let's search for another zone
            var founded = false
            
            // Current zone
            let rect = CGRect(origin: CGPoint(x: left, y: top), size: CGSize(width: right - left, height: bottom - top))
            
            if let attrs = collectionView.collectionViewLayout.layoutAttributesForElementsInRect(rect) {
                for attr in attrs {
                    if !foundedIndexPaths.contains(attr.indexPath) {
                        founded = true
                        foundedIndexPaths.insert(attr.indexPath)
                        indexPaths[i].insert(attr.indexPath)
                    }
                }
            }
            
            // Move to next search zone
            if founded {
                indexPaths.append(Set<NSIndexPath>())
                i += 1
            }
            left -= minCellEdgeLength
            right += minCellEdgeLength
            top -= minCellEdgeLength
            bottom += minCellEdgeLength
        }
        
        // Start animation // Needs in some optimization
        for (i, value) in indexPaths.enumerate() {
            let delay = Double(i) * waveDuration
            let timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(wave(_:)), userInfo: ["value": value, "indexPaths": indexPaths, "i": i], repeats: false)
            timers.append(timer)
        }
    }
    
    func wave(timer: NSTimer) {
        let value = timer.userInfo!["value"] as! Set<NSIndexPath>
        let indexPaths = timer.userInfo!["indexPaths"] as! [Set<NSIndexPath>]
        let i = timer.userInfo!["i"] as! Int
        if let index = timers.indexOf(timer) {
            timer.invalidate()
            timers.removeAtIndex(index)
        }
        
        let collectionViewLayout = self.collectionView!.collectionViewLayout as! DynamicWaveCollectionViewFlowLayout
        collectionViewLayout.downscaleIndexPaths = value

        if i+1 < indexPaths.count {
            collectionViewLayout.downscaleIndexPaths!.unionInPlace(indexPaths[i+1])
        }

        self.collectionView!.performBatchUpdates({
            self.collectionView!.collectionViewLayout.invalidateLayout()
        }, completion: { (finished) in
            if value.isEmpty {
                collectionViewLayout.downscaleIndexPaths = nil
                self.collectionView!.collectionViewLayout.invalidateLayout()
            }
        })
    }
}
