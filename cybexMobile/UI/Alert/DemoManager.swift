//
//  DemoManager.swift
//  Demo
//
//  Created by DKM on 2018/6/8.
//  Copyright © 2018年 DKM. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

protocol Views {
  var content : Any? {get set}
}

class ShowManager {
  
  static let duration : TimeInterval = 1.0
  static let shared = ShowManager()
  
  var a : Constraint!
  enum ShowManagerType : String{
    case alert
    case alert_image
    //        case sheet
    case sheet_image
    case text
  }
  enum ShowAnimationType : String{
    case none
    case up_down
    case fadeIn_Out
  }
  
  private var data : Any?{
    didSet{
      showView?.content = data
    }
  }
  
  
  private var showView : (UIView & Views)?{
    didSet{
      
    }
  }
  
  private var superView : UIView?{
    didSet{
      self.shadowView = UIView.init(frame: UIScreen.main.bounds)
      if self.showType == ShowManagerType.sheet_image{
        self.shadowView?.backgroundColor = UIColor.black.withAlphaComponent(0.0)
      }else{
        self.shadowView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
      }
      superView?.addSubview(self.shadowView!)
    }
  }
  
  private var middleView : UIView?{
    didSet{
      
    }
  }
  
  private var shadowView : UIView?{
    didSet{
      
    }
  }
  
  
  private var animationShow : ShowAnimationType = .fadeIn_Out
  
  private  var showType : ShowManagerType? {
    didSet{
      
    }
  }
  
  
  private init(){
    
  }
  
  // MARK: 展示
  // 动画效果。
  func showAnimationInView(_ sender: UIView){
    self.superView          = UIApplication.shared.keyWindow
    self.superView?.addSubview(showView!)
    showView?.content       = data
    let leading : CGFloat  = showType == .sheet_image ? 0 : 52
    let trailing : CGFloat = showType == .sheet_image ? 0 : 52
    if animationShow == .none || animationShow == .fadeIn_Out{
      
      showView?.leftToSuperview(nil, offset: leading, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      
      showView?.rightToSuperview(nil, offset: trailing, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      showView?.centerXToSuperview(nil, offset: 0, priority: .required, isActive: true, usingSafeArea: true)
      showView?.centerYToSuperview(nil, offset: -64, priority: .required, isActive: true, usingSafeArea: true)
      if animationShow == .fadeIn_Out{
        showView?.alpha   = 0.0
        shadowView?.alpha = 0.0
        UIView.animate(withDuration: 2.0) {
          self.showView?.alpha   = 1.0
          self.shadowView?.alpha = 0.5
        }
      }
      return
    }else {
      let top     : CGFloat  = showType == .sheet_image ? -200 : -800
      showView?.leftToSuperview(nil, offset: leading, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      showView?.rightToSuperview(nil, offset: trailing, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      
      if showType == .sheet_image{
        a = showView?.topToSuperview(nil, offset: top, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
      }else{
        showView?.centerXToSuperview(nil, offset: 0,  priority: .required, isActive: true, usingSafeArea: true)
        a = showView?.centerYToSuperview(nil, offset: top, priority: .required, isActive: true, usingSafeArea: true)
      }
      self.superView?.layoutIfNeeded()
      if showType == .sheet_image{
        a?.constant = 0
      }else{
        a?.constant = -64
      }
      UIView.animate(withDuration: 1.5) {
        self.superView?.layoutIfNeeded()
      }
    }
  }
  
  // MARK: 隐藏
  // 动画效果。
  func hide(){
    if animationShow == .none || animationShow == .fadeIn_Out{
      if animationShow == .fadeIn_Out{
        showView?.alpha   = 1.0
        shadowView?.alpha = 0.0
        UIView.animate(withDuration: 2.0) {
          self.showView?.alpha   = 1.0
          self.shadowView?.alpha = 0.5
        }
      }
    }
  }
  func hide(_ time : TimeInterval){
    if animationShow == .none{
      UIView.animate(withDuration: 0.1, delay: time, options: UIViewAnimationOptions.curveLinear, animations: {
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
      }) { (isFinished) in
      }
    }else if animationShow == .fadeIn_Out {
      UIView.animate(withDuration: 0.5, delay: time, options: UIViewAnimationOptions.curveLinear, animations: {
        self.showView?.alpha   = 0.0
        self.shadowView?.alpha = 0.0
      }) { (isFinished) in
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
      }
    }else{
      a.constant = showType == .sheet_image ? -200 : -800
      UIView.animate(withDuration: 1, delay: time, options: .curveLinear, animations: {
        self.superView?.layoutIfNeeded()
      }) { (isFinished) in
        self.showView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
      }
      
    }
  }
  
  func setUp(title:String,message:String,animationType:ShowAnimationType,showType:ShowManagerType = .alert){
    self.data          = ["title":title,"message":message]
    self.animationShow = animationType
    self.showType      = showType
    
    self.setupAlert()
  }
  
  
  func setUp(title_image:String,message:String,animationType:ShowAnimationType,showType:ShowManagerType){
    self.data          = ["title_image":title_image,"message":message]
    self.animationShow = animationType
    self.showType      = showType
    if showType == .alert_image{
      self.setupAlertImage()
    }else if showType == .sheet_image{
      self.setupSheetImage()
    }
  }
  
  
  // warning: 待完善
  func setUp(title:String,contentView:(UIView&Views),animationType:ShowAnimationType){
    self.animationShow  = animationType
    
    self.setupText(contentView,title: title)
  }
  
  
  fileprivate func setupAlert(){
    let alertView            = CybexAlertView(frame: CGRect.zero)
    alertView.isShowImage    = false
    showView                 = alertView
  }
  
  fileprivate func setupAlertImage(){
    let alertView            = CybexAlertView(frame: CGRect.zero)
    alertView.isShowImage    = true
    showView                 = alertView
  }
  
  fileprivate func setupSheetImage(){
    let sheetView = CybexActionView(frame: .zero)
    showView     = sheetView
  }
  fileprivate func setupText(_ sender:(UIView&Views),title:String){
    let textView = CybexTextView(frame: .zero)
    textView.middleView = sender
    textView.title.text = title
    showView     = textView
  }
}
