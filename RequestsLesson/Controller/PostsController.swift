//
//  PostsController.swift
//  FinalTask
//
//  Created by Родион Кубышкин on 28/12/2019.
//  Copyright © 2019 Родион Кубышкин. All rights reserved.
//

import UIKit
import CoreData

let cellId = "cellId"

class PostsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var storedData: [StoredPost] = []
    var parsedData: Reply? = nil
    var parsedUser: NameReply? = nil
    var cells: [PostCell] = []
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let decoder = JSONDecoder()
            parsedData = try decoder.decode(Reply.self, from: LoginController.posts!)
            parsedUser = try decoder.decode(NameReply.self, from: LoginController.user!)
        } catch let jsonErr {
            print(jsonErr)
        }
        
        let fetchRequest: NSFetchRequest<StoredPost> = StoredPost.fetchRequest()
        do {
            let posts = try AppDelegate.context.fetch(fetchRequest)
            self.storedData = posts
        } catch {}
        
        if storedData.count == 0 {
            for i in (0..<10) {
                let postCell = PostCell()
                let first_name = (parsedUser?.response![0].first_name!)!
                let last_name = (parsedUser?.response![0].last_name!)!
                let name = "\(first_name) \(last_name)"
                            
                let date = getFormattedDate(i: i, parsedData: parsedData)
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: "\n" + date, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.65, alpha: 1)]))
                postCell.nameLabel.attributedText = attributedText
                            
                let text = parsedData?.response?.items![i].text
                postCell.postTextView.text = text
                
                let commentCount = parsedData?.response?.items![i].comments?.count
                let likeCount = parsedData?.response?.items![i].likes?.count
                postCell.commentCount.text = String(commentCount!)
                postCell.likeCount.text = String(likeCount!)
                        
                let photoURL = URL(string: (parsedUser?.response![0].photo_50!)!)
                postCell.avatarImageView.load(url: photoURL!)
                            
                let item = parsedData?.response?.items![i]
                var url = ""
                if item?.attachments != nil {
                    if item?.attachments![0] != nil {
                        if item?.attachments![0].photo != nil {
                            url = (item?.attachments![0].photo?.sizes?.last?.url!)!
                        }
                    }
                }
                if url != "" {
                    postCell.postImageView.load(url: URL(string: url)!)
                }
                else {
                    postCell.postImageView.image = nil
                }
                
                cells.append(postCell)
            }
        } else {
            for i in (storedData.count-10..<storedData.count - 1) {
                let postCell = PostCell()
                let first_name = self.storedData[i].first_name!
                let last_name = self.storedData[i].last_name!
                let name = "\(first_name) \(last_name)"
                
                postCell.postTextView.text = self.storedData[i].text
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: "\n" + String(self.storedData[i].date!), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.65, alpha: 1)]))
                postCell.nameLabel.attributedText = attributedText
                postCell.avatarImageView.image = UIImage(data: self.storedData[i].avatar!)
                postCell.commentCount.text = String(self.storedData[i].comments)
                postCell.likeCount.text = String(self.storedData[i].likes)
                if self.storedData[i].image != nil {
                    postCell.postImageView.image = UIImage(data: self.storedData[i].image!)
                }
                
                cells.append(postCell)
            }
        }
        
        DispatchQueue.global().async {
            for i in (0..<10) {
                let post = StoredPost(context: AppDelegate.context)
                let text = self.parsedData?.response?.items![i].text
                let commentCount = self.parsedData?.response?.items![i].comments?.count
                let likeCount = self.parsedData?.response?.items![i].likes?.count
                var url = ""
                if self.parsedData?.response?.items![i].attachments != nil {
                    if self.parsedData?.response?.items![i].attachments![0] != nil {
                        if self.parsedData?.response?.items![i].attachments![0].photo != nil {
                            url = (self.parsedData?.response?.items![i].attachments![0].photo?.sizes?.last?.url!)!
                        }
                    }
                }
                if url != "" {
                    if let data = try? Data(contentsOf: URL(string: url)!) {
                        post.image = data
                    }
                }
                url = (self.parsedUser?.response![0].photo_50!)!
                if let data = try? Data(contentsOf: URL(string: url)!) {
                    post.avatar = data
                }
                post.first_name = (self.parsedUser?.response![0].first_name!)!
                post.last_name = (self.parsedUser?.response![0].last_name!)!
                post.date = getFormattedDate(i: i, parsedData: self.parsedData)
                post.text = text
                post.comments = Int16(commentCount!)
                post.likes = Int16(likeCount!)
                AppDelegate.saveContext()
            }
        }
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        collectionView?.register(PostCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostCell
        
        if indexPath.item < cells.count {
            
            postCell.nameLabel.attributedText = cells[indexPath.item].nameLabel.attributedText
                        
            postCell.postTextView.text = cells[indexPath.item].postTextView.text
                        
            postCell.commentCount.text = cells[indexPath.item].commentCount.text
            postCell.likeCount.text = cells[indexPath.item].likeCount.text
                    
            postCell.avatarImageView.image = cells[indexPath.item].avatarImageView.image
            postCell.avatarImageView.layer.cornerRadius = postCell.avatarImageView.bounds.height / 2
                        
            postCell.postImageView.image = cells[indexPath.item].postImageView.image
            
        }
        
        return postCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.item == cells.count - 1 {
            
            let startIndex = cells.count
            var endIndex: Int
            
            if startIndex + 10 > (parsedData?.response?.items!.count)! - 1 {
                endIndex = (parsedData?.response?.items!.count)! - 1
            } else {
                endIndex = startIndex + 10
            }
            
            for i in (startIndex..<endIndex) {
                let postCell = PostCell()
                let first_name = (parsedUser?.response![0].first_name!)!
                let last_name = (parsedUser?.response![0].last_name!)!
                let name = "\(first_name) \(last_name)"
                            
                let date = getFormattedDate(i: i, parsedData: parsedData)
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                attributedText.append(NSAttributedString(string: "\n" + date, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.65, alpha: 1)]))
                postCell.nameLabel.attributedText = attributedText
                            
                let text = parsedData?.response?.items![i].text
                postCell.postTextView.text = text
                            
                let commentCount = parsedData?.response?.items![i].comments?.count
                let likeCount = parsedData?.response?.items![i].likes?.count
                postCell.commentCount.text = String(commentCount!)
                postCell.likeCount.text = String(likeCount!)
                        
                let photoURL = URL(string: (parsedUser?.response![0].photo_50!)!)
                postCell.avatarImageView.load(url: photoURL!)
                            
                let item = parsedData?.response?.items![i]
                var url = ""
                if item?.attachments != nil {
                    if item?.attachments![0] != nil {
                        if item?.attachments![0].photo != nil {
                            url = (item?.attachments![0].photo?.sizes?.last?.url!)!
                        }
                    }
                }
                if url != "" {
                    postCell.postImageView.load(url: URL(string: url)!)
                }
                else {
                    postCell.postImageView.image = nil
                }
                
                cells.append(postCell)
            }
        }
        self.perform(#selector(loadCollectionView), with: nil, afterDelay: 1.0)
    }
    
    @objc func loadCollectionView() {
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = 100
        let item = parsedData?.response?.items![indexPath.item]
        if item?.attachments != nil {
            if item?.attachments![0] != nil {
                if item?.attachments![0].photo != nil {
                    let fromWidth = (item?.attachments![0].photo?.sizes?.last?.width!)!
                    let fromHeight = (item?.attachments![0].photo?.sizes?.last?.height!)!
                    let rect = getResizingResult(fromWidth: Double(fromWidth), fromHeight: Double(fromHeight), targetWidth: 400.0, targetHeight: 400.0)
                    height += Int(rect.height)
                }
            }
        }
        
        let postTextView: UITextView = {
            let textView = UITextView()
            textView.font = UIFont.systemFont(ofSize: 12)
            textView.translatesAutoresizingMaskIntoConstraints = false
            return textView
        }()
        postTextView.text = item?.text!
        postTextView.sizeToFit()
        if postTextView.contentSize.height < 0 {
            postTextView.contentSize.height = 10
        }
        height += Int((Double((Int(postTextView.contentSize.height) - 31) / 14) * 1.5)) * 14 + 31
        
        return CGSize(width: Int(width), height: height)
    }
}

