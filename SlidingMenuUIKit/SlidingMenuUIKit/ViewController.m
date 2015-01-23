//
//  ViewController.m
//  SlidingMenuUIKit
//
//  Created by Julian Schenkemeyer on 21/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import "ViewController.h"
#import "MenuComponent.h"

@interface ViewController ()

@property (nonatomic, strong) MenuComponent *menuComponent;

- (void)showMenu:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UISwipeGestureRecognizer *showMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    
    showMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:showMenuGesture];


    CGRect desiredMenuFrame = CGRectMake(0.0, 20.0, 150.0, self.view.frame.size.height);
    self.menuComponent = [[MenuComponent alloc] initMenuWithFrame:desiredMenuFrame
                                                       targetView:self.view
                                                        direction:menuDirectionRightToLeft
                                                          options:@[@"Download", @"Upload", @"E-mail", @"Settings", @"About"]
                                                     optionImages:@[@"download", @"upload", @"email", @"settings", @"info"]];

}

- (void)showMenu:(UIGestureRecognizer *)gestureRecognizer
{
    [self.menuComponent showMenuWithSelectionHandler:^(NSInteger selectionOptionIndex) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sliding Menu with UIKit"
                                                       message:[NSString stringWithFormat:@"You selected option #%ld", selectionOptionIndex + 1]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        
        [alert show];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
