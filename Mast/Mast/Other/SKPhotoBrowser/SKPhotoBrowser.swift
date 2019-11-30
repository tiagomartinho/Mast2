//
//  SKPhotoBrowser.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import ActiveLabel

public let SKPHOTO_LOADING_DID_END_NOTIFICATION = "photoLoadingDidEndNotification"

// MARK: - SKPhotoBrowser
open class SKPhotoBrowser: UIViewController {
    // open function
    open var currentPageIndex: Int = 0
    open var initPageIndex: Int = 0
    open var activityItemProvider: UIActivityItemProvider?
    open var photos: [SKPhotoProtocol] = []
    
    internal lazy var pagingScrollView: SKPagingScrollView = SKPagingScrollView(frame: self.view.frame, browser: self)
    
    // appearance
    fileprivate let bgColor: UIColor = SKPhotoBrowserOptions.backgroundColor
    // animation
    let animator: SKAnimator = .init()
    
    // child component
    fileprivate var actionView: SKActionView!
    fileprivate(set) var paginationView: SKPaginationView!
//    var toolbar: SKToolbar!

    // actions
    fileprivate var activityViewController: UIActivityViewController!
    fileprivate var panGesture: UIPanGestureRecognizer?

    // for status check property
//    fileprivate var isEndAnimationByToolBar: Bool = true
    fileprivate var isViewActive: Bool = false
    fileprivate var isPerformingLayout: Bool = false
    
    // pangesture property
    fileprivate var firstX: CGFloat = 0.0
    fileprivate var firstY: CGFloat = 0.0
    
    // timer
    fileprivate var controlVisibilityTimer: Timer!
    
    // delegate
    open weak var delegate: SKPhotoBrowserDelegate?

    // statusbar initial state
    private var statusbarHidden: Bool = UIApplication.shared.isStatusBarHidden
    
    // strings
    open var cancelTitle = "Cancel"
    
    fileprivate let detailView = UIButton()
    fileprivate let detailText = ActiveLabel()
    fileprivate let detailView2 = UIButton()
    fileprivate var imageText : String? = ""
    fileprivate var imageText2 : Int? = 0
    fileprivate var imageText3 : Int? = 0
    fileprivate var imageText4 : String? = ""

    // MARK: - Initializer
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    public convenience init(photos: [SKPhotoProtocol]) {
        self.init(photos: photos, initialPageIndex: 0)
    }
    
    @available(*, deprecated)
    public convenience init(originImage: UIImage, photos: [SKPhotoProtocol], animatedFromView: UIView, imageText: String, imageText2: Int, imageText3: Int, imageText4: String) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.photos.forEach { $0.checkCache() }
        animator.senderOriginImage = originImage
        animator.senderViewForAnimation = animatedFromView
        
        self.imageText = imageText
        self.imageText2 = imageText2
        self.imageText3 = imageText3
        self.imageText4 = imageText4
    }
    
    public convenience init(photos: [SKPhotoProtocol], initialPageIndex: Int) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.photos.forEach { $0.checkCache() }
        self.currentPageIndex = min(initialPageIndex, photos.count - 1)
        self.initPageIndex = self.currentPageIndex
        animator.senderOriginImage = photos[currentPageIndex].underlyingImage
        animator.senderViewForAnimation = photos[currentPageIndex] as? UIView
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSKPhotoLoadingDidEndNotification(_:)),
                                               name: NSNotification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION),
                                               object: nil)
    }
    
    // MARK: - override
    override open func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configurePagingScrollView()
        configureGestureControl()
        configureActionView()
        configurePaginationView()
        configureToolbar()
        animator.willPresent(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.singleTap), name: NSNotification.Name(rawValue: "sksingle"), object: nil)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.7
        lpgr.delaysTouchesBegan = true
        self.pagingScrollView.addGestureRecognizer(lpgr)
        
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func bringBackViews() {
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.detailView.alpha = 1
                        self.detailView2.alpha = 1
                        self.detailText.alpha = 1
        },
                       completion: { _ in
                        
        }
        )
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadData()
        
        var i = 0
        for photo: SKPhotoProtocol in photos {
            photo.index = i
            i += 1
        }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        isPerformingLayout = true
        // where did start
        delegate?.didShowPhotoAtIndex?(self, index: currentPageIndex)

        // toolbar
