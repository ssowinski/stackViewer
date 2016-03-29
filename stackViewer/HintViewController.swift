//
//  HintViewController.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 28.03.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import UIKit

class HintViewController: UIViewController {
    
    private var textToPresentation : String {
        didSet {
            label.text = textToPresentation
        }
    }
    
    private let label = UILabel()
    
    // MARK: - Init
    init(text : String) {
        textToPresentation = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(label)
        label.text = textToPresentation
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
            label.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            label.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor),
            label.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            label.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor)
            ])
    }
    
    override var preferredContentSize:CGSize {
        get{
            if presentingViewController != nil {
                return label.sizeThatFits(presentingViewController!.view.bounds.size)
            } else{
                return super.preferredContentSize
            }
        }
        set{ super.preferredContentSize = newValue}
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
