//
//  PhotoMangerViewController.swift
//  Clean
//
//  Created by liqi on 2020/11/4.
//

import UIKit

protocol PhotoMangerViewControllerDelegate: AnyObject {
    func photoManagerDidClickItem(controller: PhotoMangerViewController, item: Album)
}

class PhotoMangerViewController: ViewController {
    
    weak var delegate: PhotoMangerViewControllerDelegate?
    
    private var tableView: UITableView!
    private var header: PhotoManagerHeaderView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if PhotoManager.shared.needLoading {
            PhotoManager.shared.fetchAlbums()
        }
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginEvent("photo_page_stay")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endEvent("photo_page_stay")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        PhotoManager.shared.albumsRelay.bind(to: tableView.rx.items(cellIdentifier: PhotoManagerTableCell.reuseIdentifier, cellType: PhotoManagerTableCell.self)) { (row, element, cell) in
            cell.bind(type: element)
        }.disposed(by: rx.disposeBag)
        
        PhotoManager.shared.minAndMaxCreateDate.subscribe(onNext: {[weak self] (f, l) in
            guard let self = self else { return }
            if let f = f, let l = l {
                self.header.isHidden = false
                self.header.setupDate(max: (l.year, l.month), min: (f.year, f.month))
            } else {
                self.header.isHidden = true
            }
        }).disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            let i = PhotoManager.shared.albumsRelay.value[indexPath.row]
            if i.loading.value {
                return
            }
            self.delegate?.photoManagerDidClickItem(controller: self, item: i)
        }).disposed(by: rx.disposeBag)
        
        header.timeRelay.subscribe(onNext: { (min, max) in
            PhotoManager.shared.albumsRelay.value.forEach { album in
                album.timeRange.accept((min, max))
            }
        }).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        navigationItem.title = "管理照片"
        
        view.backgroundColor = .init(hex: "#F5F5F5")
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.estimatedRowHeight = 50.uiX
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        header = PhotoManagerHeaderView(frame: .init(x: 0, y: 0, width: UIDevice.screenWidth, height: 136.uiX))
        header.isHidden = true
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = header
        tableView.contentInset = .init(top: 0, left: 0, bottom: 20.uiX + UIDevice.safeAreaBottom, right: 0)
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(cellType: PhotoManagerTableCell.self)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
