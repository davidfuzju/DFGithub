//
//  ThemeManager.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import KafkaRefresh

let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .default)

let themeService = ThemeType.service(initial: ThemeType.currentTheme())

protocol Theme {
    var primary: UIColor { get }
    var primaryDark: UIColor { get }
    var secondary: UIColor { get }
    var secondaryDark: UIColor { get }
    var separator: UIColor { get }
    var border: UIColor { get }
    var text: UIColor { get }
    var textGray: UIColor { get }
    var background: UIColor { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var barStyle: UIBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }

    init(colorTheme: ColorTheme)
}

struct LightTheme: Theme {
    let border = UIColor.white
    
    let primary = UIColor.Material.white
    let primaryDark = UIColor.Material.grey200
    var secondary = UIColor.Material.red
    var secondaryDark = UIColor.Material.red900
    let separator = UIColor.Material.grey50
    let text = UIColor.Material.grey900
    let textGray = UIColor.Material.grey
    let background = UIColor.Material.white
    let statusBarStyle = UIStatusBarStyle.default
    let barStyle = UIBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight

    init(colorTheme: ColorTheme) {
        secondary = colorTheme.color
        secondaryDark = colorTheme.colorDark
    }
}

struct DarkTheme: Theme {
    let border = UIColor.white
    
    let primary = UIColor.Material.grey800
    let primaryDark = UIColor.Material.grey900
    var secondary = UIColor.Material.red
    var secondaryDark = UIColor.Material.red900
    let separator = UIColor.Material.grey900
    let text = UIColor.Material.grey50
    let textGray = UIColor.Material.grey
    let background = UIColor.Material.grey800
    let statusBarStyle = UIStatusBarStyle.lightContent
    let barStyle = UIBarStyle.black
    let keyboardAppearance = UIKeyboardAppearance.dark
    let blurStyle = UIBlurEffect.Style.dark

    init(colorTheme: ColorTheme) {
        secondary = colorTheme.color
        secondaryDark = colorTheme.colorDark
    }
}

enum ColorTheme: Int {
    case red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green, lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray

    static let allValues = [red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green, lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray]

    var color: UIColor {
        switch self {
        case .red: return UIColor.Material.red
        case .pink: return UIColor.Material.pink
        case .purple: return UIColor.Material.purple
        case .deepPurple: return UIColor.Material.deepPurple
        case .indigo: return UIColor.Material.indigo
        case .blue: return UIColor.Material.blue
        case .lightBlue: return UIColor.Material.lightBlue
        case .cyan: return UIColor.Material.cyan
        case .teal: return UIColor.Material.teal
        case .green: return UIColor.Material.green
        case .lightGreen: return UIColor.Material.lightGreen
        case .lime: return UIColor.Material.lime
        case .yellow: return UIColor.Material.yellow
        case .amber: return UIColor.Material.amber
        case .orange: return UIColor.Material.orange
        case .deepOrange: return UIColor.Material.deepOrange
        case .brown: return UIColor.Material.brown
        case .gray: return UIColor.Material.grey
        case .blueGray: return UIColor.Material.blueGrey
        }
    }

    var colorDark: UIColor {
        switch self {
        case .red: return UIColor.Material.red900
        case .pink: return UIColor.Material.pink900
        case .purple: return UIColor.Material.purple900
        case .deepPurple: return UIColor.Material.deepPurple900
        case .indigo: return UIColor.Material.indigo900
        case .blue: return UIColor.Material.blue900
        case .lightBlue: return UIColor.Material.lightBlue900
        case .cyan: return UIColor.Material.cyan900
        case .teal: return UIColor.Material.teal900
        case .green: return UIColor.Material.green900
        case .lightGreen: return UIColor.Material.lightGreen900
        case .lime: return UIColor.Material.lime900
        case .yellow: return UIColor.Material.yellow900
        case .amber: return UIColor.Material.amber900
        case .orange: return UIColor.Material.orange900
        case .deepOrange: return UIColor.Material.deepOrange900
        case .brown: return UIColor.Material.brown900
        case .gray: return UIColor.Material.grey900
        case .blueGray: return UIColor.Material.blueGrey900
        }
    }

    var title: String {
        switch self {
        case .red: return "Red"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .deepPurple: return "Deep Purple"
        case .indigo: return "Indigo"
        case .blue: return "Blue"
        case .lightBlue: return "Light Blue"
        case .cyan: return "Cyan"
        case .teal: return "Teal"
        case .green: return "Green"
        case .lightGreen: return "Light Green"
        case .lime: return "Lime"
        case .yellow: return "Yellow"
        case .amber: return "Amber"
        case .orange: return "Orange"
        case .deepOrange: return "Deep Orange"
        case .brown: return "Brown"
        case .gray: return "Gray"
        case .blueGray: return "Blue Gray"
        }
    }
}

