//
//  PreviewCollectionCell.swift
//  Clean
//
//  Created by liqi on 2020/10/28.
//

import UIKit
import Photos
import PhotosUI

class PreviewBaseCell: CollectionViewCell {
    
    var singleTapBlock: ( () -> Void )?
    
    var currentImage: UIImage? {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(previewVCScroll), name: PhotoPreviewViewController.previewVCScrollNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func previewVCScroll() {
        
    }
    
    func resetSubViewStatusWhenCellEndDisplay() {
        
    }
    
    func resizeImageView(imageView: UIImageView, asset: PHAsset) {
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        var frame: CGRect = .zero
        
        let viewW = self.bounds.width
        let viewH = self.bounds.height
        
        var width = min(viewW, size.width)
        
        // video和livephoto没必要处理长图和宽图
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = min(self.bounds.height, size.height)
            frame.size.height = height
            
            let imageWHRatio = size.width / size.height
            let viewWHRatio = viewW / viewH
            
            if imageWHRatio > viewWHRatio {
                frame.size.width = floor(height * imageWHRatio)
                if frame.size.width > viewW {
                    frame.size.width = viewW
                    frame.size.height = viewW / imageWHRatio
                }
            } else {
                width = floor(height * imageWHRatio)
                if width < 1 || width.isNaN {
                    width = viewW
                }
                frame.size.width = width
            }
        } else {
            frame.size.width = width
            
            let imageHWRatio = size.height / size.width
            let viewHWRatio = viewH / viewW
            
            if imageHWRatio > viewHWRatio {
                frame.size.height = floor(width * imageHWRatio)
            } else {
                var height = floor(width * imageHWRatio)
                if height < 1 || height.isNaN {
                    height = viewH
                }
                frame.size.height = height
            }
        }
        
        imageView.frame = frame
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            if frame.height < viewH {
                imageView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                imageView.frame = CGRect(origin: CGPoint(x: (viewW-frame.width)/2, y: 0), size: frame.size)
            }
        } else {
            if frame.width < viewW || frame.height < viewH {
                imageView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            }
        }
    }
    
    func animateImageFrame(convertTo view: UIView) -> CGRect {
        return .zero
    }
    
}

class PhotoPreviewCell: PreviewBaseCell {
    
    override var currentImage: UIImage? {
        return self.preview.image
    }
    
    var preview: PreviewView!
    
    var model: PhotoModel! {
        didSet {
            self.preview.model = self.model
        }
    }
    
    deinit {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.preview.frame = self.bounds
    }
    
    private func setupUI() {
        self.preview = PreviewView()
        self.preview.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        self.contentView.addSubview(self.preview)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        self.preview.scrollView.zoomScale = 1
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        let r1 = self.preview.scrollView.convert(self.preview.containerView.frame, to: self)
        return self.convert(r1, to: view)
    }
    
}

class GifPreviewCell: PreviewBaseCell {
    
    override var currentImage: UIImage? {
        return self.preview.image
    }
    
    var preview: PreviewView!
    
    var model: PhotoModel! {
        didSet {
            self.preview.model = self.model
        }
    }
    
    deinit {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.preview.frame = self.bounds
    }
    
    private func setupUI() {
        self.preview = PreviewView()
        self.preview.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        self.contentView.addSubview(self.preview)
    }
    
    override func previewVCScroll() {
        self.preview.pauseGif()
    }
    
    func resumeGif() {
        self.preview.resumeGif()
    }
    
    func pauseGif() {
        self.preview.pauseGif()
    }
    
    /// gif图加载会导致主线程卡顿一下，所以放在willdisplay时候加载
    func loadGifWhenCellDisplaying() {
        self.preview.loadGifData()
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        self.preview.scrollView.zoomScale = 1
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        let r1 = self.preview.scrollView.convert(self.preview.containerView.frame, to: self)
        return self.convert(r1, to: view)
    }
    
}

class LivePhotoPewviewCell: PreviewBaseCell {
    
    override var currentImage: UIImage? {
        return self.imageView.image
    }
    
    var livePhotoView: PHLivePhotoView!
    
    var imageView: UIImageView!
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var livePhotoRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var onFetchingLivePhoto = false
    
    var fetchLivePhotoDone = false
    
    var model: PhotoModel! {
        didSet {
            self.loadNormalImage()
        }
    }
    
    deinit {

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.livePhotoView.frame = self.bounds
        self.resizeImageView(imageView: self.imageView, asset: self.model.asset)
    }
    
