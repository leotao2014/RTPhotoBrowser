//
//  ViewController.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/2/26.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

let kReuseID = "reuseID";

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup();
    }
    
    func setup() {
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReuseID);
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseID)!;
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "NetworkImage";
        case 1:
            cell.textLabel?.text = "LocalImage"
        default:
            break;
        }
        
        return cell;
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let dis = PhotoSelectVC();
            self.navigationController?.pushViewController(dis, animated: true);
        case 1:
            break;
        default:
            break;
        }
    }
}

