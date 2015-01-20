//
//  RootViewController.m
//  SlidingMenu
//
//  Created by Julian Schenkemeyer on 20/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import "RootViewController.h"

// defining some basics for the sliding menu
#define exposeWidth 150.0
#define menuCellIDs @"MenuCell"

@interface RootViewController ()

@property (nonatomic, strong) UITableView *menu;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *menuTitles;

@property (nonatomic, assign) NSInteger indexOfVisibleController;
@property (nonatomic, assign) BOOL isMenuVisible;

@end

@implementation RootViewController

- (id)initWithViewControllers:(NSArray *)viewControllers andMenuTitles:(NSArray *)titles
{
    if (self = [super init]) {
        NSAssert(self.viewControllers.count == self.menuTitles.count, @"There must be as many viewControllers as menuTitles. One for each!");
        NSMutableArray *tempVCs = [NSMutableArray arrayWithCapacity:viewControllers.count];
        
        for (UIViewController *vc in viewControllers) {
            if (![vc isMemberOfClass:[UINavigationController class]]) {
                
                [tempVCs addObject:[[UINavigationController alloc] initWithRootViewController:vc]];
                
            } else {
                
                [tempVCs addObject:vc];
                
            }
            
            UIBarButtonItem *revealMenuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenuVisibility:)];
            
            UIViewController *topVC = ((UINavigationController *)tempVCs.lastObject).topViewController;
            topVC.navigationItem.leftBarButtonItems = [@[revealMenuBarButtonItem] arrayByAddingObjectsFromArray:topVC.navigationItem.leftBarButtonItems];
        }
        
        self.viewControllers = [tempVCs copy];
        self.menu = [[UITableView alloc] init];
        self.menu.delegate = self;
        self.menu.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
