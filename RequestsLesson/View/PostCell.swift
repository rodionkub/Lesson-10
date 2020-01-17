//
//  PostCell.swift
//  FinalTask
//
//  Created by Родион Кубышкин on 29/12/2019.
//  Copyright © 2019 Родион Кубышкин. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("oh no")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        var name = "Родион Кубышкин"
        var date = "\n14 дек в 20:35"
        
        let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: date, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0.65, alpha: 1)]))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        
        attributedText.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, attributedText.string.count))
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let postTextView: UITextView = {
        let textView = UITextView()
        textView.text = "=) ставь ликбез если жижа =)=) ставь ликбез если жижа =)=) ставь ликбез если жижа =)=) ставь ликбез если жижа =)"
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let commentCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        func set(count: Int) {
            label.text = String(count)
        }
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.init(white: 0.6, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let likeCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        func set(count: Int) {
            label.text = String(count)
        }
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.init(white: 0.6, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        backgroundColor = UIColor.white
        
        addSubview(nameLabel)
        addSubview(avatarImageView)
        addSubview(postTextView)
        addSubview(postImageView)
        addSubview(likeButton)
        addSubview(likeCount)
        addSubview(commentButton)
        addSubview(commentCount)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v0(50)]-8-[v1]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": avatarImageView, "v1": nameLabel]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]-4-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": postTextView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": postImageView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0(24)]-6-[v1]-50-[v2(24)]-6-[v3]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": likeButton, "v1": likeCount, "v2": commentButton, "v3": commentCount]))
         
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[v0]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-10-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": likeCount]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-10-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": commentCount]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(24)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": commentButton]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0(50)]-2-[v1][v2]-10-[v3(24)]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": avatarImageView, "v1": postTextView, "v2": postImageView, "v3": likeButton]))
    }
}