    private func setupUI() {
        self.livePhotoView = PHLivePhotoView()
        self.livePhotoView.contentMode = .scaleAspectFit
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        self.livePhotoView.addGestureRecognizer(singleTap)
        self.contentView.addSubview(self.livePhotoView)
        
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.imageView)
    }
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        self.singleTapBlock?()
    }
    
    override func previewVCScroll() {
        self.livePhotoView.stopPlayback()
    }
    
    func loadNormalImage() {
        if self.imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        if self.livePhotoRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.livePhotoRequestID)
        }
        self.onFetchingLivePhoto = false
        self.imageView.isHidden = false
        
        // livephoto 加载个较小的预览图即可
        var size = self.model.previewSize
        size.width /= 4
        size.height /= 4
        
        self.resizeImageView(imageView: self.imageView, asset: self.model.asset)
        self.imageRequestID = PhotoHelper.fetchImage(for: self.model.asset, size: size, completion: { [weak self] (image, isDegread) in
            self?.imageView.image = image
        })
    }
    
    func loadLivePhotoData() {
        guard !self.onFetchingLivePhoto else {
            if self.fetchLivePhotoDone {
                self.startPlayLivePhoto()
            }
            return
        }
        self.onFetchingLivePhoto = true
        self.fetchLivePhotoDone = false
        
        self.livePhotoRequestID = PhotoHelper.fetchLivePhoto(for: self.model.asset, completion: { (livePhoto, info, isDegraded) in
            if !isDegraded {
                self.fetchLivePhotoDone = true
                self.livePhotoView.livePhoto = livePhoto
                self.startPlayLivePhoto()
            }
        })
    }
    
    func startPlayLivePhoto() {
        self.imageView.isHidden = true
        self.livePhotoView.startPlayback(with: .full)
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        return self.convert(self.imageView.frame, to: view)
    }
    
}

class VideoPreviewCell: PreviewBaseCell {
    
    override var currentImage: UIImage? {
        return self.imageView.image
    }
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    var progressView: PhotoProgressView!
    
    var imageView: UIImageView!
    
    var playBtn: UIButton!
    
    var syncErrorLabel: UILabel!
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var videoRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var onFetchingVideo = false
    
    var fetchVideoDone = false
    
    var isPlaying: Bool {
        if self.player != nil, self.player?.rate != 0 {
            return true
        }
        return false
    }
    
    var model: PhotoModel! {
        didSet {
            self.configureCell()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
        self.resizeImageView(imageView: self.imageView, asset: self.model.asset)
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        self.playBtn.frame = CGRect(x: 0, y: insets.top, width: self.bounds.width, height: self.bounds.height - insets.top - insets.bottom)
        self.syncErrorLabel.frame = CGRect(x: 10, y: insets.top + 60, width: self.bounds.width - 20, height: 35)
        self.progressView.frame = CGRect(x: self.bounds.width / 2 - 30, y: self.bounds.height / 2 - 30, width: 60, height: 60)
    }
    
    private func setupUI() {
        self.imageView = UIImageView()
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.imageView)
        
        let attStr = NSMutableAttributedString()
//        let attach = NSTextAttachment()
//        attach.image = getImage("zl_videoLoadFailed")
//        attach.bounds = CGRect(x: 0, y: -10, width: 30, height: 30)
//        attStr.append(NSAttributedString(attachment: attach))
        let errorText = NSAttributedString(string: "iCloud无法同步", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(style: .regular, size: 12.uiX)])
        attStr.append(errorText)
        self.syncErrorLabel = UILabel()
        self.syncErrorLabel.attributedText = attStr
        self.contentView.addSubview(self.syncErrorLabel)
        
        self.progressView = PhotoProgressView()
        self.contentView.addSubview(self.progressView)
        
        self.playBtn = UIButton(type: .custom)
        self.playBtn.setImage(.create("bf-icon"), for: .normal)
        self.playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        self.contentView.addSubview(self.playBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func configureCell() {
        self.imageView.image = nil
        self.imageView.isHidden = false
        self.syncErrorLabel.isHidden = true
        self.playBtn.isEnabled = false
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
        if self.imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        if self.videoRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.videoRequestID)
        }
        
        // 视频预览图尺寸
        var size = self.model.previewSize
        size.width /= 2
        size.height /= 2
        
        self.resizeImageView(imageView: self.imageView, asset: self.model.asset)
        self.imageRequestID = PhotoHelper.fetchImage(for: self.model.asset, size: size, completion: { (image, isDegraded) in
            self.imageView.image = image
        })
        