enum ThemeType: ThemeProvider {
    case light(color: ColorTheme)
    case dark(color: ColorTheme)

    var associatedObject: Theme {
        switch self {
        case .light(let color): return LightTheme(colorTheme: color)
        case .dark(let color): return DarkTheme(colorTheme: color)
        }
    }

    var isDark: Bool {
        switch self {
        case .dark: return true
        default: return false
        }
    }

    func toggled() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light(let color): theme = ThemeType.dark(color: color)
        case .dark(let color): theme = ThemeType.light(color: color)
        }
        theme.save()
        return theme
    }

    func withColor(color: ColorTheme) -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light: theme = ThemeType.light(color: color)
        case .dark: theme = ThemeType.dark(color: color)
        }
        theme.save()
        return theme
    }
}

extension ThemeType {
    static func currentTheme() -> ThemeType {
        let defaults = UserDefaults.standard
        let isDark = defaults.bool(forKey: "IsDarkKey")
        let colorTheme = ColorTheme(rawValue: defaults.integer(forKey: "ThemeKey")) ?? ColorTheme.red
        let theme = isDark ? ThemeType.dark(color: colorTheme) : ThemeType.light(color: colorTheme)
        theme.save()
        return theme
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.isDark, forKey: "IsDarkKey")
        switch self {
        case .light(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        case .dark(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        }
    }
}

extension Reactive where Base: UIView {
    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }
}

extension Reactive where Base: UIButton {
    func backgroundImage(for state: UIControl.State) -> Binder<UIColor> {
        return Binder(self.base) { view, attr in
            let image = UIImage(color: attr, size: CGSize(width: 1, height: 1))
            view.setBackgroundImage(image, for: state)
        }
    }
}

extension Reactive where Base: UITextField {
    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.layerBorderColor = attr
        }
    }

    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            if let color = attr {
                view.setPlaceHolderTextColor(color)
            }
        }
    }
}

extension Reactive where Base: UITableView {
    var separatorColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.separatorColor = attr
        }
    }
}

extension Reactive where Base: TableViewCell {
    var selectionColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.selectionColor = attr
        }
    }
}

extension Reactive where Base: ViewController {
    var emptyDataSetImageTintColorBinder: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.emptyDataSetImageTintColor.accept(attr)
        }
    }
}

extension Reactive where Base: UINavigationBar {
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.largeTitleTextAttributes = attr
        }
    }
}

extension Reactive where Base: UIApplication {
    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { view, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
}

extension Reactive where Base: KafkaRefreshDefaults {
    var themeColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.themeColor = attr
        }
    }
}

public extension Reactive where Base: UISwitch {
    var onTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.onTintColor = attr
        }
    }

    var thumbTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.thumbTintColor = attr
        }
    }
}

extension ThemeProxy where Base: UIApplication {
    var statusBarStyle: ThemeAttribute<UIStatusBarStyle> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.statusBarStyle)
            hold(disposable, for: "statusBarStyle")
        }
    }
}

extension ThemeProxy where Base: UIButton {
    func backgroundImage(from newValue: ThemeAttribute<UIColor>, for state: UIControl.State) {
        let disposable = newValue.stream
            .take(until: base.rx.deallocating)
            .observe(on: MainScheduler.instance)
            .bind(to: base.rx.backgroundImage(for: state))
        hold(disposable, for: "backgroundImage.forState.\(state.rawValue)")
    }
}

extension ThemeProxy where Base: UITextField {
    var borderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.borderColor)
            hold(disposable, for: "borderColor")
        }
    }

    var placeholderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.placeholderColor)
            hold(disposable, for: "placeholderColor")
        }
    }
}

extension ThemeProxy where Base: TableViewCell {
    var selectionColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.selectionColor)
            hold(disposable, for: "selectionColor")
        }
    }
}

extension ThemeProxy where Base: ViewController {
    var emptyDataSetImageTintColorBinder: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.emptyDataSetImageTintColorBinder)
            hold(disposable, for: "emptyDataSetImageTintColorBinder")
        }
    }
}

extension ThemeProxy where Base: KafkaRefreshDefaults {
    var themeColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.themeColor)
            hold(disposable, for: "themeColor")
        }
    }
}

extension ThemeProxy where Base: UITabBar {
    var selectedColor: ThemeAttribute<UIColor> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.tintColor)
            hold(disposable, for: "selectedColor")
        }
    }

    var unselectedColor: ThemeAttribute<UIColor> {
        get { fatalError("set only") }
        set {
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.unselectedItemTintColor)
            hold(disposable, for: "unselectedColor")
        }
    }
}
