//
//  HomeViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/26.
//

import UIKit
import RxCocoa
import RxSwift

protocol HomeViewControllerDelegate: AnyObject {
    func homeDidClickVIP(controller: HomeViewController)
    func homeDidClickClean(controller: HomeViewController)
    func homeDidClickSetting(controller: HomeViewController)
    func homeDidClickItem(controller: HomeViewController, item: HomeType)
}

class HomeViewController: ViewController {
    
    var viewModel: HomeViewModel!
    weak var delegate: HomeViewControllerDelegate?
    
    private var tableView: UITableView!
    private var wave: WaveView!
    private var progressView: ProgressView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginEvent("home_time")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endEvent("home_time")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        let input = HomeViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.items.bind(to: tableView.rx.items(cellIdentifier: HomeTypeTableCell.reuseIdentifier, cellType: HomeTypeTableCell.self)) { (row, element, cell) in
            cell.bind(type: element)
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let self = self else { return }
            guard  let u = UserManager.shared.user, u.isVip else {
                self.delegate?.homeDidClickVIP(controller: self)
                return
            }
            PhotoManager.shared.checkPermissionToAccessPhotoLibrary {[weak self] auth in
                guard let self = self else { return }
                if auth {
                    let item = output.items.value[indexPath.row]
                    self.delegate?.homeDidClickItem(controller: self, item: item)
                }
            }
        }).disposed(by: rx.disposeBag)
        
        progressView.cleanBlock = { [weak self] in
            guard let self = self else { return }
            
            MobClick.event("clean_click")
            
            self.delegate?.homeDidClickClean(controller: self)
        }
        
        progressView.checkBlock = { [weak self] in
            guard let self = self else { return }
            
            MobClick.event("scan_click")
            
            guard  let u = UserManager.shared.user, u.isVip else {
                self.delegate?.homeDidClickVIP(controller: self)
                return
            }
            
            PhotoManager.shared.checkPermissionToAccessPhotoLibrary {[weak self] auth in
                guard let self = self else { return }
                if auth {
                    PhotoManager.shared.progressDisposeBag = DisposeBag()
                    PhotoManager.shared.progressRelay.subscribe(onNext: {[weak self] type in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.progressView.setupProgress(type: type)
                        }
                    }).disposed(by: PhotoManager.shared.progressDisposeBag)
                    PhotoManager.shared.fetchAlbums()
                }
            }
        }
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .init(hex: "#F5F5F5")
        setupNavigation()
        setupHeader()
    }
    
    private func setupNavigation() {
        hbd_barAlpha = 0
        
        let rightImg = UIImage.create("sz-icon")
        let right = MusicButton()
        right.size = rightImg.snpSize
        right.setBackgroundImage(rightImg, for: .normal)
        right.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.delegate?.homeDidClickSetting(controller: self)
        }).disposed(by: rx.disposeBag)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: right)
        
        let leftTitleAtt: [NSAttributedString.Key : Any] = [
            .font: UIFont(style: .medium, size: 13.uiX),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ]
        let leftImg = UIImage.create("sjvip-icon")
        let left = UIButton()
        left.size = leftImg.snpSize
        left.titleEdgeInsets = .init(top: 0, left: 26.uiX, bottom: 2.uiX, right: 0)
        left.setBackgroundImage(leftImg, for: .normal)
        left.setAttributedTitle(.init(string: "升级VIP", attributes: leftTitleAtt), for: .normal)
        left.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            MobClick.event("click_vip")
            self.delegate?.homeDidClickVIP(controller: self)
        }).disposed(by: rx.disposeBag)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: left)
        
    }
    
    private func setupHeader() {
        let bgView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: 346.5.uiX + UIDevice.statusBarHeight)
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [
            UIColor(hex: "#44B2F1").cgColor,
            UIColor(hex: "#55DBD8").cgColor,
            UIColor(hex: "#F5F5F5").cgColor
        ]
        bgGradient.locations = [0, 0.67, 1]
        bgGradient.startPoint = CGPoint(x: 0.0, y: 0)
        bgGradient.endPoint = CGPoint(x: 0, y: 1)
        bgGradient.frame = bgView.bounds
        bgView.layer.addSublayer(bgGradient)
        view.addSubview(bgView)
        
        let waveViewHeight: CGFloat = 137.uiX
        let waveY = 248.uiX + UIDevice.statusBarHeight
        wave = WaveView(frame: .init(x: 0, y: waveY, width: bgView.width, height: waveViewHeight))
        
        let w1 = WaveLayer()
        w1.offsetScale = 0
        w1.height = 40.uiX
        w1.waveDeepHeight = wave.height - w1.height
        w1.fillColor = UIColor.blue.cgColor
        
        let w2 = WaveLayer()
        w2.offsetScale = 1
        w2.height = 40.uiX
        w2.waveDeepHeight = wave.height - w2.height
        w2.fillColor = UIColor.red.cgColor
        
        wave.add(wave: w1)
        wave.add(wave: w2)
        
        view.addSubview(wave)
        
        let progressW = 220.uiX
        let progressH = 220.uiX
        let progressX = (UIDevice.screenWidth - progressW)/2.0
        let progressY = 34.uiX + UIDevice.statusBarHeight
        progressView = ProgressView(frame: .init(x: progressX, y: progressY, width: progressW, height: progressH))
        view.addSubview(progressView)
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.estimatedRowHeight = 50.uiX
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.isScrollEnabled = false
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(cellType: HomeTypeTableCell.self)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(297.uiX + UIDevice.statusBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
}