        self.videoRequestID = PhotoHelper.fetchVideo(for: self.model.asset, progress: { [weak self] (progress, _, _, _) in
            self?.progressView.progress = progress
            if progress >= 1 {
                self?.progressView.isHidden = true
            } else {
                self?.progressView.isHidden = false
            }
        }, completion: { [weak self] (item, info, isDegraded) in
            let error = info?[PHImageErrorKey] as? Error
            let isFetchError = PhotoHelper.isFetchImageError(error)
            if isFetchError {
                self?.syncErrorLabel.isHidden = false
                self?.playBtn.setImage(nil, for: .normal)
            }
            if !isDegraded, item != nil {
                self?.fetchVideoDone = true
                self?.configurePlayerLayer(item!)
            }
        })
    }
    
    func configurePlayerLayer(_ item: AVPlayerItem) {
        self.playBtn.setImage(.create("bf-icon"), for: .normal)
        self.playBtn.isEnabled = true
        
        self.player = AVPlayer(playerItem: item)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.frame = self.bounds
        self.layer.insertSublayer(self.playerLayer!, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinish), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    @objc func playBtnClick() {
        let currentTime = self.player?.currentItem?.currentTime()
        let duration = self.player?.currentItem?.duration
        if self.player?.rate == 0 {
            if currentTime?.value == duration?.value {
                self.player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
            }
            self.imageView.isHidden = true
            self.player?.play()
            self.playBtn.setImage(nil, for: .normal)
            self.singleTapBlock?()
        } else {
            self.pausePlayer(seekToZero: false)
        }
    }
    
    @objc func playFinish() {
        self.pausePlayer(seekToZero: true)
    }
    
    @objc func appWillResignActive() {
        if self.player != nil, self.player?.rate != 0 {
            self.pausePlayer(seekToZero: false)
        }
    }
    
    override func previewVCScroll() {
        if self.player != nil, self.player?.rate != 0 {
            self.pausePlayer(seekToZero: false)
        }
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        self.imageView.isHidden = false
        self.player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
    }
    
    func pausePlayer(seekToZero: Bool) {
        self.player?.pause()
        if seekToZero {
            self.player?.seek(to: .zero)
        }
        self.playBtn.setImage(.create("bf-icon"), for: .normal)
        self.singleTapBlock?()
    }
    
    func pauseWhileTransition() {
        self.player?.pause()
        self.playBtn.setImage(.create("bf-icon"), for: .normal)
    }
    
    override func animateImageFrame(convertTo view: UIView) -> CGRect {
        return self.convert(self.imageView.frame, to: view)
    }
    
}

class LocalImagePreviewCell: PreviewBaseCell {
    
    override var currentImage: UIImage? {
        return self.preview.image
    }
    
    var preview: PreviewView!
    
    var image: UIImage? = nil {
        didSet {
            self.preview.imageView.image = image
            self.preview.resetSubViewSize()
        }
    }
    
    deinit {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.preview.frame = self.bounds
    }
    
    private func setupUI() {
        self.preview = PreviewView()
        self.preview.singleTapBlock = { [weak self] in
            self?.singleTapBlock?()
        }
        self.contentView.addSubview(self.preview)
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        self.preview.scrollView.zoomScale = 1
    }
    
}

class NetVideoPreviewCell: PreviewBaseCell {
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    var playBtn: UIButton!
    
    var isPlaying: Bool {
        if self.player != nil, self.player?.rate != 0 {
            return true
        }
        return false
    }
    
    var videoUrl: URL! {
        didSet {
            self.configureCell()
        }
    }
    
    deinit {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        self.playBtn.frame = CGRect(x: 0, y: insets.top, width: self.bounds.width, height: self.bounds.height - insets.top - insets.bottom)
    }
    
