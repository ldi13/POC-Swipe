//
//  RandomColorViewController.swift
//  POC-Swipe
//
//  Created by Lorenzo DI VITA on 02/04/2015.
//  Copyright (c) 2015 Lorenzo DI VITA. All rights reserved.
//

import UIKit

class RandomColorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var colorLabelText: String!
    @IBOutlet weak var tableViewCell: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        println("deinit")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var tableViewCell = tableView.dequeueReusableCellWithIdentifier("randomColorCell") as UITableViewCell
        
        let red = CGFloat(arc4random() % 255)
        let green = CGFloat(arc4random() % 255)
        let blue = CGFloat(arc4random() % 255)
        
        tableViewCell.backgroundColor = UIColor(red:  red / 255, green: green / 255, blue: blue / 255, alpha: 1)
        
        return tableViewCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
