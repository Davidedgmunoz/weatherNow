import UIKit

public protocol ViewWrappingCell: TableViewCell {

    associatedtype ViewType

    var wrappedView: ViewType { get }

}

public class DefaultViewWrappingCell<T: UIView>: TableViewCell, ViewWrappingCell {
    public typealias ViewType = T

    public var wrappedView: ViewType

    public convenience init(withView view: ViewType, reuseIdentifier: String, inset: Double) {
        self.init(
            withView: view,
            reuseIdentifier: reuseIdentifier,
            inset: UIEdgeInsets(
                top: inset, left: inset, bottom: inset, right: inset
            )
        )
    }

    public convenience init(
        withView view: ViewType,
        reuseIdentifier: String,
        vInset: Double,
        hInset: Double
    ) {
        self.init(
            withView: view,
            reuseIdentifier: reuseIdentifier,
            inset: UIEdgeInsets(
                top: vInset, left: hInset, bottom: vInset, right: hInset
            )
        )
    }

    public init(withView view: ViewType, reuseIdentifier: String, inset: UIEdgeInsets) {
        wrappedView = view
        super.init(reuseIdentifier: reuseIdentifier)

        assert(view.isKind(of: UIView.self))
        selectionStyle = .none
        isOpaque = view.isOpaque
        backgroundColor = .clear
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrappedView)
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.setContentHuggingPriority(.required, for: .vertical)

        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset.top),
            wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: inset.left),
            wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset.bottom),
            wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -inset.right)
        ])
    }

    convenience public init(withView view: ViewType, reuseIdentifier: String) {
        self.init(withView: view, reuseIdentifier: reuseIdentifier, inset: .zero)
    }
}
