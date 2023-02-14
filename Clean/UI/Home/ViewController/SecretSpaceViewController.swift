//
//  SecretSpaceViewController.swift
//  Clean
//
//  Created by liqi on 2020/10/29.
//

import RxCocoa
import RxSwift

protocol SecretSpaceViewControllerDelegate: AnyObject {
    func secretSpaceDidClickItem(controller: SecretSpaceViewController, item: SecretType)
}

class SecretSpaceViewController: ViewController {
    
    weak var delegate: SecretSpaceViewControllerDelegate?
    
    private var tableView: UITableView!
    private var isForeground = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        NotificationCenter.default.addObserver(self, selector: #selector(enterToBackground), name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(enterToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginEvent("private_space_time")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endEvent("private_space_time")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification
    
    @objc
    private func enterToBackground(no: Notification) {
        isForeground = false
        if UserConfigure.shared.isHasPassword, !PasswordPopView.isExist, !PhotoManager.shared.isDeleteing {
            let p = PasswordPopView()
            p.show()
        }
        print("willResignActiveNotification")
    }
    
    @objc
    private func enterToForeground() {
        isForeground = true
        print("didEnterBackgroundNotification")
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        let types: [SecretType] = [.photos]
        Observable<[SecretType]>.just(types).bind(to: tableView.rx.items(cellIdentifier: SecretTypeTableCell.reuseIdentifier, cellType: SecretTypeTableCell.self)) { (row, element, cell) in
            cell.bind(type: element)
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] indexPath in
            guard let self = self else { return }
            let item = types[indexPath.row]
            self.delegate?.secretSpaceDidClickItem(controller: self, item: item)
        }).disposed(by: rx.disposeBag)
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        navigationItem.title = "私密空间"
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.estimatedRowHeight = 50.uiX
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.contentInset = .init(top: 10.uiX, left: 0, bottom: 0, right: 0)
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(cellType: SecretTypeTableCell.self)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