func getResizingResult(fromWidth: Double, fromHeight: Double, targetWidth: Double, targetHeight: Double) -> CGRect {
    
    let widthRatio  = targetWidth  / fromWidth
    let heightRatio = targetHeight / fromHeight
    let newSize = widthRatio > heightRatio ?  CGSize(width: fromWidth * heightRatio, height: fromHeight * heightRatio) : CGSize(width: fromWidth * widthRatio,  height: fromHeight * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    return rect
}

func getFormattedDate(i: Int, parsedData: Reply?) -> String {
    
    var formattedDate = ""
    let date = parsedData?.response?.items![i].date
    let dateDate = Date(timeIntervalSince1970: TimeInterval(date!))
    let currentTimestamp = Int(NSDate().timeIntervalSince1970)
    let timeDifference = currentTimestamp - date!
    let pastHours = Int(timeDifference / 3600)
    let pastMinutes = Int(timeDifference / 60)
    var minute = String(Calendar.current.component(.minute, from: dateDate))
    if minute.count == 1 {
        minute = "0" + minute
    }
    var hour = String(Calendar.current.component(.hour, from: dateDate))
    if hour.count == 1 {
        hour = "0" + hour
    }
    if Calendar.current.isDateInToday(dateDate) {
        if pastHours >= 1 {
            formattedDate = "сегодня в \(hour):\(minute)"
        }
        else {
            formattedDate = "\(pastMinutes) минут назад"
        }
    }
    else if Calendar.current.isDateInYesterday(dateDate) {
        formattedDate = "вчера в \(hour):\(minute)"
    }
    else {
        let month = Calendar.current.component(.month, from: dateDate)
        var monthName = ""
        if month == 1 {
            monthName = "янв"
        }
        else if month == 2 {
            monthName = "фев"
        }
        else if month == 3 {
            monthName = "мар"
        }
        else if month == 4 {
            monthName = "апр"
        }
        else if month == 5 {
            monthName = "мая"
        }
        else if month == 6 {
            monthName = "июн"
        }
        else if month == 7 {
            monthName = "июл"
        }
        else if month == 8 {
            monthName = "авг"
        }
        else if month == 9 {
            monthName = "сен"
        }
        else if month == 10 {
            monthName = "окт"
        }
        else if month == 11 {
            monthName = "ноя"
        }
        else if month == 12 {
            monthName = "дек"
        }
        
        if Calendar.current.component(.year, from: dateDate) == Calendar.current.component(.year, from: Date(timeIntervalSince1970: TimeInterval(currentTimestamp))) {
            formattedDate = "\(Calendar.current.component(.day, from: dateDate)) \(monthName) в \(hour):\(minute)"
        }
        else {
            formattedDate = "\(Calendar.current.component(.day, from: dateDate)) \(monthName) \(Calendar.current.component(.year, from: dateDate)) г."
        }
    }
    return formattedDate
}

