//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Updated/Modernized by C. Bess on 9/18/19.
//
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: AnyObject {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar, sender: AnyObject)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar, sender: AnyObject)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

fileprivate func pinViewEdges(of childView: UIView, to parentView: UIView) {
    NSLayoutConstraint.activate([
        childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
        childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
        childView.topAnchor.constraint(equalTo: parentView.topAnchor),
        childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
    ])
}

private let DefaultFont = UIFont.preferredFont(forTextStyle: .body)

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }
    
    open var subOptions: [RichEditorOption] = [] {
        didSet {
            updateSubToolbar()
        }
    }
    
    open var isKeyboardHiddenButtonShow: Bool = false {
        didSet {
            resignButton.isHidden = !isKeyboardHiddenButtonShow
        }
    }
    
    private let colors: [UIColor] = [
        .init(rgb: 0x41a85f),
        .init(rgb: 0x3d8eb9),
        .init(rgb: 0x2969b0),
        .init(rgb: 0x553982),
        .init(rgb: 0x28324e),
        .init(rgb: 0x000000),
        .init(rgb: 0xffffff),
        .init(rgb: 0xfac51c),
        .init(rgb: 0xf37934),
        .init(rgb: 0xd14841),
        .init(rgb: 0xb8312f),
        .init(rgb: 0x7c706b),
        .init(rgb: 0xd1d5d8),
    ]
    
    private let sizeOptions = RichEditorDefaultOption.textSize
    
    private var mainButtons: [UIButton] = []
    
    private var mainView: UIView!
    private var mainStackView: UIStackView!
    
    // 서체 편집
    private var menuView: UIView!
    private var menuStackView: UIStackView!
    
    // 서체편집 선택 > 텍스트 걸러 선택
    private var textColorScrollView: UIScrollView!
    
    // 서체편집 선택 > 텍스트 크기 선택
    private var sizeScrollView: UIScrollView!
    
    // 전체 크기
    private var maxHeightConstraint: NSLayoutConstraint?
    private var minHeightConstraint: NSLayoutConstraint?
    
    /// 서체 편집 열기/닫기
    private var isSubMenuOpen: Bool = false
    
    /// 키보드 내림 버튼
    private var resignButton: UIButton!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    private func initViews() {
        backgroundColor = .white
        
        translatesAutoresizingMaskIntoConstraints = true
        maxHeightConstraint = heightAnchor.constraint(equalToConstant: 96)
        maxHeightConstraint?.isActive = false
        minHeightConstraint = heightAnchor.constraint(equalToConstant: 48)
        minHeightConstraint?.isActive = true
        
        // 메인 뷰
        mainView = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        addSubview(mainView)
        
        // 메인 메뉴
        mainStackView = UIStackView(frame: .init(x: 12, y: 0, width: 168, height: 48))
        mainView.addSubview(mainStackView)
        mainStackView.spacing = 2
        mainStackView.distribution = .fillEqually
        mainStackView.axis = .horizontal
        
        
        let divider = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        mainView.addSubview(divider)
        divider.backgroundColor = .init(rgb: 0xf2f2f2)
        
        // 키보드 내림 버튼
        resignButton = UIButton(frame: .init(x: UIScreen.main.bounds.width - 44, y: 8, width: 32, height: 32))
        mainView.addSubview(resignButton)
        let finishOptions = RichEditorDefaultOption.finish
        resignButton.setImage(finishOptions.image, for: .normal)
        resignButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
        resignButton.isHidden = true
        
        // 서체편집
        menuView = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
        menuView.backgroundColor = .init(rgb: 0xf7f7f7)
        addSubview(menuView)
        menuView.isHidden = true
        
        let menuDivider = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        menuView.addSubview(menuDivider)
        menuDivider.backgroundColor = .init(rgb: 0xf2f2f2)
        
        menuStackView = UIStackView(frame: .init(x: 10, y: 0, width: 202, height: 48))
        menuView.addSubview(menuStackView)
        menuStackView.spacing = 2
        menuStackView.distribution = .fillEqually
        
        options = RichEditorDefaultOption.custom
        subOptions = RichEditorDefaultOption.submenu
        
        // 텍스트 컬러
        textColorScrollView = UIScrollView(frame: .init(x: 0, y: 1, width: UIScreen.main.bounds.width, height: 47))
        menuView.addSubview(textColorScrollView)
        textColorScrollView.backgroundColor = .init(rgb: 0xf7f7f7)
        textColorScrollView.contentInsetAdjustmentBehavior = .never
        textColorScrollView.showsVerticalScrollIndicator = false
        textColorScrollView.showsHorizontalScrollIndicator = false
        textColorScrollView.contentInset = .init(top: 0, left: 8, bottom: 0, right: 10)
        textColorScrollView.isHidden = true
        updateTextColorToolbar()
        
        // 텍스트 사이즈
        sizeScrollView = UIScrollView(frame: .init(x: 0, y: 1, width: UIScreen.main.bounds.width, height: 47))
        menuView.addSubview(sizeScrollView)
        sizeScrollView.backgroundColor = .init(rgb: 0xf7f7f7)
        sizeScrollView.contentInsetAdjustmentBehavior = .never
        sizeScrollView.showsVerticalScrollIndicator = false
        sizeScrollView.showsHorizontalScrollIndicator = false
        sizeScrollView.contentInset = .init(top: 0, left: 8, bottom: 0, right: 10)
        sizeScrollView.isHidden = true
        updateTextSizeToolbar()
    }
    
    private func updateToolbar() {
        for (tag, option) in options.enumerated() {
            let button = UIButton(frame: .init(x: 0, y: 0, width: 32, height: 32))
            if let image = option.image {
                button.setImage(image, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
            } else {
                button.setTitle(option.title, for: .normal)
            }
            
            if let highlightImage = option.highlightImage {
                button.setImage(highlightImage, for: .selected)
            }
            button.tag = tag
            button.addTarget(self, action: #selector(actionHandler(_:)), for: .touchUpInside)
            mainStackView.addArrangedSubview(button)
            mainButtons.append(button)
        }
    }
    
    private func updateSubToolbar() {
        for (tag, option) in subOptions.enumerated() {
            let button = UIButton(frame: .init(x: 0, y: 0, width: 32, height: 48))
            if let image = option.image {
                button.setImage(image, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
            } else {
                button.setTitle(option.title, for: .normal)
            }
            
            if let highlightImage = option.highlightImage {
                button.setImage(highlightImage, for: .selected)
            }
            button.tag = tag
            button.addTarget(self, action: #selector(subActionHnadler(_:)), for: .touchUpInside)
            menuStackView.addArrangedSubview(button)
        }
    }
    
    private func updateTextColorToolbar() {
        let bundle = Bundle(for: RichEditorToolbar.self)
        let backImage = UIImage(named: "back", in: bundle, compatibleWith: nil)
        
        let backButton = UIButton(frame: .init(x: 0, y: -1, width: 28, height: 48))
        backButton.addTarget(self, action: #selector(backSubToolbar), for: .touchUpInside)
        backButton.setImage(backImage, for: .normal)
        textColorScrollView.addSubview(backButton)
        
        var priorView: UIView = backButton
        for (tag, color) in colors.enumerated() {
            let button = UIButton()
            textColorScrollView.addSubview(button)
            button.setImage(UIImage(color: color, size: .init(width: 32, height: 32)), for: .normal)
            button.frame = .init(x: priorView.frame.origin.x + priorView.frame.size.width + 8, y: 7, width: 32, height: 32)
            button.addTarget(self, action: #selector(changeTextColor(_:)), for: .touchUpInside)
            button.tag = tag
            priorView = button
        }
        
        textColorScrollView.contentSize = .init(width: priorView.frame.origin.x + priorView.frame.size.width, height: textColorScrollView.frame.size.height)
    }
    
    private func updateTextSizeToolbar() {
        let bundle = Bundle(for: RichEditorToolbar.self)
        let backImage = UIImage(named: "back", in: bundle, compatibleWith: nil)
        
        let backButton = UIButton(frame: .init(x: 0, y: -1, width: 28, height: 48))
        backButton.addTarget(self, action: #selector(backSubToolbar), for: .touchUpInside)
        backButton.setImage(backImage, for: .normal)
        sizeScrollView.addSubview(backButton)
        
        var priorView: UIView = backButton
        let sizeName = ["제목 1", "제목 2", "본문"]
        for tag in 0 ..< sizeOptions.count {
            let button = UIButton()
            sizeScrollView.addSubview(button)
            button.setTitle(sizeName[tag], for: .normal)
            button.titleLabel?.sizeToFit()
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.init(rgb: 0xfb4760), for: .selected)
            button.frame = .init(x: priorView.frame.origin.x + priorView.frame.size.width + 8, y: -1, width: button.titleLabel?.frame.size.width ?? 0, height: 48)
            button.tag = tag
            button.addTarget(self, action: #selector(changeTextSize(_:)), for: .touchUpInside)
            priorView = button
        }
        
        sizeScrollView.contentSize = .init(width: priorView.frame.origin.x + priorView.frame.size.width, height: sizeScrollView.frame.size.height)
    }
    
    @objc func toggleSubMenu() {
        isSubMenuOpen.toggle()
        
        if isSubMenuOpen {
            // 서브 뷰 추가하기
            minHeightConstraint?.isActive = false
            maxHeightConstraint?.isActive = true
            mainView.frame = .init(x: 0, y: 48, width: UIScreen.main.bounds.width, height: 48)
            menuView.isHidden = false
            menuView.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48)
        } else {
            maxHeightConstraint?.isActive = false
            minHeightConstraint?.isActive = true
            mainView.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48)
            menuView.isHidden = true
        }
        layoutIfNeeded()
    }
    
    @objc func actionHandler(_ button: UIButton) {
        let option = options[button.tag]
        option.action(self, sender: button)
        if button.tag == 1 {
            let centerButton = mainButtons[2]
            if centerButton.isSelected {
                centerButton.isSelected = false
            }
        } else if button.tag == 2 {
            let leftButton = mainButtons[1]
            if leftButton.isSelected {
                leftButton.isSelected = false
            }
        }
        button.isSelected.toggle()
        
    }
    
    @objc func subActionHnadler(_ button: UIButton) {
        let option = subOptions[button.tag]
        option.action(self, sender: button)
        button.isSelected.toggle()
    }
    
    @objc func changeTextColor(_ button: UIButton) {
        let color = colors[button.tag]
        let option = RichEditorDefaultOption.colorChip
        option.action(self, sender: color)
    }
    
    @objc func changeTextSize(_ button: UIButton) {
        let option = sizeOptions[button.tag]
        option.action(self, sender: button)
    }
    
    /// 키보드 닫음
    @objc func finish() {
        editor?.finish()
    }
    
    /// 서체 편집으로 돌아가기
    @objc func backSubToolbar() {
        textColorScrollView.isHidden = true
        sizeScrollView.isHidden = true
    }
    
    /// 텍스트 컬러 선택 툴바
    @objc func showTextColor() {
        textColorScrollView.isHidden = false
    }
    
    @objc func showTextSize() {
        sizeScrollView.isHidden = false
    }
    
//    func stringWidth(_ text: String, withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
//        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
//
//        return ceil(boundingBox.width)
//    }

}
