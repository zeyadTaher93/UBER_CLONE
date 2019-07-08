//
//  ContainerVC.swift
//  Uber_Clone
//
//  Created by zeyad on 6/9/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case collapsed
    case expanded
}
enum ShowWhichVC{
    case homeVC
}

var showVC: ShowWhichVC = .homeVC

class ContainerVC: UIViewController {
    
    var homeVc: HomeVC!
    var leftVC: LeftSidePanelVC!
    var centreController: UIViewController!
    var currentState: SlideOutState = .collapsed{
        didSet{
            let showshadow = (currentState != .collapsed)
            showShadow(status: showshadow)
            
        }
    }
    var isHidden = false
    let centrePanelExpendedOffset:CGFloat = 160
    var tap: UITapGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCentre(screen: showVC)
    }
    
    
    
    
    func initCentre(screen: ShowWhichVC){
        var presentingController: UIViewController
        showVC = screen
        if homeVc == nil {
            homeVc = UIStoryboard.homeVC()
            homeVc.delagate = self
        }
        presentingController = homeVc
        
        if let con = centreController {
            con.view.removeFromSuperview()
            con.removeFromParent()
        }
        centreController = presentingController
        view.addSubview(centreController.view)
        addChild(centreController)
        centreController.didMove(toParent: self)
    }
    

}

extension ContainerVC: CentreVCDelegate {
    func toggleSideMenu() {
        let notAlreadyExpanded = (currentState != .expanded)
        if notAlreadyExpanded {
            addLeftPanelVC()
        }
        animateLeftPanel(shouldExpanded: notAlreadyExpanded)
    }
    
    func addLeftPanelVC() {
        if leftVC == nil {
            leftVC = UIStoryboard.LeftViewController()
            addChildSidePanelVC(_sidePanelController: leftVC)
        }
    }
    func addChildSidePanelVC(_sidePanelController: LeftSidePanelVC){
        view.insertSubview(_sidePanelController.view, at: 0)
        addChild(_sidePanelController)
        _sidePanelController.didMove(toParent:self)
    }
    @objc func animateLeftPanel(shouldExpanded: Bool) {
        if shouldExpanded {
            isHidden = !isHidden
            animateStatusBar()
            animateCentreXPosition(targetPosition: centreController.view.frame.width - centrePanelExpendedOffset)
            setupWhiteCoverView()
            currentState = .expanded
        }else{
            isHidden = !isHidden
            animateStatusBar()
            hideWhiteCoverView()
            
            animateCentreXPosition(targetPosition: 0) { (finished) in
                if finished {
                    self.currentState = .collapsed
                    self.leftVC = nil
                }
            }
        }
    }
    func animateCentreXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centreController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    func setupWhiteCoverView() {
        let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        whiteCoverView.alpha = 0.0
        whiteCoverView.backgroundColor = UIColor.white
        whiteCoverView.tag = 25
        self.centreController.view.addSubview(whiteCoverView)
        whiteCoverView.fadeTo(alphaValue: 0.75, with: 0.2)
        
//        UIView.animate(withDuration: 0.2) {
//            whiteCoverView.alpha = 0.75
//        }
        tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(shouldExpanded:)))
        tap.numberOfTapsRequired = 1
        self.centreController.view.addGestureRecognizer(tap)
    }
    func hideWhiteCoverView(){
        centreController.view.removeGestureRecognizer(tap)
        for subView in self.centreController.view.subviews {
            if subView.tag == 25 {
                UIView.animate(withDuration: 0.2, animations: {
                    subView.alpha = 0.0
                    
                }) { (finished) in
                    if finished {
                        subView.removeFromSuperview()
                    }
                }
            }
            
        }
    }
    func showShadow(status: Bool){
        if status {
            centreController.view.layer.shadowOpacity = 0.6
        }else {
            centreController.view.layer.shadowOpacity = 0
        }
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return UIStatusBarAnimation.slide
    }
    override var prefersStatusBarHidden: Bool{
        return isHidden
    }
    
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    class func LeftViewController() -> LeftSidePanelVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SideMenuVC") as? LeftSidePanelVC
    }
    class func homeVC() -> HomeVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
    }
}
