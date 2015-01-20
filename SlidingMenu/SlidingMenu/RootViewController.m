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
#define menuCellID @"MenuCell"

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
    
    [self.menu registerClass:[UITableViewCell class] forCellReuseIdentifier:menuCellID];
    self.menu.frame = self.view.bounds;
    [self.view addSubview:self.menu];
    
    self.indexOfVisibleController = 0;
    UIViewController *visibleViewController = self.viewControllers[0];
    visibleViewController.view.frame = [self offScreenFrame];
    [self addChildViewController:visibleViewController];
    [self.view addSubview:visibleViewController.view];
    self.isMenuVisible = YES;
    [self adjustContentFrameAccordingToMenuVisibilty];
    
    [self.viewControllers[0] didMoveToParentViewController:self];
}

- (void)toggleMenuVisibility:(id)sender
{
    self.isMenuVisible = !self.isMenuVisible;
    [self adjustContentFrameAccordingToMenuVisibilty];
}

- (void)adjustContentFrameAccordingToMenuVisibilty
{
    UIViewController *visibleViewController = self.viewControllers[self.indexOfVisibleController];
    CGSize size = visibleViewController.view.frame.size;
    
    if (self.isMenuVisible)
    {
        [UIView animateWithDuration:0.5 animations:^{
            visibleViewController.view.frame = CGRectMake(exposeWidth, 0, size.width, size.height);
        }];
    }
    else
        [UIView animateWithDuration:0.5 animations:^{
            visibleViewController.view.frame = CGRectMake(0, 0, size.width, size.height);
        }];
}

- (void)replaceVisibleViewControllerWithViewControllerAtIndex:(NSInteger)index
{
    if (index == self.indexOfVisibleController) return;
    UIViewController *incomingViewController = self.viewControllers[index];
    incomingViewController.view.frame = [self offScreenFrame];
    UIViewController *outgoingViewController = self.viewControllers[self.indexOfVisibleController];
    CGRect visibleFrame = self.view.bounds;
    
    
    [outgoingViewController willMoveToParentViewController:nil];
    
    [self addChildViewController:incomingViewController];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self transitionFromViewController:outgoingViewController
                      toViewController:incomingViewController
                              duration:0.5 options:0
                            animations:^{
                                outgoingViewController.view.frame = [self offScreenFrame];
                                
                            }
     
                            completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.5
                                                 animations:^{
                                                     [outgoingViewController.view removeFromSuperview];
                                                     [self.view addSubview:incomingViewController.view];
                                                     incomingViewController.view.frame = visibleFrame;
                                                     [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                                 }];
                                [incomingViewController didMoveToParentViewController:self];
                                [outgoingViewController removeFromParentViewController];
                                self.isMenuVisible = NO;
                                self.indexOfVisibleController = index;
                            }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuCellID];
    cell.textLabel.text = self.menuTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self replaceVisibleViewControllerWithViewControllerAtIndex:indexPath.row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect)offScreenFrame
{
    return CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
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
