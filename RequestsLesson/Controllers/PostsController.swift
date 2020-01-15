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

struct Reply: Decodable {
    let response: Response?
}

struct NameReply: Decodable {
    let response: [User]?
}

struct User: Decodable {
    let first_name: String?
    let last_name: String?
    let photo_50: String?
}

struct Response: Decodable {
    let count: Int?
    let items: [Post]?
}

struct Post: Decodable {
    let date: Int?
    let text: String?
    let comments: Comment?
    let likes: Like?
    let reposts: Repost?
    let attachments: [Attachment]?
}

struct Attachment: Decodable {
    let type: String?
    let photo: Photo?
}

struct Photo: Decodable {
    let sizes: [Size]?
}

struct Size: Decodable {
    let url: String?
    let height: Int?
    let width: Int?
}

struct Comment: Decodable {
    let count: Int?
}

struct Like: Decodable {
    let count: Int?
}

struct Repost: Decodable {
    let count: Int?
}

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
        
        
        
        for i in (0..<10) {
            let post = StoredPost(context: AppDelegate.context)
            let text = parsedData?.response?.items![i].text
            let commentCount = parsedData?.response?.items![i].comments?.count
            let likeCount = parsedData?.response?.items![i].likes?.count
            var url = ""
            if parsedData?.response?.items![i].attachments != nil {
                if parsedData?.response?.items![i].attachments![0] != nil {
                    if parsedData?.response?.items![i].attachments![0].photo != nil {
                        url = (parsedData?.response?.items![i].attachments![0].photo?.sizes?.last?.url!)!
                    }
                }
            }
            if url != "" {
               DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: URL(string: url)!) {
                        post.image = data
                    }
                }
            }
            post.date = getFormattedDate(i: i, parsedData: parsedData)
            post.text = text
            post.comments = Int16(commentCount!)
            post.likes = Int16(likeCount!)
            AppDelegate.saveContext()
        }
        
        let fetchRequest: NSFetchRequest<StoredPost> = StoredPost.fetchRequest()
        do {
            let posts = try AppDelegate.context.fetch(fetchRequest)
            self.storedData = posts
        } catch {}
        
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
//    }
//        else {
//            postCell.postTextView.text = self.storedData[indexPath.item].text
//            let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
//            attributedText.append(NSAttributedString(string: "\n" + String(self.storedData[indexPath.item].date!), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.65, alpha: 1)]))
//            postCell.nameLabel.attributedText = attributedText
//            postCell.commentCount.text = String(self.storedData[indexPath.item].comments)
//            postCell.likeCount.text = String(self.storedData[indexPath.item].likes)
//            print(self.storedData[indexPath.item].image)
//            if self.storedData[indexPath.item].image != nil {
//                postCell.postImageView.image = UIImage(data: self.storedData[indexPath.item].image!)
//            }
//        }
        
        return postCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.item == cells.count - 1 {
            
            let startIndex = cells.count
            var endIndex: Int
            
            if startIndex + 10 > (parsedData?.response?.items!.count)! - 1 {
                endIndex = (parsedData?.response?.items!.count)! - 1
            }
            else {
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if image.size.width == 50 {
                            self?.layer.cornerRadius = self!.bounds.width / 2
                            self?.image = image
                        } else {
                            self?.image = image.resizeImage(targetSize: CGSize(width: 400, height: 400))
                        }
                    }
                }
            }
        }
    }
}

extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
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

