//
//  ViewController.swift
//  Combine-Test-UIImage
//
//  Created by Nanu Jogi on 23/07/19.
//  Copyright © 2019 Greenleaf Software. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var img: UIImageView!
    
    var subCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        original()
        //method1()
    }
    
    func method1() {
        
        let sub = URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")!)
            
            .map { UIImage(data: $0.data)! }
            .catch { err in
                return Just(UIImage())
        }
            
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
        
        //            .assign(to: \.image, on: img)
        // sometime the above ^^^ line gives error so we use below .sink to pass image
        
        let subCancel = sub
            .sink(receiveCompletion: { completion in
                print("✅ .sink() received the completion", String(describing: completion))
                switch completion {
                case .finished:
                    break
                case .failure(let anError):
                    print("❌ received error: ", anError)
                }
            }, receiveValue: { image in
                print("✅ .sink() image received!")
                self.img.image = image
            })
        
        // convert the .sink to an `AnyCancellable` object that we have
        // referenced from the implied initializers
        subCancellable = AnyCancellable(subCancel)
    }
    
    func original() {
        
        let sub  = URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")!)
            
            .tryMap { (data, resp) -> UIImage? in
                guard let image = UIImage(data: data) else { return nil }
                return image
        }
        .replaceError(with: UIImage())
//            .subscribe(on: DispatchQueue.main) // will give error
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: img)
        sub.cancel()
    }
}

