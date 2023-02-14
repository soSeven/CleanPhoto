//
//  MBProgressHUD+Rx.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/17.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MBProgressHUD

fileprivate class MbHudCustomView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return .init(width: width, height: height)
    }
}

extension Reactive where Base: UIView {
    
    var mbHudImageText: Binder<String> {
        
        return Binder(self.base) {v, text in
            let hud = MBProgressHUD.showAdded(to: v, animated: true)
            hud.mode = .customView
            let imgView = UIImageView(image: UIImage.create("toast_cryface"))
            imgView.sizeToFit()
            let v = MbHudCustomView()
            v.frame = .init(x: 0, y: 0, width: imgView.width, height: imgView.height + 12.uiX)
            v.addSubview(imgView)
            hud.label.font = .init(style: .regular, size: 14.uiX)
            hud.customView = v
            hud.label.text = text
            hud.bezelView.style = .solidColor
            hud.bezelView.color = .init(white: 0, alpha: 0.8)
            hud.contentColor = .white
            hud.hide(animated: true, afterDelay: 2)
        }
        
    }
    
    var mbHudText: Binder<String> {
        
        return Binder(self.base) {v, text in
            let hud = MBProgressHUD.showAdded(to: v, animated: true)
            hud.mode = .text
            hud.label.font = .init(style: .regular, size: 14.uiX)
            hud.label.text = text
            hud.bezelView.style = .solidColor
            hud.bezelView.color = .init(white: 0, alpha: 0.8)
            hud.contentColor = .white
            hud.hide(animated: true, afterDelay: 2)
        }
        
    }
    
    func mbHudText(completion: @escaping () -> ()) -> Binder<String> {
        
        return Binder(self.base) {v, text in
            let hud = MBProgressHUD.showAdded(to: v, animated: true)
            hud.mode = .text
            hud.label.text = text
            hud.bezelView.style = .solidColor
            hud.bezelView.color = .init(white: 0, alpha: 0.8)
            hud.contentColor = .white
            hud.hide(animated: true, afterDelay: 1.5)
            hud.completionBlock = completion
        }
        
    }
    
    var mbHudLoaing: Binder<Bool> {
        
        return Binder(self.base) { v, hidden in
            
            if hidden {
                let mb = MBProgressHUD.showAdded(to: v, animated: true)
                mb.bezelView.style = .solidColor
                mb.bezelView.color = .clear//[UIColor colorWithWhite:0.8f alpha:0.6f]
                mb.contentColor = .gray
                mb.tag = -111111
            } else {
                for sub in v.subviews {
                    if let mb = sub as? MBProgressHUD, mb.tag == -111111 {
                        mb.hide(animated: true)
                        break
                    }
                }
            }
        }
    }
    
    var mbHudLoaingForce: Binder<Bool> {
        
        return Binder(self.base) { v, hidden in
      
            if hidden {
                v.window?.isUserInteractionEnabled = false
                let mb = MBProgressHUD.showAdded(to: v, animated: true)
                mb.bezelView.style = .solidColor
                mb.bezelView.color = .clear//[UIColor colorWithWhite:0.8f alpha:0.6f]
                mb.contentColor = .gray
                mb.tag = -111111
                mb.completionBlock = {
                    v.window?.isUserInteractionEnabled = true
                }
            } else {
                for sub in v.subviews {
                    if let mb = sub as? MBProgressHUD, mb.tag == -111111 {
                        mb.hide(animated: true)
                        break
                    }
                }
            }
        }
    }
    
}

