//
//  ViewController.swift
//  ThreadControl
//
//  Created by Daisuke T on 2019/04/24.
//  Copyright © 2019 ThreadControl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let threadControl = ThreadControl.init(target: self, selector: #selector(ViewController.threadFunc(_:)), object: "Hello World", loopTimeInterval: 1)
    threadControl.rawThread?.name = "Test-Thread"
    threadControl.rawThread?.start()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      threadControl.rawThread?.cancel()
    }
  }
  
  @objc func threadFunc(_ object: Any?) {
    let message = object as? String ?? ""
    print("\(Thread.current.name ?? "") message=\(message)")
  }
  
}

