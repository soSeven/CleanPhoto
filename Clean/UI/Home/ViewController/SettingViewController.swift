//
//  SettingViewController.swift
//  Clean
//
//  Created by liqi on 2020/11/2.
//

import UIKit
import RxDataSources

protocol SettingViewControllerDelegate: AnyObject {
    func settingDidUsePassword(controller: SettingViewController)
    func settingDidChangePassword(controller: SettingViewController)
    func settingDidClickQuestion(controller: SettingViewController)
    func settingDidClickPrivacy(controller: SettingViewController)
    func settingDidClickUserProtocol(controller: SettingViewController)
}

class SettingViewController: ViewController {
    
    private var tableView: UITableView!
    
    var viewModel: SettingViewModel!
    weak var delegate: SettingViewControllerDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        let input = SettingViewModel.Input()
        let output = viewModel.transform(input: input)
        
        let datasource = RxTableViewSectionedReloadDataSource<SectionModel<String, SettingTypeModel>>(configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SettingSelectedTableCell.self)
            cell.bind(type: item)
            return cell
        })
        
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        output.items.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: {[weak self] i in
            guard let self = self else { return }
            let section = output.items.value[i.section]
            let m = section.items[i.row]
            switch m.type {
            case .changePassword:
                self.delegate?.settingDidChangePassword(controller: self)
            case .question:
                self.delegate?.settingDidClickQuestion(controller: self)
            case .privacy:
                self.delegate?.settingDidClickPrivacy(controller: self)
            case .userProtocol:
                self.delegate?.settingDidClickUserProtocol(controller: self)
            default:
                break
            }
        }).disposed(by: rx.disposeBag)
        
        output.usePassword.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.delegate?.settingDidUsePassword(controller: self)
        }).disposed(by: rx.disposeBag)
        
        output.changeTouchId.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if !UserConfigure.shared.isHasPassword {
                self.view.makeToast("请先设置密码")
                return
            }
            let (can, context) = TouchIdManager.isCanUseTouchIdOrFaceId
            if can {
                TouchIdManager.auth(completion: { s in
                    if s {
                        UserConfigure.shared.isTouchId.accept(!UserConfigure.shared.isTouchId.value)
                    } else {
                        self.view.makeToast("修改失败")
                    }
                })
            } else {
                if #available(iOS 11.0, *) {
                    if context.biometryType == .faceID {
                        self.view.makeToast("不能使用Face ID")
                        return
                    }
                }
                self.view.makeToast("不能使用Touch ID")
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        navigationItem.title = "设置"
        
        view.backgroundColor = .init(hex: "#F5F5F5")
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.5))
        tableView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.rowHeight = 53.uiX
        tableView.contentInset = .init(top: 0, left: 0, bottom: UIDevice.safeAreaBottom + 20, right: 0)
        tableView.register(cellType: SettingSelectedTableCell.self)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = .init(hex: "#F5F5F5")
            let l = UILabel()
            l.textColor = .init(hex: "#999999")
            l.text = "导入私密空间后自动删除通讯录中的联系人、照片中的照片和视频"
            l.font = .init(style: .regular, size: 12.uiX)
            view.addSubview(l)
            l.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(15.uiX)
            }
            return view
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 32.uiX
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 || section == 1 {
            let view = UIView()
            view.backgroundColor = .init(hex: "#F5F5F5")
            let l = UILabel()
            l.textColor = .init(hex: "#666666")
            l.text = section == 0 ? "导入后删除" : "私密空间"
            l.font = .init(style: .regular, size: 14.uiX)
            view.addSubview(l)
            l.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(15.uiX)
            }
            return view
        }
        
        let view = UIView()
        view.backgroundColor = .init(hex: "#F5F5F5")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 40.uiX
        }
        return 10.uiX
        
    }
}

