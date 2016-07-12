//
//  DynamicWaveCollectionViewFlowLayout.swift
//  DynamicWaveCollectionView
//
//  Created by Dmitry Utmanov on 10/07/16.
//  Copyright © 2016 Dmitry Utmanov. All rights reserved.
//

import UIKit

public class DynamicWaveCollectionViewFlowLayout: UICollectionViewFlowLayout {

    public var length: CGFloat = 0.0
    public var damping: CGFloat = 0.8
    public var frequency: CGFloat = 1.0
    public var resistance: CGFloat = 1000.0

    var downscaleIndexPaths = Set<NSIndexPath>()
    
    var dynamicAnimator: UIDynamicAnimator!
    var visibleIndexPathsSet: Set<NSIndexPath>!
    var latestDelta: CGFloat = 0.0
    
    
    override public init() {
        super.init()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        visibleIndexPathsSet = Set<NSIndexPath>()
    }
    
    override public func prepareLayout() {
        super.prepareLayout()
        print("prepare layout")

        let visibleRect = CGRectInset(CGRect(origin: self.collectionView!.bounds.origin, size: self.collectionView!.frame.size), -100, -100)

        if let itemsInVisibleRectArray = super.layoutAttributesForElementsInRect(visibleRect) {
            let itemsIndexPathsInVisibleRectSet = Set<NSIndexPath>(itemsInVisibleRectArray.map({ $0.indexPath }))
            
            let noLongerVisibleBehaviours = self.dynamicAnimator.behaviors.filter({ (dynamicBehavior) -> Bool in
                if let attachmentBehavior = dynamicBehavior as? UIAttachmentBehavior {
                    let collectionViewLayoutAttributes = attachmentBehavior.items.last as! UICollectionViewLayoutAttributes
                    return !itemsIndexPathsInVisibleRectSet.contains(collectionViewLayoutAttributes.indexPath)
                }
                return false
            })
            
            for behavior in noLongerVisibleBehaviours {
                if let attachmentBehavior = behavior as? UIAttachmentBehavior {
                    self.dynamicAnimator.removeBehavior(behavior)
                    let collectionViewLayoutAttributes = attachmentBehavior.items.last as! UICollectionViewLayoutAttributes
                    self.visibleIndexPathsSet.remove(collectionViewLayoutAttributes.indexPath)
                }
            }
            
            let newlyVisibleItems = itemsInVisibleRectArray.filter({ (collectionViewLayoutAttributes) -> Bool in
                return !visibleIndexPathsSet.contains(collectionViewLayoutAttributes.indexPath)
            })
            
            let touchLocation = self.collectionView!.panGestureRecognizer.locationInView(self.collectionView)
            
            for item in newlyVisibleItems {

                let center = item.center
                var fixedCenter: CGPoint
                switch scrollDirection {
                case .Horizontal:
                    fixedCenter = CGPoint(x: center.x, y: round(center.y))

                case .Vertical:
                    fixedCenter = CGPoint(x: round(center.x), y: center.y)
                }

                let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor:fixedCenter)
                
                if #available(iOS 9.0, *) {
                    springBehaviour.frictionTorque = CGFloat.max
                }
                if #available(iOS 9.0, *) {
                    springBehaviour.attachmentRange = UIFloatRangeZero
                }
                springBehaviour.length = 0.0
                springBehaviour.damping = 0.8
                springBehaviour.frequency = 1.0
                
                if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
                    let distanceFromTouch: CGFloat
                    switch scrollDirection {
                    case .Horizontal:
                        distanceFromTouch = abs(touchLocation.x - springBehaviour.anchorPoint.x)
                        
                    case .Vertical:
                        distanceFromTouch = abs(touchLocation.y - springBehaviour.anchorPoint.y)
                    }
                    
                    
                    let scrollResistance = distanceFromTouch / resistance
                    
