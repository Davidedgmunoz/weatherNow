import UIKit

public class TableViewCell: UITableViewCell {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var defaultReuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableView {

    /**
        Dequeues a cell with the given identifier via `dequeueReusableCell(withIdentifier:)`
        or creates a new one if the latter returns `nil`.

        This implements the common "try to dequeue first or create it if unavailable" pattern, which allows to avoid
        registering cells in advance which in turn allows to avoid standard initializers.

        Example:

        ```
        let stepCell = _view.tableView.dequeueReusableCell(StepCell.defaultReuseIdentifier) {
            StepCell()
        }
        ```
    */
    public func dequeueReusableCell<CellType: UITableViewCell>(
            _ identifier: String,
            creationBlock: (_ identifier: String) -> CellType
    ) -> CellType {
        if let cell = self.dequeueReusableCell(withIdentifier: identifier) as? CellType {
            return cell
        } else {
            return creationBlock(identifier)
        }
    }
}
