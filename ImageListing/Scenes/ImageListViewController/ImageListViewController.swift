//
//  ImageListViewController.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit
import RxSwift
import Toast_Swift

class ImageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = ImageListViewModel()
    
    private let disposeBag = DisposeBag()
    
    private let fadeFilter = FadeFilter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        loadNextPage()
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadNextPage() {
        viewModel.loadNextPage()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldReload in
                guard shouldReload else { return }
                self?.tableView.reloadData()
                }, onError: { [weak self] error in
                    self?.showError()
                    print(error)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let image = viewModel.images[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(ofType: ImageCell.self, for: indexPath)
        
        cell.backgroundImageView.image = UIImage(named: "placeholder")
        cell.authorLabel.attributedText = NSAttributedString(string: "© " + image.author,
                                                             attributes: [
                                                                .strokeColor : UIColor.black,
                                                                .foregroundColor : UIColor.white,
                                                                .strokeWidth : -2.0
        ])
        
        let url = image.downloadUrl(width: Int(cell.contentView.bounds.width), height: 250)
        //        cell.heightConstraint.constant = 250
        
        cell.url = url
        
        viewModel.loadImage(url: url)
            .map { [weak self] image in
                return self?.fadeFilter?.filter(image: image)
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { image in
            if url == cell.url {
                cell.backgroundImageView.image = image
            }
        }, onError: { [weak self] error in
            self?.showError()
            print(error)
        })
            .disposed(by: disposeBag)
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let image = viewModel.images[indexPath.row]
        
        let imageViewerViewController = ImageViewerViewController.instance()
        imageViewerViewController.image = image
        imageViewerViewController.dataManager = viewModel.dataManager
        imageViewerViewController.modalPresentationStyle = .fullScreen
        
        present(imageViewerViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == viewModel.images.count {
            loadNextPage()
        }
    }
    
}