    private func setupUI() {
        self.playBtn = UIButton(type: .custom)
        self.playBtn.setImage(.create("bf-icon"), for: .normal)
        self.playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        self.contentView.addSubview(self.playBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func configureCell() {
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
        self.player = AVPlayer(playerItem: AVPlayerItem(url: self.videoUrl))
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.frame = self.bounds
        self.layer.insertSublayer(self.playerLayer!, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinish), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    @objc func playBtnClick() {
        let currentTime = self.player?.currentItem?.currentTime()
        let duration = self.player?.currentItem?.duration
        if self.player?.rate == 0 {
            if currentTime?.value == duration?.value {
                self.player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
            }
            self.player?.play()
            self.playBtn.setImage(nil, for: .normal)
            self.singleTapBlock?()
        } else {
            self.pausePlayer(seekToZero: false)
        }
    }
    
    @objc func playFinish() {
        self.pausePlayer(seekToZero: true)
    }
    
    @objc func appWillResignActive() {
        if self.player != nil, self.player?.rate != 0 {
            self.pausePlayer(seekToZero: false)
        }
    }
    
    override func previewVCScroll() {
        if self.player != nil, self.player?.rate != 0 {
            self.pausePlayer(seekToZero: false)
        }
    }
    
    override func resetSubViewStatusWhenCellEndDisplay() {
        self.player?.currentItem?.seek(to: CMTimeMake(value: 0, timescale: 1))
    }
    
    func pausePlayer(seekToZero: Bool) {
        self.player?.pause()
        if seekToZero {
            self.player?.seek(to: .zero)
        }
        self.playBtn.setImage(.create("bf-icon"), for: .normal)
        self.singleTapBlock?()
    }
    
}

class PreviewView: UIView {
    
    static let defaultMaxZoomScale: CGFloat = 3
    
    var scrollView: UIScrollView!
    
    var containerView: UIView!
    
    var imageView: UIImageView!
    
    var image: UIImage?
    
    var progressView: PhotoProgressView!
    
    var singleTapBlock: ( () -> Void )?
    
    var doubleTapBlock: ( () -> Void )?
    
    var imageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var gifImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    
    var imageIdentifier: String = ""
    
    var onFetchingGif = false
    
    var fetchGifDone = false
    
    var model: PhotoModel! {
        didSet {
            self.configureView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.progressView.frame = CGRect(x: self.bounds.width / 2 - 20, y: self.bounds.height / 2 - 20, width: 40, height: 40)
        self.scrollView.zoomScale = 1
        self.resetSubViewSize()
    }
    
    func setupUI() {
        self.scrollView = UIScrollView()
        self.scrollView.maximumZoomScale = PreviewView.defaultMaxZoomScale
        self.scrollView.minimumZoomScale = 1
        self.scrollView.isMultipleTouchEnabled = true
        self.scrollView.delegate = self
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delaysContentTouches = false
        self.addSubview(self.scrollView)
        
        self.containerView = UIView()
        self.scrollView.addSubview(self.containerView)
        
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.containerView.addSubview(self.imageView)
        
        self.progressView = PhotoProgressView()
        self.addSubview(self.progressView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        self.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    @objc func singleTapAction(_ tap: UITapGestureRecognizer) {
        self.singleTapBlock?()
    }
    
    @objc func doubleTapAction(_ tap: UITapGestureRecognizer) {
        let scale: CGFloat = self.scrollView.zoomScale != self.scrollView.maximumZoomScale ? self.scrollView.maximumZoomScale : 1
        let tapPoint = tap.location(in: self)
        var rect = CGRect.zero
        rect.size.width = self.scrollView.frame.width / scale
        rect.size.height = self.scrollView.frame.height / scale
        rect.origin.x = tapPoint.x - (rect.size.width / 2)
        rect.origin.y = tapPoint.y - (rect.size.height / 2)
        self.scrollView.zoom(to: rect, animated: true)
    }
    
    func configureView() {
        if self.imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        if self.gifImageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(self.gifImageRequestID)
        }
        
        self.scrollView.zoomScale = 1
        self.imageIdentifier = self.model.ident
        
        if self.model.type == .gif {
            self.loadGifFirstFrame()
        } else {
            self.loadPhoto()
        }
    }
    
    func requestPhotoSize(gif: Bool) -> CGSize {
        // gif 情况下优先加载一个小的缩略图
        var size = self.model.previewSize
        if gif {
            size.width /= 2
            size.height /= 2
        }
        return size
    }
    
    func loadPhoto() {
        if let editImage = self.model.editImage {
            self.imageView.image = editImage
            self.image = editImage
            self.resetSubViewSize()
        } else {
            self.imageRequestID = PhotoHelper.fetchImage(for: self.model.asset, size: self.requestPhotoSize(gif: false), progress: { [weak self] (progress, _, _, _) in
                self?.progressView.progress = progress
                if progress >= 1 {
                    self?.progressView.isHidden = true
                } else {
                    self?.progressView.isHidden = false
                }
            }, completion: { [weak self] (image, isDegraded) in
                guard self?.imageIdentifier == self?.model.ident else {
                    return
                }
                self?.imageView.image = image
                self?.image = image
                self?.resetSubViewSize()
                if !isDegraded {
                    self?.progressView.isHidden = true
                    self?.imageRequestID = PHInvalidImageRequestID
                }
            })
        }
    }
    
    func loadGifFirstFrame() {
        self.onFetchingGif = false
        
        self.imageRequestID = PhotoHelper.fetchImage(for: self.model.asset, size: self.requestPhotoSize(gif: true), completion: { [weak self] (image, isDegraded) in
            guard self?.imageIdentifier == self?.model.ident else {
                return
            }
            self?.imageView.image = image
            self?.image = image
            self?.resetSubViewSize()
        })
    }
    
    func loadGifData() {
        guard !self.onFetchingGif else {
            if self.fetchGifDone {
                self.resumeGif()
            }
            return
        }
        self.onFetchingGif = true
        self.fetchGifDone = false
        self.imageView.layer.speed = 1
        self.imageView.layer.timeOffset = 0
        self.imageView.layer.beginTime = 0
        self.gifImageRequestID = PhotoHelper.fetchOriginalImageData(for: self.model.asset, progress: { [weak self] (progress, _, _, _) in
            self?.progressView.progress = progress
            if progress >= 1 {
                self?.progressView.isHidden = true
            } else {
                self?.progressView.isHidden = false
            }
        }, completion: { [weak self] (data, _, isDegraded) in
            guard self?.imageIdentifier == self?.model.ident else {
                return
            }
            if !isDegraded {
                self?.fetchGifDone = true
                self?.imageView.image = UIImage.zl_animateGifImage(data: data)
                self?.resetSubViewSize()
            }
        })
    }
    
    func resetSubViewSize() {
        let size: CGSize
        if let _ = self.model {
            if let ei = self.model.editImage {
                size = ei.size
            } else {
                size = CGSize(width: self.model.asset.pixelWidth, height: self.model.asset.pixelHeight)
            }
        } else {
            size = self.imageView.image?.size ?? self.bounds.size
        }
        
        var frame: CGRect = .zero
        
        let viewW = self.bounds.width
        let viewH = self.bounds.height
        
        var width = viewW
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = viewH
            frame.size.height = height
            
            let imageWHRatio = size.width / size.height
            let viewWHRatio = viewW / viewH
            
            if imageWHRatio > viewWHRatio {
                frame.size.width = floor(height * imageWHRatio)
                if frame.size.width > viewW {
                    // 宽图
                    frame.size.width = viewW
                    frame.size.height = viewW / imageWHRatio
                }
            } else {
                width = floor(height * imageWHRatio)
                if width < 1 || width.isNaN {
                    width = viewW
                }
                frame.size.width = width
            }
        } else {
            frame.size.width = width
            
            let imageHWRatio = size.height / size.width
            let viewHWRatio = viewH / viewW
            
            if imageHWRatio > viewHWRatio {
                // 长图
                frame.size.width = min(size.width, viewW)
                frame.size.height = floor(frame.size.width * imageHWRatio)
            } else {
                var height = floor(frame.size.width * imageHWRatio)
                if height < 1 || height.isNaN {
                    height = viewH
                }
                frame.size.height = height
            }
        }
        
        // 优化 scroll view zoom scale
        if frame.width < frame.height {
            self.scrollView.maximumZoomScale = max(PreviewView.defaultMaxZoomScale, viewW / frame.width)
        } else {
            self.scrollView.maximumZoomScale = max(PreviewView.defaultMaxZoomScale, viewH / frame.height)
        }
        
        self.containerView.frame = frame
        
        var contenSize: CGSize = .zero
        if UIApplication.shared.statusBarOrientation.isLandscape {
            contenSize = CGSize(width: width, height: max(viewH, frame.height))
            if frame.height < viewH {
                self.containerView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            } else {
                self.containerView.frame = CGRect(origin: CGPoint(x: (viewW-frame.width)/2, y: 0), size: frame.size)
            }
        } else {
            contenSize = frame.size
            if frame.width < viewW || frame.height < viewH {
                self.containerView.center = CGPoint(x: viewW / 2, y: viewH / 2)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.scrollView.contentSize = contenSize
            self.imageView.frame = self.containerView.bounds
            self.scrollView.contentOffset = .zero
        }
    }
    
    func resumeGif() {
        guard let model = model else {
            return
        }
        guard model.type == .gif else {
            return
        }
        guard self.imageView.layer.speed != 1 else {
            return
        }
        let pauseTime = self.imageView.layer.timeOffset
        self.imageView.layer.speed = 1
        self.imageView.layer.timeOffset = 0
        self.imageView.layer.beginTime = 0
        let timeSincePause = self.imageView.layer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        self.imageView.layer.beginTime = timeSincePause
    }
    
    func pauseGif() {
        guard let model = model else {
            return
        }
        guard model.type == .gif else {
            return
        }
        guard self.imageView.layer.speed != 0 else {
            return
        }
        let pauseTime = self.imageView.layer.convertTime(CACurrentMediaTime(), from: nil)
        self.imageView.layer.speed = 0
        self.imageView.layer.timeOffset = pauseTime
    }
    
}

extension PreviewView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        self.containerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.resumeGif()
    }
    
}
