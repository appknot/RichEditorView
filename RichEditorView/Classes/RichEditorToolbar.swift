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
    

    /// The tint color to apply to the toolbar background.
//    open var barTintColor: UIColor? {
//        get { return backgroundColor }
//        set { backgroundColor = newValue }
//    }
    
    /// The spacing between the option items
//    open var itemMargin: CGFloat = 8 {
//        didSet {
//            collectionView.collectionViewLayout.invalidateLayout()
//        }
//    }

//    private var collectionView: UICollectionView!
    private var mainView: UIView!
    private var menuView: UIView!
    
    private var mainStackView: UIStackView!
    
    // 서체편집 선택
    private var menuStackView: UIStackView!
    
    // 서체편집 선택 > 텍스트 걸러 선택
    private var textColorStackView: UIStackView!
    private var textColorScrollView: UIScrollView!
    
    // 서체편집 선택 > 텍스트 크기 선택
    private var sizeStackView: UIStackView!
    private var sizeScrollView: UIScrollView!
    
    private var maxHeightConstraint: NSLayoutConstraint?
    private var minHeightConstraint: NSLayoutConstraint?
    
    private var isSubMenuOpen: Bool = false
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
        
        resignButton = UIButton(frame: .init(x: UIScreen.main.bounds.width - 44, y: 8, width: 32, height: 32))
        mainView.addSubview(resignButton)
        let finishOptions = RichEditorDefaultOption.finish
        resignButton.setImage(finishOptions.image, for: .normal)
        resignButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
        resignButton.isHidden = true
        
        menuView = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
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
        
//        menuScrollView.translatesAutoresizingMaskIntoConstraints = false
//        menuScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        menuScrollView.contentInsetAdjustmentBehavior = .never
//        menuScrollView.showsVerticalScrollIndicator = false
//        menuScrollView.showsHorizontalScrollIndicator = false
//        menuScrollView.contentInset = .init(top: 0, left: 8, bottom: 0, right: 10)
        
        
        
//        translatesAutoresizingMaskIntoConstraints = false
//        heightAnchor.constraint(equalToConstant: 48).isActive = true
//        backgroundColor = .blue
//        mainStackView = UIStackView()
//        mainStackView.axis = .vertical
//        mainStackView.distribution = .equalSpacing
//        mainStackView.spacing = 0

//        addSubview(mainStackView)
//        mainStackView.translatesAutoresizingMaskIntoConstraints = true
//        mainStackView.backgroundColor = .systemPink
//
//        NSLayoutConstraint.activate([
//            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            mainStackView.topAnchor.constraint(equalTo: topAnchor),
//            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            mainStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
//        ])

//        let menuView = UIView()
//        mainStackView.addArrangedSubview(menuView)
//        menuView.translatesAutoresizingMaskIntoConstraints = true
//        let heightConstraint = menuView.heightAnchor.constraint(equalToConstant: 48)
//        heightConstraint.priority = UILayoutPriority(rawValue: 750)
//        heightConstraint.isActive = true
        
//        self.setNeedsUpdateConstraints()
//        self.layoutIfNeeded()
        
//        autoresizingMask = .flexibleWidth

//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        
//        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = backgroundColor
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.register(ToolbarCell.self, forCellWithReuseIdentifier: "cell")
        
//        let visualView = UIVisualEffectView(frame: bounds)
//        visualView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        visualView.effect = UIBlurEffect(style: .regular)
//        visualView.contentView.addSubview(collectionView)
//
//        pinViewEdges(of: collectionView, to: visualView)

//        addSubview(visualView)
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
            button.tag = tag
            button.addTarget(self, action: #selector(actionHandler(_:)), for: .touchUpInside)
            mainStackView.addArrangedSubview(button)
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
            button.tag = tag
            button.addTarget(self, action: #selector(subActionHnadler(_:)), for: .touchUpInside)
            menuStackView.addArrangedSubview(button)
        }
    }
    
    @objc func openSubMenu() {
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
    }
    
    @objc func subActionHnadler(_ button: UIButton) {
        let option = subOptions[button.tag]
        option.action(self, sender: button)
    }
    
    @objc func finish() {
        editor?.finish()
    }
    

    
//    func stringWidth(_ text: String, withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
//        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
//
//        return ceil(boundingBox.width)
//    }

    // MARK: - CollectionView
    
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return options.count
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let option = options[indexPath.item]
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ToolbarCell
//        cell.option = option
//
//        return cell
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let option = options[indexPath.item]
//
//        if let cell = collectionView.cellForItem(at: indexPath) {
//            option.action(self, sender: cell.contentView)
//        }
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return itemMargin
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        let opt = options[indexPath.item]
////        var width: CGFloat = 0
////        if let image = opt.image {
////            width = image.size.width
////        } else {
////            width = stringWidth(opt.title, withConstrainedHeight: bounds.height, font: DefaultFont)
////        }
//        return CGSize(width: 26, height: bounds.height)
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: itemMargin, height: 1)
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: itemMargin, height: 1)
//    }
}


//private class ToolbarCell: UICollectionViewCell {
//    var option: RichEditorOption! {
//        didSet {
//            // remove the previous subview
//            contentView.subviews.first?.removeFromSuperview()
//
//            var subview: UIView!
//
//            // build the subview for the cell
//            if let image = option.image {
//                let imageView = UIImageView(frame: .zero)
//                imageView.image = image
//                imageView.contentMode = .scaleAspectFit
//                subview = imageView
//            } else {
//                let label = UILabel(frame: .zero)
//                label.text = option.title
//                label.font = DefaultFont
//                label.textColor = tintColor
//                subview = label
//            }
//
//            subview.translatesAutoresizingMaskIntoConstraints = false
//            subview.sizeToFit()
//            contentView.addSubview(subview)
//            pinViewEdges(of: subview, to: contentView)
//        }
//    }
//}
