//
//  UITableView.swift
//  Helpers
//
//  Created by Iustin Bulimar on 02/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit

extension UITableView {
    
    func register<Cell: UITableViewCell>(cellClass: Cell.Type) {
        self.register(UINib(nibName: "\(cellClass)", bundle: Bundle(for: Cell.self)),
                      forCellReuseIdentifier: "\(cellClass)")
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(ofType type: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: "\(type)", for: indexPath) as? Cell else {
            fatalError("Cell has no identifier or is not of the expected class \(type).")
        }
        return cell
    }
    
    func register<Header: UITableViewHeaderFooterView>(headerClass: Header.Type) {
        self.register(UINib(nibName: "\(headerClass)", bundle: Bundle(for: Header.self)),
                      forHeaderFooterViewReuseIdentifier: "\(headerClass)")
    }
    
    func dequeueReusableHeader<Header: UITableViewHeaderFooterView>(ofType type: Header.Type) -> Header {
        guard let header = self.dequeueReusableHeaderFooterView(withIdentifier: "\(type)") as? Header else {
            fatalError("Header has no identifier or is not of the expected class \(type).")
        }
        return header
    }
    
}
