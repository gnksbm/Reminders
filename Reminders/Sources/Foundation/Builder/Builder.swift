//
//  Builder.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit
import OSLog

extension Buildable where Self: AnyObject {
    /**
     클로저 구문 안에서 Builder로 객체의 프로퍼티 값을 변경하거나 함수 실행
     - Parameter block: Builder를 반환하는 subscript나 action 메서드를 체이닝 형태로 사용,
     클로저 내부에서 Builder<객체> 타입을 반환해야함
     - Returns: Builder<객체>가 언래핑되어 블록 안에서 설정한 객체 반환
     */
    func build(
        _ block: (_ builder: Builder<Self>) -> Builder<Self>,
        fileID: String = #fileID,
        line: Int = #line
    ) -> Self {
        block(
            Builder(
                self,
                fileID: fileID,
                line: line
            )
        ).build()
    }
}

/**
 객체의 설정을 메서드 체이닝 형태로 구현할 수 있는 래핑 객체
 - 변수 선언과 호출, return문 등의 반복을 줄여 간결한 코드 작성 가능
 - dynamicMemberLookup을 사용한 구현으로 View, Controller 객체의 프로퍼티에 접근이 가능하며
 subscript의 반환형을 클로저 형태로 구현하여 SwiftUI의 Modifier처럼 프로퍼티 값 할당 가능
 */
@dynamicMemberLookup
struct Builder<Base: AnyObject> {
    private let _base: Base
    private let fileID: String
    private let line: Int
    
    init(
        _ base: Base,
        fileID: String = #fileID,
        line: Int = #line
    ) {
        self._base = base
        self.fileID = fileID
        self.line = line
    }
    
    var base: Base {
        _base
    }
    
    subscript<Property>(
        dynamicMember keyPath: ReferenceWritableKeyPath<Base, Property>
    ) -> (Property) -> Builder<Base> {
        { newValue in
            _base[keyPath: keyPath] = newValue
            return self
        }
    }
    
    subscript<Property>(
        dynamicMember keyPath: KeyPath<Base, Property>
    ) -> PropertyBuilder<Base, Property> {
        PropertyBuilder(_base, keyPath: keyPath)
    }
    
    subscript<Property>(
        dynamicMember keyPath: ReferenceWritableKeyPath<Base, Property?>
    ) -> OptionalPropertyBuilder<Base, Property> {
        OptionalPropertyBuilder(
            _base,
            keyPath: keyPath,
            fileID: fileID,
            line: line
        )
    }
    
    func action(_ block: (_ base: Base) -> Void) -> Builder<Base> {
        block(_base)
        return self
    }
    
    fileprivate func build() -> Base {
        _base
    }
}

@dynamicMemberLookup
struct PropertyBuilder<Parent: AnyObject, Property> {
    private var parent: Parent
    private var keyPath: KeyPath<Parent, Property>
    
    init(_ parent: Parent, keyPath: KeyPath<Parent, Property>) {
        self.parent = parent
        self.keyPath = keyPath
    }
    
    subscript<NestedProperty>(
        dynamicMember nestedKeyPath:
        ReferenceWritableKeyPath<Property, NestedProperty>
    ) -> (NestedProperty) -> Builder<Parent> {
        { newValue in
            parent[keyPath: keyPath.appending(path: nestedKeyPath)] = newValue
            return Builder(parent)
        }
    }
}

@dynamicMemberLookup
struct OptionalPropertyBuilder<Parent: AnyObject, Property> {
    private var parent: Parent
    private var keyPath: ReferenceWritableKeyPath<Parent, Property?>
    
    private let fileID: String
    private let line: Int
    
    private var logger: OSLog {
        OSLog(
            subsystem: .bundleIdentifier,
            category: "Builder"
        )
    }
    
    init(
        _ parent: Parent,
        keyPath: ReferenceWritableKeyPath<Parent, Property?>,
        fileID: String,
        line: Int
    ) {
        self.parent = parent
        self.keyPath = keyPath
        self.fileID = fileID
        self.line = line
    }
    
