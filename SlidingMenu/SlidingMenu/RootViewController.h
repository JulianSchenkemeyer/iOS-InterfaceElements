//
//  RootViewController.h
//  SlidingMenu
//
//  Created by Julian Schenkemeyer on 20/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithViewControllers:(NSArray *)viewControllers andMenuTitles:(NSArray *)titles;

@end
