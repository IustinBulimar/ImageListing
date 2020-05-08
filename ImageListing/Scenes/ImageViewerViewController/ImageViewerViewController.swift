//
//  ImageViewerViewController.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit
import RxSwift

class ImageViewerViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var image: Image!
    var dataManager: DataManager!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadimage()
    }
    
    @IBAction func didTapImageView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func loadimage() {
        dataManager.fetchImage(url: image.downloadUrl)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                self.imageWidthConstraint.constant = self.view.bounds.size.width
                self.imageHeightConstraint.constant = self.view.bounds.size.height
                self.imageView.image = image
                }, onError: { [weak self] error in
                    self?.showError()
                    print(error)
            })
            .disposed(by: disposeBag)
    }
    
}
