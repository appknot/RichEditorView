//
//  RichEditorOptionItem.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// A RichEditorOption object is an object that can be displayed in a RichEditorToolbar.
/// This protocol is proviced to allow for custom actions not provided in the RichEditorOptions enum.
public protocol RichEditorOption {

    /// The image to be displayed in the RichEditorToolbar.
    var image: UIImage? { get }
    var highlightImage: UIImage? { get }
    /// The title of the item.
    /// If `image` is nil, this will be used for display in the RichEditorToolbar.
    var title: String { get }

    /// The action to be evoked when the action is tapped
    /// - parameter editor: The RichEditorToolbar that the RichEditorOption was being displayed in when tapped.
    ///                     Contains a reference to the `editor` RichEditorView to perform actions on.
    /// - parameter sender: The object that sent the action. Usually a `UIView` from the toolbar item that represents the option.
    func action(_ editor: RichEditorToolbar, sender: AnyObject)
}

/// RichEditorOptionItem is a concrete implementation of RichEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar.
public struct RichEditorOptionItem: RichEditorOption {
    /// The image that should be shown when displayed in the RichEditorToolbar.
    public var image: UIImage?
    
    public var highlightImage: UIImage?

    /// If an `itemImage` is not specified, this is used in display
    public var title: String

    /// The action to be performed when tapped
    public var handler: ((RichEditorToolbar, AnyObject) -> Void)

    public init(image: UIImage? = nil, title: String, action: @escaping ((RichEditorToolbar, AnyObject) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }
    
    public init(title: String, action: @escaping ((RichEditorToolbar, AnyObject) -> Void)) {
        self.init(image: nil, title: title, action: action)
    }
    
    public func action(_ toolbar: RichEditorToolbar, sender: AnyObject) {
        handler(toolbar, sender)
    }
}

/// RichEditorOptions is an enum of standard editor actions
public enum RichEditorDefaultOption: RichEditorOption {
    case typeface
    case clear
    case undo
    case redo
    case bold
    case italic
    case `subscript`
    case superscript
    case strike
    case underline
    case textColor
    case textBackgroundColor
    case header(Int)
    case indent
    case outdent
    case orderedList
    case unorderedList
    case alignLeft
    case alignCenter
    case alignRight
    case image
    case link
    case finish
    case size
    case color
    case colorChip
    
    public static let all: [RichEditorDefaultOption] = [
        .clear,
        .undo, .redo, .bold, .italic,
        .subscript, .superscript, .strike, .underline,
        .textColor, .textBackgroundColor,
        .header(1), .header(2), .header(3), .header(4), .header(5), .header(6),
        .indent, outdent, orderedList, unorderedList,
        .alignLeft, .alignCenter, .alignRight, .image, .link
    ]
    
    public static let custom: [RichEditorDefaultOption] = [
        .typeface, .alignLeft, .alignCenter, .link, .image
    ]
    
    public static let submenu: [RichEditorDefaultOption] = [
        .bold, .italic, .underline, .strike, .size, .color
    ]
    
    public static let textSize: [RichEditorDefaultOption] = [
        .header(2), .header(4), .header(6)
    ]

    // MARK: RichEditorOption

