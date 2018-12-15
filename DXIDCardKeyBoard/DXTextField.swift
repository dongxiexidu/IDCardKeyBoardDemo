//
//  DXTextField.swift
//  IDCardKeyBoardDemo
//
//  Created by fashion on 2018/12/15.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

private let kScreenH : CGFloat = UIScreen.main.bounds.size.height
private let kScreenW : CGFloat = UIScreen.main.bounds.size.width
// 是否为iPhoneX iPhoneX Max iPhoneXR
private let iPhoneX_M_R : Bool = kScreenH >= 812
private let DXDangerousAreaH : CGFloat = 34


class DXTextField: UITextField {
    /// 是否使用了键盘头部工具条，调整了键盘的高度
    public var adjustTextFeildH : Bool = false
    
    /// X按钮
    private var doneButton : UIButton?
    private var isWillShowKeyboard : Bool = false
    private var isDisplayingKeyboard : Bool = false
    private var notification : Notification?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        didInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        didInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func didInit() {
        self.keyboardType = .numberPad
        
        let noti = NotificationCenter.default
        noti.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        noti.addObserver(self, selector: #selector(textFieldDidBeginEditing(notification:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        noti.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        noti.addObserver(self, selector: #selector(textFieldDidEndEditing(notification:)), name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:设置X 按钮
    private func setupDoneKey() {
        if isWillShowKeyboard == false {
            isDisplayingKeyboard = true
            return
        }
        self.doneButton?.removeFromSuperview()
        self.doneButton = nil

        guard let notifi = notification else { return }
        guard let userInfo = notifi.userInfo else { return }
        
         // 键盘的Frame
        let keyBoardFrame : CGRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        var kbHeight : CGFloat = keyBoardFrame.size.height
        
        // 这里因为用了第三方的键盘顶部，所有加了44
        if adjustTextFeildH {
            kbHeight = keyBoardFrame.size.height - 44
        }
        
        let doneBtnX : CGFloat = 0
        var doneBtnY : CGFloat = 0
        var doneBtnW : CGFloat = 0
        var doneBtnH : CGFloat = 0
        // 为了适配不同屏幕
        if kScreenW == 320 {// 5
            doneBtnW = (kScreenW - 6) / 3
            doneBtnH = (kbHeight - 2) / 4
        } else if kScreenW == 375 {// 6
            doneBtnW = (kScreenW - 8) / 3
            doneBtnH = (kbHeight - 2) / 4
        } else if kScreenW == 414 { // 6p
            doneBtnW = (kScreenW - 7) / 3
            doneBtnH = kbHeight / 4
        } else {
            
        }
        
        if isDisplayingKeyboard == true {
            doneBtnY = kScreenH - doneBtnH
        } else {
            doneBtnY = kScreenH - doneBtnH + kbHeight
        }
        
        if iPhoneX_M_R {
            doneBtnH = (kbHeight - 75 - 2) / 4
            if isDisplayingKeyboard == true {
                doneBtnY = kScreenH - doneBtnH
            } else {
                doneBtnY = kScreenH - doneBtnH + kbHeight
            }
            doneBtnY -= 75
        }
        let button = UIButton.init(frame: CGRect.init(x: doneBtnX, y: doneBtnY, width: doneBtnW, height: doneBtnH))
        button.setTitle("X", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(doneButtonClick(button:)), for: UIControl.Event.touchUpInside)
        if #available(iOS 11, *) {
            button.alpha = 0
            UIView.animate(withDuration: 0.1) {
                button.alpha = 1
            }
        }else{
            button.setBackgroundImage(UIImage.dx_createImage(color: UIColor.white), for: UIControl.State.highlighted)
        }
        self.doneButton = button
        
        // 获取到最上层的window
        var topWindow = UIApplication.shared.windows.first
        if #available(iOS 9.0, *) {
            topWindow = UIApplication.shared.windows.last
        }
        // 添加按钮
        topWindow?.addSubview(button)
        
        // 动画的轨迹
        let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve.RawValue

        // 动画时间
        let animationDuration : TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        if self.isDisplayingKeyboard == false {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(animationDuration)
            if let curve = animationCurve {
                UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: curve)!)
            }
            button.transform = button.transform.translatedBy(x: 0, y: -kbHeight)
            UIView.commitAnimations()
        }
        self.isDisplayingKeyboard = true
    }
    // 完成按钮点击
    @objc func doneButtonClick(button : UIButton) {
        guard let selectedRange = selectedRange() else { return }
        // 获得光标所在的位置
        let insertIndex = selectedRange.location
        if let myDelegate = delegate  {
            let isAllowChange = myDelegate.textField!(self, shouldChangeCharactersIn: NSRange.init(location: insertIndex, length: 0), replacementString: button.currentTitle!)
            if isAllowChange == false{
                return
            }
        }
        if let tempText = self.text {
            let stringMut = NSMutableString.init(string: tempText)
            stringMut.replaceCharacters(in: selectedRange, with: button.currentTitle!)
            // 重新赋值
            self.text = stringMut as String
        }
        // 让光标回到插入文字后面
        setSelectedRange(range: NSRange.init(location: insertIndex+1, length: 0))
        UIDevice.current.playInputClick()
    }
    
}

