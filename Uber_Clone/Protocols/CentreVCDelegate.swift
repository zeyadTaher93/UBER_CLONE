//
//  CentreVCDelegate.swift
//  Uber_Clone
//
//  Created by zeyad on 6/9/19.
//  Copyright © 2019 zeyad. All rights reserved.
//

import UIKit

protocol CentreVCDelegate {
    func toggleSideMenu()
    func addLeftPanelVC()
    func animateLeftPanel(shouldExpanded: Bool)
}