    public var image: UIImage? {
        var name = ""
        switch self {
        case .typeface: name = "typeface"
        case .clear: name = "clear"
        case .undo: name = "undo"
        case .redo: name = "redo"
        case .bold: name = "bold"
        case .italic: name = "italic"
        case .subscript: name = "subscript"
        case .superscript: name = "superscript"
        case .strike: name = "strike"
        case .underline: name = "underline"
        case .textColor: name = "text_color"
        case .textBackgroundColor: name = "bg_color"
        case .header(let h): name = "h\(h)"
        case .indent: name = "indent"
        case .outdent: name = "outdent"
        case .orderedList: name = "ordered_list"
        case .unorderedList: name = "unordered_list"
        case .alignLeft: name = "alignleft"
        case .alignCenter: name = "aligncenter"
        case .alignRight: name = "justify_right"
        case .image: name = "image"
        case .link: name = "link"
        case .finish: name = "finish"
        case .size: name = "size"
        case .color: name = "color"
        case .colorChip: name = "colorChip"
        }
        
        let bundle = Bundle(for: RichEditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var highlightImage: UIImage? {
        var name = ""
        switch self {
        case .typeface: name = "typeface_highlight"
        case .alignLeft: name = "alignleft_highlight"
        case .alignCenter: name = "aligncenter_highlight"
        case .bold: name = "bold_highlight"
        case .italic: name = "italic_highlight"
        case .underline: name = "underline_highlight"
        case .strike: name = "strike_hightlight"
        default: name = ""
        }
        
        let bundle = Bundle(for: RichEditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var title: String {
        switch self {
        case .typeface: return NSLocalizedString("Typeface", comment: "")
        case .clear: return NSLocalizedString("Clear", comment: "")
        case .undo: return NSLocalizedString("Undo", comment: "")
        case .redo: return NSLocalizedString("Redo", comment: "")
        case .bold: return NSLocalizedString("Bold", comment: "")
        case .italic: return NSLocalizedString("Italic", comment: "")
        case .subscript: return NSLocalizedString("Sub", comment: "")
        case .superscript: return NSLocalizedString("Super", comment: "")
        case .strike: return NSLocalizedString("Strike", comment: "")
        case .underline: return NSLocalizedString("Underline", comment: "")
        case .textColor: return NSLocalizedString("Color", comment: "")
        case .textBackgroundColor: return NSLocalizedString("BG Color", comment: "")
        case .header(let h): return NSLocalizedString("H\(h)", comment: "")
        case .indent: return NSLocalizedString("Indent", comment: "")
        case .outdent: return NSLocalizedString("Outdent", comment: "")
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .alignLeft: return NSLocalizedString("Left", comment: "")
        case .alignCenter: return NSLocalizedString("Center", comment: "")
        case .alignRight: return NSLocalizedString("Right", comment: "")
        case .image: return NSLocalizedString("Image", comment: "")
        case .link: return NSLocalizedString("Link", comment: "")
        case .finish: return NSLocalizedString("Finish", comment: "")
        case .size: return NSLocalizedString("Text Size", comment: "")
        case .color: return NSLocalizedString("Text Color", comment: "")
        case .colorChip: return "colorChip"
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar, sender: AnyObject) {
        switch self {
        case .typeface: toolbar.toggleSubMenu()
        case .clear: toolbar.editor?.removeFormat()
        case .undo: toolbar.editor?.undo()
        case .redo: toolbar.editor?.redo()
        case .bold: toolbar.editor?.bold()
        case .italic: toolbar.editor?.italic()
        case .subscript: toolbar.editor?.subscriptText()
        case .superscript: toolbar.editor?.superscript()
        case .strike: toolbar.editor?.strikethrough()
        case .underline: toolbar.editor?.underline()
        case .textColor: toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, sender: sender)
        case .textBackgroundColor: toolbar.delegate?.richEditorToolbarChangeBackgroundColor?(toolbar, sender: sender)
        case .header(let h): toolbar.editor?.header(h)
        case .indent: toolbar.editor?.indent()
        case .outdent: toolbar.editor?.outdent()
        case .orderedList: toolbar.editor?.orderedList()
        case .unorderedList: toolbar.editor?.unorderedList()
        case .alignLeft: toolbar.editor?.alignLeft()
        case .alignCenter: toolbar.editor?.alignCenter()
        case .alignRight: toolbar.editor?.alignRight()
        case .image: toolbar.delegate?.richEditorToolbarInsertImage?(toolbar)
        case .link: toolbar.delegate?.richEditorToolbarInsertLink?(toolbar)
        case .finish: toolbar.editor?.finish()
        case .size: toolbar.showTextSize()
        case .color: toolbar.showTextColor()
        case .colorChip: toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, sender: sender)
        }
    }
}
