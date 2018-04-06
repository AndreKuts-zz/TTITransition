//
//  NewsTableViewController.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    private var path = 0
    private var allNews = [NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                   NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                   NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")
    ]
    
    private var updateSegment = NewsSelection.New {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch segmentOutlet.selectedSegmentIndex {
        case 0:
            updateSegment = .New
            allNews = [NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")
            ]
        case 1: updateSegment = .Top
        allNews = [NewsItem(image: UIImage(named: "040-headphones")!, text: "aasd asd asd as das dadfgsdf gsd asddasdadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                    NewsItem(image: UIImage(named: "012-computer")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                    NewsItem(image: UIImage(named: "029-video-camera")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")]
        case 2: updateSegment = .Best
        allNews = [NewsItem(image: UIImage(named: "007-van")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                    NewsItem(image: UIImage(named: "005-news-1")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                    NewsItem(image: UIImage(named: "016-sand-clock")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")
            ]
        default: break
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        cell.iconNews.image = allNews[indexPath.row].image
        cell.textNews.text = allNews[indexPath.row].text
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = indexPath.row
        self.performSegue(withIdentifier: "showDetails", sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let destVC = segue.destination as! DetailsViewController
            destVC.news = allNews[path]
        }
    }
}
