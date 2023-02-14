//
//  CleanListViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/27.
//

import UIKit
import RxCocoa
import RxSwift

protocol CleanListViewControllerDelegate: AnyObject {
    func cleanListDidClickItem(controller: CleanListViewController, item: Album)
}

class CleanListViewController: ViewController {
    
    weak var delegate: CleanListViewControllerDelegate?
    
    private var tableView: UITableView!
    private let deleteBtn = UIButton()
    private var emptyView1: UIView!
    
    private var deleteDisposeBag = DisposeBag()
    private let albumsRelay = BehaviorRelay<[Album]>(value: [])
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hbd_swipeBackEnabled = false
        setupUI()
        setupData()
        setupBinding()
        PhotoManager.shared.progressRelay.accept(.check)
        PhotoManager.shared.progressDisposeBag = DisposeBag()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Data
    
    private func setupData() {
        
        let snaps =  PhotoManager.shared.snapPhotoAlbum
        let similarPhoto =  PhotoManager.shared.similarPhotoAlbum
        let similarLive =  PhotoManager.shared.livePhotoAlbum
        let similarMostPhoto =  PhotoManager.shared.similarMostPhotoAlbum
        let similarVideoPhoto =  PhotoManager.shared.similarVideoAlbum
        
        let observer = Observable.combineLatest(snaps.photos.asObservable(),
                                                similarPhoto.photosAlbum.asObservable(),
                                                similarLive.photosAlbum.asObservable(),
                                                similarMostPhoto.photosAlbum.asObservable(),
                                                similarVideoPhoto.photosAlbum.asObservable())
        observer.subscribe(onNext: {[weak self] (snapsPhotos, similarPhotoAlbum, similarLiveAlbum, similarMostAlbum, similarVideoAlbum) in
            guard let self = self else { return }
            var data = [Album]()
            
            if snapsPhotos.count > 0 {
                snaps.selected.accept(true)
                data.append(snaps)
            }
            
            if similarPhotoAlbum.count > 0 {
                similarPhoto.selected.accept(true)
                data.append(similarPhoto)
            }
            
            if similarLive.photosAlbum.value.count > 0 {
                similarLive.selected.accept(true)
                data.append(similarLive)
            }
            
            if similarMostPhoto.photosAlbum.value.count > 0 {
                similarMostPhoto.selected.accept(true)
                data.append(similarMostPhoto)
            }
            
            if similarVideoPhoto.photosAlbum.value.count > 0 {
                similarVideoPhoto.selected.accept(true)
                data.append(similarVideoPhoto)
            }
            
            self.albumsRelay.accept(data)
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        
        
        albumsRelay.bind(to: tableView.rx.items(cellIdentifier: CleanListTableCell.reuseIdentifier, cellType: CleanListTableCell.self)) { (row, element, cell) in
            cell.bind(type: element)
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            let i = self.albumsRelay.value[indexPath.row]
            self.delegate?.cleanListDidClickItem(controller: self, item: i)
        }).disposed(by: rx.disposeBag)
        
        albumsRelay.subscribe(onNext: {[weak self] items in
            guard let self = self else { return }
            self.deleteDisposeBag = DisposeBag()
            if items.count == 0 {
                self.emptyView1.isHidden = false
                self.deleteBtn.rx.tap.subscribe(onNext: {[weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }).disposed(by: self.deleteDisposeBag)
            } else {
                self.emptyView1.isHidden = true
                self.deleteBtn.rx.tap.subscribe(onNext: {[weak self] in
                    guard let self = self else { return }
                    MobClick.event("clear_all")
                    var selectedPhotos = [PhotoModel]()
                    for a in self.albumsRelay.value {
                        if a.selected.value {
                            if a.type == .snapPhoto {
                                selectedPhotos.append(contentsOf: a.photos.value)
                            } else {
                                for photos in a.photosAlbum.value {
                                    var newPhotos = photos
                                    newPhotos.removeFirst()
                                    selectedPhotos.append(contentsOf: newPhotos)
                                }
                            }
                        }
                    }
                    PhotoManager.shared.delete(photos: selectedPhotos) { s in
                        
                    }
                }).disposed(by: self.deleteDisposeBag)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        view.backgroundColor = .init(hex: "#F5F5F5")
        
        let backBtn = UIButton()
        backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        backBtn.setImage(UIImage(named: "fh-icon"), for: .normal)
        backBtn.frame = .init(x: 0, y: 0, width: 40, height: 40)
        backBtn.contentHorizontalAlignment = .left
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.estimatedRowHeight = 50.uiX
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        let header = UIView(frame: .init(x: 0, y: 0, width: 0, height: 62.uiX))
        let textLbl = UILabel()
        textLbl.text = "可清理文件"
        textLbl.textColor = .init(hex: "#1A1A1A")
        textLbl.font = .init(style: .medium, size: 18.uiX)
        header.addSubview(textLbl)
        textLbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15.uiX)
        }
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = header
        tableView.contentInset = .init(top: 0, left: 0, bottom: 20.uiX + UIDevice.safeAreaBottom, right: 0)
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(cellType: CleanListTableCell.self)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteBtn.cornerRadius = 22.uiX
        deleteBtn.backgroundColor = .init(hex: "#009CFF")
        deleteBtn.setAttributedTitle(.init(string: "  删除所选", attributes: [
            .font: UIFont(style: .medium, size: 15.uiX),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ]), for: .normal)
        deleteBtn.setImage(.create("qcsy-icon"), for: .normal)
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14.uiX - UIDevice.safeAreaBottom)
            make.right.equalToSuperview().offset(-15.uiX)
            make.left.equalToSuperview().offset(15.uiX)
            make.height.equalTo(44.uiX)
        }
        
        emptyView1 = getEmptyView()
        emptyView1.isHidden = true
        view.addSubview(emptyView1)
        emptyView1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(125.uiX)
            make.centerX.equalToSuperview()
        }
    }
    
    private func getEmptyView() -> UIView {
        let v = UIView()
        let img = UIImage.create("qlcg-icon")
        let imgView = UIImageView()
        imgView.image = img
        v.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.size.equalTo(img.snpSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        let lbl1 = UILabel()
        lbl1.text = "清理成功"
        lbl1.font = .init(style: .medium, size: 16.uiX)
        lbl1.textColor = .init(hex: "#333333")
        v.addSubview(lbl1)
        lbl1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imgView.snp.bottom).offset(34.uiX)
        }
        let lbl2 = UILabel()
        lbl2.text = "当前已经没有可清除照片"
        lbl2.font = .init(style: .regular, size: 14.uiX)
        lbl2.textColor = .init(hex: "#808080")
        v.addSubview(lbl2)
        lbl2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(lbl1.snp.bottom).offset(16.uiX)
        }
        return v
    }
    
    @objc
    private func onClickBack() {
        MobClick.event("back_button")
        MobClick.event("cancel_clean_up")
        MobClick.beginEvent("prompt")
        let message = MessageAlertView()
        message.rightBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            MobClick.event("confirm_button")
            MobClick.endEvent("prompt")
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: rx.disposeBag)
        message.leftBtn.rx.tap.subscribe(onNext: {
            MobClick.endEvent("prompt")
        }).disposed(by: rx.disposeBag)
        message.show()
    }
    
}
