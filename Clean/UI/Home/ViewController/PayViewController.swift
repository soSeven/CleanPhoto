//
//  PayViewController.swift
//  Clean
//
//  Created by liqi on 2020/11/10.
//

import UIKit
import RxCocoa
import RxSwift
import YYText

protocol PayViewControllerDelegate: AnyObject {
    func payShowProtocol(controller: PayViewController, type: NetHtmlAPI)
}

class PayViewController: ViewController {
    
    var viewModel: PayViewModel!
    
    weak var delegate: PayViewControllerDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 109.uiX, height: 80.uiX)
        layout.minimumLineSpacing = 15.uiX
        layout.minimumInteritemSpacing = 2.uiX
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 36.uiX, left: 15.uiX, bottom: 0, right: 15.uiX)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(cellType: PayListCell.self)
        
        return collectionView
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let retryBtn = UIButton()
    private let buyBtn = UIButton()
    private let priceLbl = UILabel()
    
    private var currentIndex = 0
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hbd_barHidden = true
        setupUI()
        setupBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.roundCorners([.topLeft, .topRight], radius: 15.uiX)
    }
    
    // MARK: - Binding
    
    private func setupBinding() {
        
        let buy = PublishRelay<String>()
        let restore = PublishRelay<Void>()
        
        let input = PayViewModel.Input(request: Observable.just(()), buy: buy.asObservable(), restore: restore.asObservable())
        let output = viewModel.transform(input: input)
        
        output.items.bind(to: collectionView.rx.items(cellIdentifier: PayListCell.reuseIdentifier, cellType: PayListCell.self)) { (row, element, cell) in
            cell.bind(to: element, selected: row == self.currentIndex)
        }.disposed(by: rx.disposeBag)
        
        output.items.subscribe(onNext: {[weak self] items in
            guard let self = self else { return }
            if items.count <= self.currentIndex {
                return
            }
            let i = items[self.currentIndex]
            self.priceLbl.text = i.description
        }).disposed(by: rx.disposeBag)
        
        let completion = {[weak self] in
            guard let self = self else { return }
            MobClick.event("successfully_subscribed")
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        output.buySuccess.bind(to: view.rx.mbHudText(completion: completion)).disposed(by: rx.disposeBag)

        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            let i = output.items.value[index.row]
            self.currentIndex = index.row
            self.priceLbl.text = i.description
            self.collectionView.reloadData()
            MobClick.event("card_recharge", attributes: [
                "type": i.name ?? "unKnown"
            ])
        }).disposed(by: rx.disposeBag)
        
        buyBtn.rx.tap.subscribe(onNext: {[weak self]  _ in
            guard let self = self else { return }
            MobClick.event("subscribe_button")
            if output.items.value.count <= self.currentIndex {
                return
            }
            let i = output.items.value[self.currentIndex]
            buy.accept(i.id)
        }).disposed(by: rx.disposeBag)
        
        retryBtn.rx.tap.subscribe(onNext: { _ in
            MobClick.event("restore_purchase")
            restore.accept(())
        }).disposed(by: rx.disposeBag)
        
        viewModel.parsedError.asObserver().bind(to: view.rx.toastError).disposed(by: rx.disposeBag)
        viewModel.loading.asObservable().bind(to: view.rx.mbHudLoaing).disposed(by: rx.disposeBag)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        let bgImg = UIImage.create("VIP-bj")
        let bgImgView = UIImageView()
        bgImgView.image = bgImg
        view.addSubview(bgImgView)
        bgImgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bgImgView.snp.width).multipliedBy(bgImg.snpScale)
        }
        
        let iconImgView = UIImageView()
        iconImgView.image = .create("app-icon")
        iconImgView.borderColor = .init(hex: "#F2CC89")
        iconImgView.borderWidth = 2.5.uiX
        iconImgView.cornerRadius = 10.uiX
        bgImgView.addSubview(iconImgView)
        iconImgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(62.5.uiX)
            make.height.equalTo(62.5.uiX)
        }
        
        let iconLbl = UILabel()
        iconLbl.text = "极速清理大师"
        iconLbl.textColor = .init(hex: "#F2CC89")
        iconLbl.font = .init(style: .medium, size: 15.uiX)
        bgImgView.addSubview(iconLbl)
        iconLbl.snp.makeConstraints { make in
            make.top.equalTo(iconImgView.snp.bottom).offset(12.uiX)
            make.centerX.equalToSuperview()
        }
        
        let closeImg = UIImage.create("vip-gb")
        let closeBtn = MusicButton()
        closeBtn.setBackgroundImage(closeImg, for: .normal)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIDevice.safeAreaBottom + 20.uiX)
            make.right.equalToSuperview().offset(-15.uiX)
            make.size.equalTo(closeImg.snpSize)
        }
        closeBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(bgImgView.snp.bottom).offset(-36.uiX)
        }
        
        contentView.backgroundColor = .white
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(220.uiX)
        }
        
        priceLbl.textColor = .init(hex: "#886C49")
        priceLbl.font = .init(style: .regular, size: 13.uiX)
        contentView.addSubview(priceLbl)
        priceLbl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(30.uiX)
            make.centerX.equalToSuperview()
        }
        
        let buyatt: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .medium, size: 17.uiX),
            .foregroundColor: UIColor(hex: "#986406"),
        ]
        let buyImg = UIImage.create("buy-icon")
        buyBtn.titleEdgeInsets = .init(top: 0, left: 0, bottom: 10.uiX, right: 0)
        buyBtn.setAttributedTitle(.init(string: "立即购买", attributes: buyatt), for: .normal)
        buyBtn.setBackgroundImage(buyImg, for: .normal)
        contentView.addSubview(buyBtn)
        buyBtn.snp.makeConstraints { make in
            make.top.equalTo(priceLbl.snp.bottom).offset(10.uiX)
            make.centerX.equalToSuperview()
            make.size.equalTo(buyImg.snpSize)
        }
        
        let retryatt: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 13.uiX),
            .foregroundColor: UIColor(hex: "#886C49"),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(hex: "#886C49")
        ]
        retryBtn.setAttributedTitle(.init(string: "恢复购买", attributes: retryatt), for: .normal)
        contentView.addSubview(retryBtn)
        retryBtn.snp.makeConstraints { make in
            make.top.equalTo(buyBtn.snp.bottom).offset(5.uiX)
            make.right.equalToSuperview().offset(-15.uiX)
        }
        
        let att = NSMutableAttributedString(string: "自动续期服务：1.免费试用：专业版免费试用3天，试用结束按季度订阅，用户可以在试用期间随时取消。2.订阅会员自动续期，在服务到期前24小时自动续订服务并通过iTunes账户扣除相应费用，同时延长专业版高级服务相应的有效期。3.如需停止自动续期服务，请在下个账单日期之前在 App Store账户设置页，点击“订阅”取消对应服务。")
        att.yy_lineSpacing = 3.uiX
        att.yy_color = .init(hex: "#A79D8F")
        att.yy_font = .init(style: .regular, size: 11.uiX)
        let lbl = UILabel()
        lbl.attributedText = att
        lbl.numberOfLines = 0
        contentView.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.uiX)
            make.right.equalToSuperview().offset(-15.uiX)
            make.top.equalTo(retryBtn.snp.bottom).offset(11.uiX)
        }
        
        let proto = getProtocolView()
        contentView.addSubview(proto)
        proto.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.uiX)
            make.right.equalToSuperview().offset(-15.uiX)
            make.top.equalTo(lbl.snp.bottom).offset(8.uiX)
            make.bottom.equalToSuperview().offset(-20.uiX)
        }
    }
    
    private func getProtocolView() -> UIView {
        
        let text = NSMutableAttributedString(string: "")
        text.yy_font = .init(style: .regular, size: 11.uiX)
        text.yy_color = .init(hex: "#886C49")
        
        let a = NSMutableAttributedString(string: "自动续期服务声明")
        a.yy_font = .init(style: .regular, size: 11.uiX)
        a.yy_color = .init(hex: "#886C49")
        a.yy_underlineColor = .init(hex: "#886C49")
        a.yy_underlineStyle = .single
        
        let hi = YYTextHighlight()
        hi.tapAction =  { [weak self] containerView, text, range, rect in
            guard let self = self else { return }
            self.delegate?.payShowProtocol(controller: self, type: .userProtocol)
        };
        a.yy_setTextHighlight(hi, range: a.yy_rangeOfAll())
        
        let b = NSMutableAttributedString(string: "和")
        b.yy_font = .init(style: .regular, size: 11.uiX)
        b.yy_color = .init(hex: "#886C49")
        
        let c = NSMutableAttributedString(string: "隐私政策")
        c.yy_font = .init(style: .regular, size: 11.uiX)
        c.yy_color = .init(hex: "#886C49")
        c.yy_underlineColor = .init(hex: "#886C49")
        c.yy_underlineStyle = .single
        
        let chi = YYTextHighlight()
        chi.tapAction = { [weak self] containerView, text, range, rect in
            guard let self = self else { return }
            self.delegate?.payShowProtocol(controller: self, type: .privacy)
        };
        c.yy_setTextHighlight(chi, range: c.yy_rangeOfAll())
        
        text.append(a)
        text.append(b)
        text.append(c)
        
        let protocolLbl = YYLabel()
        protocolLbl.attributedText = text;
        
        return protocolLbl
    }
    
    
    
}