    subscript<NestedProperty>(
        dynamicMember nestedKeyPath:
        WritableKeyPath<Property, NestedProperty>
    ) -> (NestedProperty) -> Builder<Parent> {
        { newValue in
            guard var copy = parent[keyPath: keyPath] else {
                failureLog(nestedKeyPath: nestedKeyPath)
                return Builder(parent)
            }
            copy[keyPath: nestedKeyPath] = newValue
            parent[keyPath: keyPath] = copy
            return Builder(parent)
        }
    }
    
    private func failureLog<NestedProperty>(
        nestedKeyPath: WritableKeyPath<Property, NestedProperty>
    ) {
        let parentType = String(describing: Parent.self)
        let propertyType = removingOptionalDescription(
            type: type(of: keyPath).valueType
        )
        let nestedPropertyType = removingOptionalDescription(
            type: type(of: nestedKeyPath).valueType
        )
        os_log(
            """
            [Builder: Failed to Update %{public}@]
            Location: %{public}@ at line %{public}d.
            %{public}@'s %{public}@ is nil.
            """,
            log: logger,
            type: .error,
            nestedPropertyType, fileID, line, parentType, propertyType
        )
    }
    
    private func removingOptionalDescription(type: Any.Type) -> String {
        String(describing: type)
            .replacingOccurrences(of: "Optional<", with: "")
            .replacingOccurrences(of: ">", with: "")
    }
}

extension Builder where Base: UIView {
    func addSubview(view: UIView) -> Builder<Base> {
        _base.addSubview(view)
        return self
    }
    
    func setContentHuggingPriority(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis
    ) -> Builder<Base> {
        _base.setContentHuggingPriority(priority, for: axis)
        return self
    }
    
    func setContentCompressionResistancePriority(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis
    ) -> Builder<Base> {
        _base.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
}

extension Builder where Base: UIControl {
    func addTarget(
        _ target: Any?,
        action: Selector,
        for controlEvents: UIControl.Event
    ) -> Builder<Base> {
        _base.addTarget(target, action: action, for: controlEvents)
        return self
    }
    
    func removeTarget(
        _ target: Any?,
        action: Selector?,
        for controlEvents: UIControl.Event
    ) -> Builder<Base> {
        _base.removeTarget(target, action: action, for: controlEvents)
        return self
    }
}

extension Builder where Base: UIButton {
    func setImage(
        _ image: UIImage?,
        for state: UIControl.State
    ) -> Builder<Base> {
        _base.setImage(image, for: state)
        return self
    }
    
    func setTitle(
        _ title: String?,
        for state: UIControl.State
    ) -> Builder<Base> {
        _base.setTitle(title, for: state)
        return self
    }
    
    func setTitleColor(
        _ color: UIColor?,
        for state: UIControl.State
    ) -> Builder<Base> {
        _base.setTitleColor(color, for: state)
        return self
    }
}

extension Builder where Base: UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) -> Builder<Base> {
        _base.register(
            cellClass,
            forCellReuseIdentifier: String(describing: T.self)
        )
        return self
    }
}

extension Builder where Base: UICollectionView {
    func register<T: UICollectionViewCell>(
        _ cellClass: T.Type
    ) -> Builder<Base> {
        _base.register(
            cellClass,
            forCellWithReuseIdentifier: String(describing: T.self)
        )
        return self
    }
}

extension Builder where Base: UIAlertController {
    func addAction(_ action: UIAlertAction) -> Builder<Base> {
        _base.addAction(action)
        return self
    }
}

extension Builder where Base: UIActivityIndicatorView {
    func startAnimating() -> Builder<Base> {
        _base.startAnimating()
        return self
    }
}

extension Builder where Base: NSMutableAttributedString {
    func append(_ attrString: NSAttributedString) -> Builder<Base> {
        _base.append(attrString)
        return self
    }
}

extension Builder where Base: UINavigationBarAppearance {
    func configureWithOpaqueBackground() -> Builder<Base> {
        _base.configureWithOpaqueBackground()
        return self
    }
}

extension Builder where Base: UITabBarAppearance {
    func configureWithOpaqueBackground() -> Builder<Base> {
        _base.configureWithOpaqueBackground()
        return self
    }
}

