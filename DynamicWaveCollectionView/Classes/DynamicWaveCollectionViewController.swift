//
//  DynamicWaveCollectionViewController.swift
//  DynamicWaveCollectionView
//
//  Created by Dmitry Utmanov on 10/07/16.
//  Copyright © 2016 Dmitry Utmanov. All rights reserved.
//

import UIKit

public class DynamicWaveCollectionViewController: UICollectionViewController {

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
}

extension DynamicWaveCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        if timers.count > 0 {
            for timer in timers {
                timer.invalidate()
            }
            timers.removeAll()
            
            let collectionViewLayout = self.collectionView!.collectionViewLayout as! DynamicWaveCollectionViewFlowLayout
            collectionViewLayout.downscaleIndexPaths = Set<NSIndexPath>()
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
        
//        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        let collectionViewLayoutAttributes = self.collectionView!.layoutAttributesForItemAtIndexPath(indexPath)!
        let center = collectionViewLayoutAttributes.center
        
        var left = center.x
        var right = center.x
        var top = center.y
        var bottom = center.y
        
        var i = 0
        
        var founded = Set<NSIndexPath>()
        var indexPaths = [Set<NSIndexPath>]()
        indexPaths.append([indexPath])
        
        while left > 0 || right < self.collectionView!.frame.size.width || top > self.collectionView!.contentOffset.y || bottom < self.collectionView!.frame.size.height {
            left -= 5
            right += 5
            top -= 5
            bottom += 5
            
            var foundedBool = false
            
            let rect = CGRect(origin: CGPoint(x: left < 0 ? 0 : left, y: top < 0 ? 0 : top), size: CGSize(width: right - (left < 0 ? 0 : left), height: bottom - (top < 0 ? 0 : top)))
            if let attrs = collectionView.collectionViewLayout.layoutAttributesForElementsInRect(rect) {
                for attr in attrs {
                    if founded.contains(attr.indexPath) {
                        // already contain
                    } else {
                        foundedBool = true
                        founded.insert(attr.indexPath)
                        indexPaths[i].insert(attr.indexPath)
                    }
                }
            }
            
            if foundedBool {
                indexPaths.append(Set<NSIndexPath>())
                i += 1
            }
        }
        
        for (i, value) in indexPaths.enumerate() {
            let delay = Double(i) / 10
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
            collectionViewLayout.downscaleIndexPaths.unionInPlace(indexPaths[i+1])
        }
        
        self.collectionView!.performBatchUpdates({
            self.collectionView!.collectionViewLayout.invalidateLayout()
        }, completion: { (finished) in
            // ...
        })
    }
}
