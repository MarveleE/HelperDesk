import UIKit

protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

// MARK: - UICollectionView
extension UICollectionReusableView {
    static var nibName: String { return String(describing: self) }
}

extension UICollectionView {

    func register(_ cellClass: UICollectionViewCell.Type) {
        register(cellClass.self, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }

    func registerNib(for cellClass: UICollectionViewCell.Type) {
        register(cellClass.nib, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }

    func registerSectionHeaderNib<T: UICollectionReusableView>(for cellClass: T.Type) {
        let nib = UINib(nibName: cellClass.nibName, bundle: Bundle(for: T.self))
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellClass.reuseIdentifier)
    }

    func registerSectionFooter(for cellClass: UICollectionReusableView.Type) {
        register(cellClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cellClass.reuseIdentifier)
    }

    func registerSectionHeader(for cellClass: UICollectionReusableView.Type) {
        register(cellClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellClass.reuseIdentifier)
    }

    func dequeueReusableCell<CellClass: UICollectionViewCell>(for indexPath: IndexPath) -> CellClass {
        guard let cell = dequeueReusableCell(withReuseIdentifier: CellClass.reuseIdentifier, for: indexPath) as? CellClass else {
            fatalError("Cannot dequeueReusableCell of \(CellClass.self) type!")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<ViewClass: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath) -> ViewClass {
        guard let view = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: ViewClass.reuseIdentifier, for: indexPath) as? ViewClass else {
            fatalError("Cannot dequeueReusableSupplementaryView of \(ViewClass.self) type!")
        }
        return view
    }

    func dequeueReusableCell<CellClass: UICollectionViewCell>(
        of classType: CellClass.Type,
        for indexPath: IndexPath,
        defaultCell: UICollectionViewCell? = nil,
        configure: (CellClass) -> Void = { _ in }) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: CellClass.reuseIdentifier, for: indexPath)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
            return typedCell
        }
        return defaultCell ?? cell
    }
}

// MARK: - UITableView
extension UITableView {

    func register(_ cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }

    func register(_ view: UITableViewHeaderFooterView.Type) {
        register(view, forHeaderFooterViewReuseIdentifier: view.reuseIdentifier)
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T else {
            fatalError("Could not deque headerView of type: \(viewType.reuseIdentifier)")
        }
        return view
    }

    func registerNib<T: UITableViewCell>(_ cellType: T.Type) {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not deque cell of type: \(cellType.reuseIdentifier)")
        }
        cell.layer.anchorPointZ = CGFloat(indexPath.row)
        return cell
    }
}
