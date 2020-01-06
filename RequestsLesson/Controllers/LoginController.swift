//
//  LoginController.swift
//  RequestsLesson
//
//  Created by Родион Кубышкин on 28/12/2019.
//  Copyright © 2019 Родион Кубышкин. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class LoginController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    static var posts: Data?
    static var user: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        let url = URL(string: "https://oauth.vk.com/authorize?client_id=6898636&display=page&redirect_uri=https://oauth.vk.com/blank.html&scope=offline%2Cwall&response_type=token&v=5.92")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let url = webView.url
        print(url!)
        if (url?.absoluteString.contains("access_token="))! {
            let token = url?.absoluteString.split(separator: "&")[0].split(separator: "=")[1]
            let user_id = url?.absoluteString.split(separator: "&")[2].split(separator: "=")[1]
            
            let getPostsRequest = URL(string: "https://api.vk.com/method/wall.get?v=5.92&access_token=" + token!)
            let getNameRequest = URL(string: "https://api.vk.com/method/users.get?user_ids=\(user_id!)v=5.92&access_token=" + token!)
            let task = URLSession.shared.dataTask(with: getPostsRequest!) {(data, response, error) in
                guard let data = data else { return }
                LoginController.posts = data
            }
            let task2 = URLSession.shared.dataTask(with: getNameRequest!) {(data, response, error) in
                guard let data = data else { return }
                LoginController.user = data
            }
            task.resume()
            task2.resume()
            while LoginController.posts == nil {}
            while LoginController.user == nil {}

            let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
            let collectionView:PostsController = PostsController.init(collectionViewLayout:layout)
            navigationController!.pushViewController(collectionView, animated: true)
        }
    }
    
}
