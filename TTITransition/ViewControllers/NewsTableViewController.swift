//
//  NewsTableViewController.swift
//  TTITransition
//
//  Created by 1 on 05.04.2018.
//  Copyright © 2018 ANDRE.CORP. All rights reserved.
//

import UIKit

weak var tableViewDelegate : UITableViewController!

class NewsTableViewController: UITableViewController {

    @IBOutlet weak var newsTypeSelector: UISegmentedControl!
    
    private var allNews = [NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                   NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                   NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")
    ]
    
    private var updateSegment: NewsSelection = .new {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDelegate = self
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch newsTypeSelector.selectedSegmentIndex {
        case 0:
            allNews = [NewsItem(image: #imageLiteral(resourceName: "021-camera"), text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf"),
                        NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf"),
                        NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf"),
                        NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf"),
                        NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf"),
                        NewsItem(image: UIImage(named: "010-worldwide")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                        NewsItem(image: UIImage(named: "021-camera")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                        NewsItem(image: UIImage(named: "038-radio")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")
            ]
            updateSegment = .new
        case 1:
        allNews = [NewsItem(image: UIImage(named: "040-headphones")!, text: "aasd asd asd as das dadfgsdf gsd asddasdadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                    NewsItem(image: UIImage(named: "012-computer")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                    NewsItem(image: UIImage(named: "029-video-camera")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")]
            updateSegment = .top
        case 2:
        allNews = [NewsItem(image: UIImage(named: "007-van")!, text: "aasd asd asd as das dadfgsdf gsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgdsfg sdfg sdfg"),
                    NewsItem(image: UIImage(named: "005-news-1")!, text: "Sasd asdsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg asd ads asdasdafadh ads fasdfffasd asdf"),
                    NewsItem(image: UIImage(named: "016-sand-clock")!, text: "asdfasdgd sd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfgsd asd as das dadfgsdf gdsfg agdsdfhjvksdmrg asdf")
            ]
            updateSegment = .best
        default: break
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell
        cell?.iconNews.image = allNews[indexPath.row].image
        cell?.textNews.text = allNews[indexPath.row].text
        if allNews[indexPath.row].isLiked {
            cell?.backgroundColor = .gray
        } else {
            cell?.backgroundColor = UIColor(red:0.95, green:0.98, blue:0.98, alpha:1.0)
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetails", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let title = "" + ( !allNews[indexPath.row].isLiked ? "Liked" :  "Dislike")
        let likeBtn = UITableViewRowAction(style: .normal, title: title) { [weak self] (action, index) in
            self?.allNews[indexPath.row].isLiked = !(self?.allNews[indexPath.row].isLiked)!
            self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        let color : UIColor = (allNews[indexPath.row].isLiked ? UIColor.orange : UIColor.blue)
        likeBtn.backgroundColor = color
        return [likeBtn]
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" ,
            let index = sender as? IndexPath {
            let destVC = segue.destination as? DetailsViewController
            destVC?.news = allNews[index.row]
        }
    }
}
