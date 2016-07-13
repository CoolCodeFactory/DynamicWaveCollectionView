//
//  DynamicWaveCollectionViewFlowLayout.swift
//  DynamicWaveCollectionView
//
//  Created by Dmitry Utmanov on 10/07/16.
//  Copyright © 2016 Dmitry Utmanov. All rights reserved.
//

import UIKit

public class DynamicWaveCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    public var length: CGFloat = 0.0 {
        didSet {
            dynamicAnimator.removeAllBehaviors()
            visibleIndexPathsSet = Set<NSIndexPath>()
        }
    }
    public var damping: CGFloat = 0.8 {
        didSet {
            dynamicAnimator.removeAllBehaviors()
            visibleIndexPathsSet = Set<NSIndexPath>()
        }
    }
    public var frequency: CGFloat = 1.0 {
        didSet {
            dynamicAnimator.removeAllBehaviors()
            visibleIndexPathsSet = Set<NSIndexPath>()
        }
    }
    public var resistance: CGFloat = 1000.0 {
        didSet {
            dynamicAnimator.removeAllBehaviors()
            visibleIndexPathsSet = Set<NSIndexPath>()
        }
    }
    
    public var transformX: CGFloat = 0.4
    public var transformY: CGFloat = 0.4
    
    
    var downscaleIndexPaths: Set<NSIndexPath>?
    
    var dynamicAnimator: UIDynamicAnimator!
    var visibleIndexPathsSet: Set<NSIndexPath>!
    var latestDelta: CGFloat = 0.0
    
    let kElementKindSectionHeaderItem = Int.max - 1
    let kElementKindSectionFooterItem = Int.max - 2
    
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
                    
                    if let kind = collectionViewLayoutAttributes.representedElementKind {
                        switch kind {
                        case UICollectionElementKindSectionHeader:
                            let indexPath = NSIndexPath(forItem: kElementKindSectionHeaderItem, inSection: collectionViewLayoutAttributes.indexPath.section)
                            self.visibleIndexPathsSet.remove(indexPath)
                            
                        case UICollectionElementKindSectionFooter:
                            let indexPath = NSIndexPath(forItem: kElementKindSectionFooterItem, inSection: collectionViewLayoutAttributes.indexPath.section)
                            self.visibleIndexPathsSet.remove(indexPath)
                            
                        default:
                            fatalError("Unknown kind type")
                        }
                    } else {
                        self.visibleIndexPathsSet.remove(collectionViewLayoutAttributes.indexPath)
                    }
                }
            }
            
            let newlyVisibleItems = itemsInVisibleRectArray.filter({ (collectionViewLayoutAttributes) -> Bool in
                if let kind = collectionViewLayoutAttributes.representedElementKind {
                    switch kind {
                    case UICollectionElementKindSectionHeader:
                        let indexPath = NSIndexPath(forItem: kElementKindSectionHeaderItem, inSection: collectionViewLayoutAttributes.indexPath.section)
                        return !visibleIndexPathsSet.contains(indexPath)
                        
                    case UICollectionElementKindSectionFooter:
                        let indexPath = NSIndexPath(forItem: kElementKindSectionFooterItem, inSection: collectionViewLayoutAttributes.indexPath.section)
                        return !visibleIndexPathsSet.contains(indexPath)
                        
                    default:
                        fatalError("Unknown kind type")
                    }
                } else {
                    return !visibleIndexPathsSet.contains(collectionViewLayoutAttributes.indexPath)
                }
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
                springBehaviour.length = length
                springBehaviour.damping = damping
                springBehaviour.frequency = frequency
                
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
                
                if let kind = item.representedElementKind {
                    switch kind {
                    case UICollectionElementKindSectionHeader:
                        let indexPath = NSIndexPath(forItem: kElementKindSectionHeaderItem, inSection: item.indexPath.section)
                        self.visibleIndexPathsSet.insert(indexPath)

                    case UICollectionElementKindSectionFooter:
                        let indexPath = NSIndexPath(forItem: kElementKindSectionFooterItem, inSection: item.indexPath.section)
                        self.visibleIndexPathsSet.insert(indexPath)
                        
                    default:
                        fatalError("Unknown kind type")
                    }
                } else {
                    self.visibleIndexPathsSet.insert(item.indexPath)
                }
            }
        }
        
        print(visibleIndexPathsSet.count)
        print(dynamicAnimator.behaviors.count)
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = dynamicAnimator.itemsInRect(rect) as! [UICollectionViewLayoutAttributes]
        
        if let downscaleIndexPaths = downscaleIndexPaths {
            let scaledLayoutAttributes: [UICollectionViewLayoutAttributes] = layoutAttributes.map({ (collectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes in
                if downscaleIndexPaths.contains(collectionViewLayoutAttributes.indexPath) {
                    collectionViewLayoutAttributes.transform = CGAffineTransformScale(CGAffineTransformIdentity, transformX, transformY)
                } else {
                    collectionViewLayoutAttributes.transform = CGAffineTransformIdentity
                }
                return collectionViewLayoutAttributes
            })
            return scaledLayoutAttributes
        } else {
            return layoutAttributes
        }
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