//        toolbar.frame = frameForToolbarAtOrientation()
        
        // action
        actionView.updateFrame(frame: view.frame)

        // paging
        switch SKCaptionOptions.captionLocation {
        case .basic:
            paginationView.updateFrame(frame: view.frame)
        case .bottom:
            paginationView.frame = frameForPaginationAtOrientation()
        }
        pagingScrollView.updateFrame(view.bounds, currentPageIndex: currentPageIndex)

        isPerformingLayout = false
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }
    
    override open var prefersStatusBarHidden: Bool {
        return !SKPhotoBrowserOptions.displayStatusbar
    }
    
    // MARK: - Notification
    @objc open func handleSKPhotoLoadingDidEndNotification(_ notification: Notification) {
        guard let photo = notification.object as? SKPhotoProtocol else {
            return
        }
        
        DispatchQueue.main.async(execute: {
            guard let page = self.pagingScrollView.pageDisplayingAtPhoto(photo), let photo = page.photo else {
                return
            }
            
            if photo.underlyingImage != nil {
                page.displayImage(complete: true)
                self.loadAdjacentPhotosIfNecessary(photo)
            } else {
                page.displayImageFailure()
            }
        })
    }
    
    open func loadAdjacentPhotosIfNecessary(_ photo: SKPhotoProtocol) {
        pagingScrollView.loadAdjacentPhotosIfNecessary(photo, currentPageIndex: currentPageIndex)
    }
    
    // MARK: - initialize / setup
    open func reloadData() {
        performLayout()
        view.setNeedsLayout()
    }
    
    open func performLayout() {
        isPerformingLayout = true

        // reset local cache
        pagingScrollView.reload()
        pagingScrollView.updateContentOffset(currentPageIndex)
        pagingScrollView.tilePages()
        
        delegate?.didShowPhotoAtIndex?(self, index: currentPageIndex)
        
        isPerformingLayout = false
    }
    
    open func prepareForClosePhotoBrowser() {
        cancelControlHiding()
        if let panGesture = panGesture {
            view.removeGestureRecognizer(panGesture)
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    open func dismissPhotoBrowser(animated: Bool, completion: (() -> Void)? = nil) {
        prepareForClosePhotoBrowser()
//        if !animated {
//            modalTransitionStyle = .crossDissolve
//        }
        dismiss(animated: !animated) {
            completion?()
            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
        }
    }
    
    open func determineAndClose() {
        delegate?.willDismissAtPageIndex?(self.currentPageIndex)
        animator.willDismiss(self)
    }
    
    open func popupShare(includeCaption: Bool = true) {
        let photo = photos[currentPageIndex]
        guard let underlyingImage = photo.underlyingImage else {
            return
        }
        
        var activityItems: [AnyObject] = [underlyingImage]
        if photo.caption != nil && includeCaption {
            if let shareExtraCaption = SKPhotoBrowserOptions.shareExtraCaption {
                let caption = photo.caption ?? "" + shareExtraCaption
                activityItems.append(caption as AnyObject)
            } else {
                activityItems.append(photo.caption as AnyObject)
            }
        }
        
        if let activityItemProvider = activityItemProvider {
            activityItems.append(activityItemProvider)
        }
        
        activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            self.hideControlsAfterDelay()
            self.activityViewController = nil
        }
        if UI_USER_INTERFACE_IDIOM() == .phone {
            present(activityViewController, animated: true, completion: nil)
        } else {
            activityViewController.modalPresentationStyle = .popover
            let popover: UIPopoverPresentationController! = activityViewController.popoverPresentationController
//            popover.barButtonItem = toolbar.toolActionButton
            present(activityViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Public Function For Customizing Buttons

public extension SKPhotoBrowser {
    func updateCloseButton(_ image: UIImage, size: CGSize? = nil) {
        actionView.updateCloseButton(image: image, size: size)
    }
    
    func updateDeleteButton(_ image: UIImage, size: CGSize? = nil) {
        actionView.updateDeleteButton(image: image, size: size)
    }
}

// MARK: - Public Function For Browser Control

public extension SKPhotoBrowser {
    func initializePageIndex(_ index: Int) {
        let i = min(index, photos.count - 1)
        currentPageIndex = i
        
        if isViewLoaded {
            jumpToPageAtIndex(index)
            if !isViewActive {
                pagingScrollView.tilePages()
            }
            paginationView.update(currentPageIndex)
        }
        self.initPageIndex = currentPageIndex
    }
    
    func jumpToPageAtIndex(_ index: Int) {
        if index < photos.count {
//            if !isEndAnimationByToolBar {
//                return
//            }
//            isEndAnimationByToolBar = false

            let pageFrame = frameForPageAtIndex(index)
            pagingScrollView.jumpToPageAtIndex(pageFrame)
        }
        hideControlsAfterDelay()
    }
    
    func photoAtIndex(_ index: Int) -> SKPhotoProtocol {
        return photos[index]
    }
    
    @objc func gotoPreviousPage() {
        jumpToPageAtIndex(currentPageIndex - 1)
    }
    
    @objc func gotoNextPage() {
        jumpToPageAtIndex(currentPageIndex + 1)
    }
    
    func cancelControlHiding() {
        if controlVisibilityTimer != nil {
            controlVisibilityTimer.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    func hideControlsAfterDelay() {
        // reset
        cancelControlHiding()
        // start
        controlVisibilityTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(SKPhotoBrowser.hideControls(_:)), userInfo: nil, repeats: false)
    }
    
    func hideControls() {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    @objc func hideControls(_ timer: Timer) {
        hideControls()
        delegate?.controlsVisibilityToggled?(self, hidden: true)
    }
    
    func toggleControls() {
        let hidden = !areControlsHidden()
        setControlsHidden(hidden, animated: true, permanent: false)
        delegate?.controlsVisibilityToggled?(self, hidden: areControlsHidden())
    }
    
    func areControlsHidden() -> Bool {
        return paginationView.alpha == 0.0
    }
    
    func getCurrentPageIndex() -> Int {
        return currentPageIndex
    }
    
    func addPhotos(photos: [SKPhotoProtocol]) {
        self.photos.append(contentsOf: photos)
        self.reloadData()
    }
    
    func insertPhotos(photos: [SKPhotoProtocol], at index: Int) {
        self.photos.insert(contentsOf: photos, at: index)
        self.reloadData()
    }
}

// MARK: - Internal Function

internal extension SKPhotoBrowser {
    func showButtons() {
        actionView.animate(hidden: false)
    }
    
    func pageDisplayedAtIndex(_ index: Int) -> SKZoomingScrollView? {
        return pagingScrollView.pageDisplayedAtIndex(index)
    }
    
    func getImageFromView(_ sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

// MARK: - Internal Function For Frame Calc

internal extension SKPhotoBrowser {
    func frameForToolbarAtOrientation() -> CGRect {
        let offset: CGFloat = {
            if #available(iOS 11.0, *) {
                return view.safeAreaInsets.bottom
            } else {
                return 15
            }
        }()
        return view.bounds.divided(atDistance: 44, from: .maxYEdge).slice.offsetBy(dx: 0, dy: -offset)
    }
    
    func frameForToolbarHideAtOrientation() -> CGRect {
        return view.bounds.divided(atDistance: 44, from: .maxYEdge).slice.offsetBy(dx: 0, dy: 44)
    }
    
    func frameForPaginationAtOrientation() -> CGRect {
        let offset = UIDevice.current.orientation.isLandscape ? 35 : 44
        
        return CGRect(x: 0, y: self.view.bounds.size.height - CGFloat(offset), width: self.view.bounds.size.width, height: CGFloat(offset))
    }
    
    func frameForPageAtIndex(_ index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
}

// MARK: - Internal Function For Button Pressed, UIGesture Control

internal extension SKPhotoBrowser {
    @objc func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        guard let zoomingScrollView: SKZoomingScrollView = pagingScrollView.pageDisplayedAtIndex(currentPageIndex) else {
            return
        }
        
        animator.backgroundView.isHidden = true
        let viewHeight: CGFloat = zoomingScrollView.frame.size.height
        let viewHalfHeight: CGFloat = viewHeight/2
        var translatedPoint: CGPoint = sender.translation(in: self.view)
        
        // gesture began
        if sender.state == .began {
            firstX = zoomingScrollView.center.x
            firstY = zoomingScrollView.center.y
            

            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.detailView.alpha = 0
                            self.detailView2.alpha = 0
                            self.detailText.alpha = 0
            },
                           completion: { _ in
                            
            }
            )
            
            hideControls()
            setNeedsStatusBarAppearanceUpdate()
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let minOffset: CGFloat = viewHalfHeight / 4
        let offset: CGFloat = 1 - (zoomingScrollView.center.y > viewHalfHeight
            ? zoomingScrollView.center.y - viewHalfHeight
            : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        view.backgroundColor = bgColor.withAlphaComponent(max(0.7, offset))
        
        // gesture end
        if sender.state == .ended {
            
            if zoomingScrollView.center.y > viewHalfHeight + minOffset
                || zoomingScrollView.center.y < viewHalfHeight - minOffset {

                UIApplication.shared.setStatusBarHidden(false, with: .fade)
                setNeedsStatusBarAppearanceUpdate()
                
                determineAndClose()
                
            } else {
                // Continue Showing View
                setNeedsStatusBarAppearanceUpdate()
                view.backgroundColor = bgColor

                let velocityY: CGFloat = CGFloat(0.35) * sender.velocity(in: self.view).y
                let finalX: CGFloat = firstX
                let finalY: CGFloat = viewHalfHeight
                
                let animationDuration: Double = Double(abs(velocityY) * 0.0002 + 0.2)
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(UIView.AnimationCurve.easeIn)
                zoomingScrollView.center = CGPoint(x: finalX, y: finalY)
                UIView.commitAnimations()

                UIView.animate(withDuration: 0.2,
                               animations: {
                                self.detailView.alpha = 1
                                self.detailView2.alpha = 1
                                self.detailText.alpha = 1
                },
                               completion: { _ in
                                
                }
                )
            }
        }
    }
   
    @objc func actionButtonPressed(ignoreAndShare: Bool) {
        delegate?.willShowActionSheet?(currentPageIndex)
        
        guard photos.count > 0 else {
            return
        }
        
        if let titles = SKPhotoBrowserOptions.actionButtonTitles {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
            
            for idx in titles.indices {
                actionSheetController.addAction(UIAlertAction(title: titles[idx], style: .default, handler: { (_) -> Void in
                    self.delegate?.didDismissActionSheetWithButtonIndex?(idx, photoIndex: self.currentPageIndex)
                }))
            }
            
            if UI_USER_INTERFACE_IDIOM() == .phone {
                present(actionSheetController, animated: true, completion: nil)
            } else {
                actionSheetController.modalPresentationStyle = .popover
                
                if let popoverController = actionSheetController.popoverPresentationController {
                    popoverController.sourceView = self.view
//                    popoverController.barButtonItem = toolbar.toolActionButton
                }
                
                present(actionSheetController, animated: true, completion: { () -> Void in
                })
            }
            
        } else {
            popupShare()
        }
    }
    
    func deleteImage() {
        defer {
            reloadData()
        }
        
        if photos.count > 1 {
            pagingScrollView.deleteImage()
            
            photos.remove(at: currentPageIndex)
            if currentPageIndex != 0 {
                gotoPreviousPage()
            }
            paginationView.update(currentPageIndex)
            
        } else if photos.count == 1 {
            dismissPhotoBrowser(animated: true)
        }
    }
}

// MARK: - Private Function
private extension SKPhotoBrowser {
    func configureAppearance() {
        view.backgroundColor = bgColor
        view.clipsToBounds = true
        view.isOpaque = false
        
        if #available(iOS 11.0, *) {
            view.accessibilityIgnoresInvertColors = true
        }
    }
    
    func configurePagingScrollView() {
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
    }

    func configureGestureControl() {
        guard !SKPhotoBrowserOptions.disableVerticalSwipe else { return }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SKPhotoBrowser.panGestureRecognized(_:)))
        panGesture?.minimumNumberOfTouches = 1
        panGesture?.maximumNumberOfTouches = 1

        if let panGesture = panGesture {
            view.addGestureRecognizer(panGesture)
        }
    }
    
    func configureActionView() {
        actionView = SKActionView(frame: view.frame, browser: self)
        view.addSubview(actionView)
    }

    func configurePaginationView() {
        paginationView = SKPaginationView(frame: view.frame, browser: self)
        view.addSubview(paginationView)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.detailView.alpha = 0
                            self.detailView2.alpha = 0
                            self.detailText.alpha = 0
            },
                           completion: { _ in
                            
            }
            )
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let op1 = UIAlertAction(title: "Share".localized, style: .default , handler:{ (UIAlertAction) in
                let imToShare = [self.photos[self.currentPageIndex].underlyingImage ?? UIImage()]
                let activityViewController = UIActivityViewController(activityItems: imToShare,  applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.pagingScrollView.inputView
                activityViewController.popoverPresentationController?.sourceRect = self.pagingScrollView.inputView!.bounds
                self.present(activityViewController, animated: true, completion: nil)
                self.bringBackViews()
            })
            op1.setValue(UIImage(systemName: "square.and.arrow.up")!, forKey: "image")
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            let op2 = UIAlertAction(title: "Save".localized, style: .default , handler:{ (UIAlertAction) in
                UIImageWriteToSavedPhotosAlbum(self.photos[self.currentPageIndex].underlyingImage ?? UIImage(), nil, nil, nil)
                self.bringBackViews()
            })
            op2.setValue(UIImage(systemName: "square.and.arrow.down")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                self.bringBackViews()
            }))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.pagingScrollView.inputView
                presenter.sourceRect = self.pagingScrollView.inputView!.bounds
            }
            self.present(alert, animated: true, completion: nil)
        } else if gestureReconizer.state == UIGestureRecognizer.State.ended {
            
        } else {
            //When lognpress is finish
        }
    }
    
    @objc func singleTap() {
        if self.detailView.alpha == 1 {
            UIView.animate(withDuration: 0.14,
                           animations: {
                            self.detailView.alpha = 0
                            self.detailView2.alpha = 0
                            self.detailText.alpha = 0
            },
                           completion: { _ in
            })
        } else {
            UIView.animate(withDuration: 0.14,
                           animations: {
                            self.detailView.alpha = 1
                            self.detailView2.alpha = 1
                            self.detailText.alpha = 1
            },
                           completion: { _ in
            })
        }
        
    }
    
    @objc func viewTootTapped() {
        dismiss(animated: true, completion: {
            GlobalStruct.thePassedID = self.imageText4 ?? ""
            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)
            if GlobalStruct.currentTab == 1 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail1"), object: nil)
            }
            if GlobalStruct.currentTab == 2 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail2"), object: nil)
            }
            if GlobalStruct.currentTab == 3 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail3"), object: nil)
            }
            if GlobalStruct.currentTab == 4 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail4"), object: nil)
            }
            if GlobalStruct.currentTab == 5 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail5"), object: nil)
            }
            if GlobalStruct.currentTab == 999 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail6"), object: nil)
            }
            if GlobalStruct.currentTab == 998 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail7"), object: nil)
            }
            if GlobalStruct.currentTab == 997 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail8"), object: nil)
            }
            if GlobalStruct.currentTab == 996 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "openTootDetail9"), object: nil)
            }
        })
    }
    
    func configureToolbar() {
//        toolbar = SKToolbar(frame: frameForToolbarAtOrientation(), browser: self)
//        view.addSubview(toolbar)
        
        detailView.layer.cornerRadius = 8
        if #available(iOS 13.0, *) {
            detailView.backgroundColor = UIColor(named: "darkGray")!
            detailView.layer.cornerCurve = .continuous
        }
        detailView.addTarget(self, action: #selector(self.viewTootTapped), for: .touchUpInside)
        self.view.addSubview(detailView)
        
        if #available(iOS 11.0, *) {
            detailText.frame = CGRect(x: 30, y: self.view.bounds.height - 60 - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0), width: self.view.bounds.width - 60, height: 50)
        }
        detailText.textAlignment = .left
        detailText.text = self.imageText
        detailText.textColor = UIColor.white
        detailText.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        detailText.isUserInteractionEnabled = false
        detailText.numberOfLines = 8
        detailText.sizeToFit()
        if #available(iOS 13.0, *) {
            detailText.frame.origin.y = self.view.bounds.height - detailText.frame.height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) - 5
        }
        detailText.enabledTypes = [.mention, .hashtag, .url]
        detailText.mentionColor = GlobalStruct.baseTint
        detailText.hashtagColor = GlobalStruct.baseTint
        detailText.URLColor = GlobalStruct.baseTint
        self.view.addSubview(detailText)
        
        detailView.frame = detailText.frame
        detailView.frame.size.width = self.view.bounds.width - 40
        detailView.frame.size.height = detailText.bounds.height + 16
        detailView.frame.origin.y = detailText.frame.origin.y - 8
        detailView.frame.origin.x = detailText.frame.origin.x - 10
        
        detailView2.layer.cornerRadius = 10
        if #available(iOS 13.0, *) {
            detailView2.backgroundColor = UIColor(named: "darkerGray")!
            detailView2.layer.cornerCurve = .continuous
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: imageText2 ?? 0))
        let numberFormatter2 = NumberFormatter()
        numberFormatter2.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber2 = numberFormatter2.string(from: NSNumber(value: imageText3 ?? 0))
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize - 4, weight: .bold)
        let normalFont = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize - 2)
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "heart", withConfiguration: symbolConfig)?.withTintColor(UIColor.white.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        let attachment2 = NSTextAttachment()
        attachment2.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor.white.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        let attStringNewLine = NSMutableAttributedString(string: "\(formattedNumber ?? "0")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(1)])
        let attStringNewLine2 = NSMutableAttributedString(string: "\(formattedNumber2 ?? "0")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(1)])
        let attString = NSAttributedString(attachment: attachment)
        let attString2 = NSAttributedString(attachment: attachment2)
        let fullString = NSMutableAttributedString(string: "")
        let spaceString0 = NSMutableAttributedString(string: " ")
        let spaceString = NSMutableAttributedString(string: "  ")
        fullString.append(attString)
        fullString.append(spaceString0)
        fullString.append(attStringNewLine)
        fullString.append(spaceString)
        fullString.append(attString2)
        fullString.append(spaceString0)
        fullString.append(attStringNewLine2)
        detailView2.setAttributedTitle(fullString, for: .normal)
        detailView2.contentHorizontalAlignment = .left
        detailView2.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        detailView2.sizeToFit()
        detailView2.frame.origin.y = detailView.frame.origin.y - detailView2.bounds.height - 10
        detailView2.frame.origin.x = detailView.frame.origin.x
        self.view.addSubview(detailView2)
        
        detailView.layer.shadowColor = UIColor(named: "alwaysBlack")!.cgColor
        detailView.layer.shadowOffset = CGSize(width: 0, height: 12)
        detailView.layer.shadowRadius = 12
        detailView.layer.shadowOpacity = 0.18
        
        detailView2.layer.shadowColor = UIColor(named: "alwaysBlack")!.cgColor
        detailView2.layer.shadowOffset = CGSize(width: 0, height: 12)
        detailView2.layer.shadowRadius = 12
        detailView2.layer.shadowOpacity = 0.18
        
        UIView.animate(withDuration: 2, animations: {
            if self.imageText4 == "" {
                self.detailView.alpha = 0
                self.detailView2.alpha = 0
                self.detailText.alpha = 0
            } else {
                self.detailView.alpha = 1
                self.detailView2.alpha = 1
                self.detailText.alpha = 1
            }
        }, completion: { _ in
            
        })
    }

    func setControlsHidden(_ hidden: Bool, animated: Bool, permanent: Bool) {
        // timer update
        cancelControlHiding()
        
        // scroll animation
        pagingScrollView.setControlsHidden(hidden: hidden)

        // paging animation
        paginationView.setControlsHidden(hidden: hidden)
        
        // action view animation
        actionView.animate(hidden: hidden)
        
        if !hidden && !permanent {
            hideControlsAfterDelay()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - UIScrollView Delegate

extension SKPhotoBrowser: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isViewActive else { return }
        guard !isPerformingLayout else { return }
        
        // tile page
        pagingScrollView.tilePages()
        
        // Calculate current page
        let previousCurrentPage = currentPageIndex
        let visibleBounds = pagingScrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), photos.count - 1)
        
        if currentPageIndex != previousCurrentPage {
            delegate?.didShowPhotoAtIndex?(self, index: currentPageIndex)
            paginationView.update(currentPageIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hideControlsAfterDelay()
        
        let currentIndex = pagingScrollView.contentOffset.x / pagingScrollView.frame.size.width
        delegate?.didScrollToIndex?(self, index: Int(currentIndex))
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        isEndAnimationByToolBar = true
    }
}
