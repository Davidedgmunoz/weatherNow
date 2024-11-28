//
// Copyright © 2021 HealthyWage. All rights reserved.
//

import UIKit

open class NiblessView: UIView {
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A base for controls that do not support NIBs/storyboards, so there is no need in defining
/// `required init?(coder:)` initializer. It also declares Auto Layout support
open class NiblessControl: UIControl {

    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class ImageView: UIImageView {

    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - StackView

public class StackView: NiblessStackView {
    public init(
        orientation: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution = .fill
    ) {
        super.init()
        self.axis = orientation
        self.distribution = distribution
    }

    public override func setContentCompressionResistancePriority(
        _ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis
    ) {
        self.arrangedSubviews.forEach { $0.setContentCompressionResistancePriority(priority, for: axis)}
    }

    public func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    public func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }

    public func addArrangedSubviews(from viewsArray: [UIView]) {
        viewsArray.forEach { addArrangedSubview($0) }
    }
}

// MARK: -

open class NiblessStackView: UIStackView {
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MAKR: -

open class Button: UIButton {
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -

open class Label: UILabel {
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -
open class NiblessViewController: UIViewController {
    // MARK: - Methods
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable,
                message: "Loading this view controller from a nib is unsupported"
    )
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable,
                message: "Loading this view controller from a nib is unsupported"
    )
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Loading this view controller from a nib is unsupported")
    }
}

