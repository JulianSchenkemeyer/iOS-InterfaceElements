//
//  AccordionTableViewController.h
//  TableAccordion
//
//  Created by Julian Schenkemeyer on 24/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccordionTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *topItems;
@property (nonatomic, strong) NSMutableArray *subItems;

@property (nonatomic) NSInteger currentExpandedIndex;

@end
