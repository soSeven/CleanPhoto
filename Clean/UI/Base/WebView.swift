//
//  WebView.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/26.
//  Copyright © 2020 Qire. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import WebKit

final class WebViewController: ViewController {

    // MARK: - Fields

    private var webView: WKWebView?

    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .init(hex: "#1AAB97")
        progressView.trackTintColor = .clear
        return progressView
    }()

    private var disposeBag = DisposeBag()

    var url: URL?
    var needGoBack = false
    
    // MARK: - Lifecycle

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)

        webView.allowsBackForwardNavigationGestures = true
        webView.isMultipleTouchEnabled = true

        view = webView
        self.webView = webView
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let navigationController = navigationController else {
            return
        }
        progressView.frame = CGRect(x: 0, y: navigationController.navigationBar.frame.size.height - progressView.frame.size.height, width: navigationController.navigationBar.frame.size.width, height: progressView.frame.size.height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBinding()
        setupData()
    }

    // MARK: - Setup

    private func setupUI() {
        if navigationController?.viewControllers.count ?? 0 <= 1 {
            navigationItem.leftBarButtonItem = nil
        }
        navigationController?.navigationBar.addSubview(progressView)
    }

    private func setupData() {
        if let url = url {
            load(url)
        }
    }

    private func setupBinding() {

        guard let webView = webView else {
            return
        }
        if needGoBack {
            webView.rx.canGoBack.bind {[weak self] canGoBack in
                guard let self = self else { return }
                if canGoBack {
                    let backBtn = UIButton()
                    backBtn.rx.tap.subscribe(onNext: {[weak self] _ in
                        guard let self = self else { return }
                        self.webView?.goBack()
                    }).disposed(by: backBtn.rx.disposeBag)
                    backBtn.setImage(UIImage(named: "setting_img_return"), for: .normal)
                    backBtn.frame = .init(x: 0, y: 0, width: 40, height: 40)
                    backBtn.contentHorizontalAlignment = .left
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
                } else {
                    self.navigationItem.leftBarButtonItem = nil
                }
            }.disposed(by: disposeBag)
        }
        webView.rx.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        webView.rx.estimatedProgress.bind { [weak self] estimatedProgress in
            self?.progressView.alpha = 1
            self?.progressView.setProgress(Float(estimatedProgress), animated: true)

            if estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: { [weak self] in
                    self?.progressView.alpha = 0
                    }, completion: { [weak self] _ in
                        self?.progressView.setProgress(0, animated: false)
                })
            }
        }.disposed(by: disposeBag)
        webView.rx.didFailLoad.bind { (navigation, error) in
            print(error)
        }.disposed(by: disposeBag)
        webView.rx.didFinishLoad.bind { (navigation) in
            print("..... success ....")
        }.disposed(by: disposeBag)
    }

    private func load(_ url: URL) {
        guard let webView = webView else {
            return
        }
        let request = URLRequest(url: url)
        DispatchQueue.main.async {
            webView.load(request)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