                    if (self.latestDelta < 0) {
                        switch scrollDirection {
                        case .Horizontal:
                            fixedCenter.x += max(self.latestDelta, self.latestDelta*scrollResistance)
                            
                        case .Vertical:
                            fixedCenter.y += max(self.latestDelta, self.latestDelta*scrollResistance)
                        }
                    }
                    else {
                        switch scrollDirection {
                        case .Horizontal:
                            fixedCenter.x += min(self.latestDelta, self.latestDelta*scrollResistance)
                            
                        case .Vertical:
                            fixedCenter.y += min(self.latestDelta, self.latestDelta*scrollResistance)
                        }
                    }
                    var _fixedCenter: CGPoint
                    switch scrollDirection {
                    case .Horizontal:
                        _fixedCenter = CGPoint(x: fixedCenter.x, y: round(fixedCenter.y))
                        
                    case .Vertical:
                        _fixedCenter = CGPoint(x: round(fixedCenter.x), y: fixedCenter.y)
                    }
                    item.center = _fixedCenter
                }
                
                self.dynamicAnimator.addBehavior(springBehaviour)
                self.visibleIndexPathsSet.insert(item.indexPath)
                print("newlyVisibleItems update")
            }
        }
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = dynamicAnimator.itemsInRect(rect) as! [UICollectionViewLayoutAttributes]
        let scaledLayoutAttributes: [UICollectionViewLayoutAttributes] = layoutAttributes.map({ (collectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes in
            if downscaleIndexPaths.contains(collectionViewLayoutAttributes.indexPath) {
                collectionViewLayoutAttributes.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4)
            } else {
                collectionViewLayoutAttributes.transform = CGAffineTransformIdentity
            }
            return collectionViewLayoutAttributes
        })
        return scaledLayoutAttributes
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForCellAtIndexPath(indexPath)
    }
    
    public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
    }
    
    public override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView!
        
        let delta: CGFloat
        switch scrollDirection {
        case .Horizontal:
            delta = newBounds.origin.x - scrollView.bounds.origin.x
            
        case .Vertical:
            delta = newBounds.origin.y - scrollView.bounds.origin.y
        }
        
        self.latestDelta = delta
        
        let touchLocation = self.collectionView!.panGestureRecognizer.locationInView(self.collectionView)
        
        for attachmentBehavior in dynamicAnimator.behaviors as! [UIAttachmentBehavior] {
            let distanceFromTouch: CGFloat
            switch scrollDirection {
            case .Horizontal:
                distanceFromTouch = abs(touchLocation.x - attachmentBehavior.anchorPoint.x)
                
            case .Vertical:
                distanceFromTouch = abs(touchLocation.y - attachmentBehavior.anchorPoint.y)
            }
            
            let scrollResistance = distanceFromTouch / resistance
            
            let item = attachmentBehavior.items.first as! UICollectionViewLayoutAttributes
            let center = item.center
            var fixedCenter: CGPoint
            switch scrollDirection {
            case .Horizontal:
                fixedCenter = CGPoint(x: center.x, y: round(center.y))
                
            case .Vertical:
                fixedCenter = CGPoint(x: round(center.x), y: center.y)
            }

            if (delta < 0) {
                switch scrollDirection {
                case .Horizontal:
                    fixedCenter.x += max(delta, delta*scrollResistance)
                    
                case .Vertical:
                    fixedCenter.y += max(delta, delta*scrollResistance)
                }
            } else {
                switch scrollDirection {
                case .Horizontal:
                    fixedCenter.x += min(delta, delta*scrollResistance)
                    
                case .Vertical:
                    fixedCenter.y += min(delta, delta*scrollResistance)
                }
            }
            var _fixedCenter: CGPoint
            switch scrollDirection {
            case .Horizontal:
                _fixedCenter = CGPoint(x: fixedCenter.x, y: round(fixedCenter.y))
                
            case .Vertical:
                _fixedCenter = CGPoint(x: round(fixedCenter.x), y: fixedCenter.y)
            }
            item.center = _fixedCenter
            
            dynamicAnimator.updateItemUsingCurrentState(item)
        }
        
        let oldBounds = self.collectionView!.frame
        if newBounds.width != oldBounds.width {
            dynamicAnimator.removeAllBehaviors()
            visibleIndexPathsSet = Set<NSIndexPath>()
            return false
        }
        return false
    }
}
