//
//  EventsVC.swift
//  Mother_Earth
//
//  Created by Sonar on 24/10/17.
//  Copyright © 2017 Navdeep. All rights reserved.
//

import UIKit

class EventsVC: UIViewController {

    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var eventsTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTV.rowHeight = UITableViewAutomaticDimension
        eventsTV.estimatedRowHeight = 60
    }
    
    @IBAction func sliderMoved(_ sender: Any) {
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        return cell
    }
}
