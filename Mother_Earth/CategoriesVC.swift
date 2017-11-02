//
//  CategoriesVC.swift
//  Mother_Earth
//
//  Created by Sonar on 24/10/17.
//  Copyright © 2017 Navdeep. All rights reserved.
//

import UIKit
import RxSwift

class CategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoriesTableView: UITableView!
    
    let categories = Variable<[Category]>([])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                // Traditional way of doing things.. We will learn Schedulers later in the book
                DispatchQueue.main.async {
                    self?.categoriesTableView?.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        startDownload()
    }
    
    func startDownload(){
        let localCategories = EONETRequestRouter.categories
        let downloadedEvents = EONETRequestRouter.events(forLast: 360)
        let updatedCategories = Observable
            .combineLatest(localCategories, downloadedEvents) {
                (categories, events) -> [Category] in
                return categories.map { category in
                    var cat = category
                    cat.events = events.filter {
                        $0.categories.contains(category.id)
                    }
                    return cat
                }
        }
        localCategories
            .concat(updatedCategories)
            .bind(to: categories)
            .disposed(by: disposeBag)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
        let category = categories.value[indexPath.row]
        cell.textLabel?.text = "\(category.name) (\(category.events.count))"
        cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator
            : .none
        return cell
    }

}