// MARK: assitant
extension UIImage {
    // 用颜色返回一张图片
    public class func dx_createImage(color: UIColor) -> UIImage? {
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

// MARK: Notifications
extension DXTextField {
    
    @objc private func keyboardWillShow(notification : Notification) {
        if self.keyboardType != .numberPad {
            return
        }
        // 获取到最上层的window
        var topWindow = UIApplication.shared.windows.first

        if #available(iOS 9.0, *) {
            topWindow = UIApplication.shared.windows.last
        }
        guard let tempWindow = topWindow else {
            print("未获取到窗口")
            return
        }
        
        // 通过图层查看系统的键盘有UIKeyboardAutomatic这个View，第三方的对应位置的view为_UISizeTrackingView
        if #available(iOS 8.0, *) {
            let foundView = UIView.dx_foundView(view: tempWindow, className: "UIKeyboardAutomatic")
            if foundView == nil{
                return
            }
        }
        self.notification = notification
        setupDoneKey()
    }
    
    
    @objc private func textFieldDidBeginEditing(notification : Notification) {
        if self.keyboardType != .numberPad {
            return
        }
        // FIXME:使用了运行时获取对象类型
        let aClass = object_getClass(notification.object)
        let name = String(describing: aClass)
        self.isWillShowKeyboard = ("Optional(UITextField)" != name)
     
        if isWillShowKeyboard {
            if #available(iOS 11, *) {
                if self.notification != nil {
                    setupDoneKey()
                }
            }
            if Double(UIDevice.current.systemVersion)! < 9.0 {
                if self.notification != nil {
                    setupDoneKey()
                }
            }
        }

    }
    
    @objc private func keyboardWillHide(notification : Notification) {
        if self.keyboardType != .numberPad {
            return
        }
        self.isDisplayingKeyboard = false
        self.notification = nil
    }
    @objc private func textFieldDidEndEditing(notification : Notification) {
        if self.keyboardType != .numberPad {
            return
        }
        self.isWillShowKeyboard = false

        let animationDuration : TimeInterval = 0.25
        let animationCurve = UIView.AnimationCurve.init(rawValue: 0)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve!)
        if let button = doneButton {
            button.transform = CGAffineTransform.identity
            button.removeFromSuperview()
        }
        UIView.commitAnimations()
    }
}

extension UITextField {
    
    public func selectedRange() -> NSRange? {
        let begin : UITextPosition = self.beginningOfDocument
        // 内容为[start,end)，无论是否有选取区域，start都描述了光标的位置
        guard let selectedRange : UITextRange = self.selectedTextRange else { return nil }
        
        let selectionStart : UITextPosition = selectedRange.start
        let selectionEnd : UITextPosition = selectedRange.end
        
        // 获取以from为基准的to的偏移
        let location = self.offset(from: begin, to: selectionStart)
        let length = self.offset(from: selectionStart, to: selectionEnd)
        return NSRange.init(location: location, length: length)
    }
    
    public func setSelectedRange(range: NSRange) {
        
        let begin : UITextPosition = self.beginningOfDocument
        guard let startPosition = self.position(from: begin, offset: range.location) else { return }
        guard let endPosition = self.position(from: begin, offset: range.location + range.length) else { return }
        // 创建一个UITextRange
        guard let selectionRange = textRange(from: startPosition, to: endPosition) else { return }
        self.selectedTextRange = selectionRange
    }
}

extension UIView {
    // 使用了递归输出所有子控件
    public class func dx_foundView(view: UIView, className: String) -> UIView? {

        if let tmpClass = NSClassFromString(className) {
            // 递归出口
            if view.isKind(of: tmpClass) {
                return view
            }
            
            for subView in view.subviews {
                let foundView = dx_foundView(view: subView, className: className)
                if foundView != nil {
                    return foundView
                }
            }
        }
        
        return nil
    }
}
