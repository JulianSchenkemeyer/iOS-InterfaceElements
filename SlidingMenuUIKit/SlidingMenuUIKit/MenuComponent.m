//
//  MenuComponent.m
//  SlidingMenuUIKit
//
//  Created by Julian Schenkemeyer on 21/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import "MenuComponent.h"

@interface MenuComponent()

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UITableView *optionsTableView;

@property (nonatomic, strong) NSArray *menuOptions;
@property (nonatomic, strong) NSArray *menuOptionImages;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic) MenuDirectionOptions menuDirection;
@property (nonatomic) CGRect menuFrame;
@property (nonatomic) CGRect menuInitialFrame;

@property (nonatomic) BOOL isMenuShown;

// private property for storing a block
@property (nonatomic, strong) void(^selectionHandler)(NSInteger);


//private methods for setting up the sliding menu
- (void)setupMenuView;
- (void)setupBackgroundView;
- (void)setupOptionsTableView;
- (void)setInitialTableViewSettings;
- (void)setupSwipeGestureRecognizer;

- (void)hideMenuWithGesture:(UISwipeGestureRecognizer *)gesture;

- (void)toggleMenu;

@end


@implementation MenuComponent

- (id)initMenuWithFrame:(CGRect)frame
             targetView:(UIView *)targetView
              direction:(MenuDirectionOptions)direction
                options:(NSArray *)options
           optionImages:(NSArray *)optionImages
{
    if (self = [super init]) {
        self.menuFrame = frame;
        self.targetView = targetView;
        self.menuDirection = direction;
        self.menuOptions = options;
        self.menuOptionImages = optionImages;
        
        
        // Setup the background view.
        [self setupBackgroundView];
        
        // Setup the menu view.
        [self setupMenuView];
        
        // Setup the options table view.
        [self setupOptionsTableView];
        
        // Set the initial table view settings.
        [self setInitialTableViewSettings];
        
        // Setup the swipe gesture recognizer.
        [self setupSwipeGestureRecognizer];
        
        
        // Initialize the animator.
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.targetView];
        
        // Set the initial height for each cell row.
        self.optionCellHeight = 50.0;
        
        // Set the initial acceleration value (push magnitude).
        self.acceleration = 15.0;
        
        // Indicate that initially the menu is not shown.
        self.isMenuShown = NO;
    }
    
    return self;
}

//*************************************//
// Implementation of the setup-methods
//*************************************//

// setup the Menu View outside of the visible screen area
- (void)setupMenuView
{
    if (self.menuDirection == menuDirectionLeftToRight) {
        self.menuInitialFrame = CGRectMake(-self.menuFrame.size.width,
                                           self.menuFrame.origin.y,
                                           self.menuFrame.size.width,
                                           self.menuFrame.size.height);
    } else {
        self.menuInitialFrame = CGRectMake(self.targetView.frame.size.width,
                                           self.menuFrame.origin.y,
                                           self.menuFrame.size.width,
                                           self.menuFrame.size.height);
    }
    
    self.menuView = [[UIView alloc] initWithFrame:self.menuInitialFrame];
    [self.menuView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:0.39 alpha:1.0]];
    [self.targetView addSubview:self.menuView];
}

// setup a View, which prohibites the user touches anywhere outside the menu
- (void)setupBackgroundView
{
    self.backgroundView = [[UIView alloc] initWithFrame:self.targetView.frame];
    [self.backgroundView setBackgroundColor:[UIColor grayColor]];
    [self.backgroundView setAlpha:0.0];
    [self.targetView addSubview:self.backgroundView];
}

// setup the table on the menu
- (void)setupOptionsTableView
{
    self.optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                          0.0,
                                                                          self.menuFrame.size.width,
                                                                          self.menuFrame.size.height)
                                                         style:UITableViewStylePlain];
    [self.optionsTableView setBackgroundColor:[UIColor clearColor]];
    [self.optionsTableView setScrollEnabled:NO];
    [self.optionsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.menuView addSubview:self.optionsTableView];
    
    [self.optionsTableView setDelegate:self];
    [self.optionsTableView setDataSource:self];
}

// initialize and populate the tableView
- (void)setInitialTableViewSettings
{
    self.tableSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [UIFont fontWithName:@"American Typewriter" size:15.0], @"font",
                          [NSNumber numberWithInt:NSTextAlignmentLeft], @"textAlignment",
                          [UIColor whiteColor], @"textColor",
                          [NSNumber numberWithInt:UITableViewCellSelectionStyleGray], @"selectionStyle",
                          nil];
}

// setup the gesture recognizer to recognize swipe gestures on the screen
- (void)setupSwipeGestureRecognizer {
    UISwipeGestureRecognizer *hideMenuGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuWithGesture:)];
    if (self.menuDirection == menuDirectionLeftToRight) {
        hideMenuGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    else{
        hideMenuGesture.direction = UISwipeGestureRecognizerDirectionRight;
    }
    [self.menuView addGestureRecognizer:hideMenuGesture];
}


- (void)toggleMenu
{
    // first we remove previously assigned behaviors
    [self.animator removeAllBehaviors];
    
    // define the behaviors
    CGFloat gravityDirectionX;
    
    CGPoint collisionPointFrom, collisionPointTo;
    
    CGFloat pushMagnitude = self.acceleration;
    
    
    // Check if the menu is shown or not.
    if (!self.isMenuShown) {
        // If the menu view is hidden and it's about to be shown, then specify each variable
        // value depending on the animation direction.
        if (self.menuDirection == menuDirectionLeftToRight) {
            // The value 1.0 means that gravity "moves" the view towards the right side.
            gravityDirectionX = 1.0;
            
            // The From and To points define an invisible boundary, where the X-origin point
            // equals to the desired X-origin point that the menu view should collide, and the
            // Y-origin points specify the highest and lowest point of the boundary.
            
            // If the menu view is being shown from left to right, then the collision boundary
            // should be defined so as to be at the right of the initial menu view position.
            collisionPointFrom = CGPointMake(self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(self.menuFrame.size.width, self.menuFrame.size.height);
        }
        else{
            // The value -1.0 means that gravity "pulls" the view towards the left side.
            gravityDirectionX = -1.0;
            
            // If the menu view is being shown from right to left, then the collision boundary
            // should be defined so as to be at the left of the initial menu view position.
            collisionPointFrom = CGPointMake(self.targetView.frame.size.width - self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(self.targetView.frame.size.width - self.menuFrame.size.width, self.menuFrame.size.height);
            
            // Set to the pushMagnitude variable the opposite value.
            pushMagnitude = (-1) * pushMagnitude;
        }
        
        // Make the background view semi-transparent.
        [self.backgroundView setAlpha:0.25];
    }
    else{
        // In case the menu is about to be hidden, then the exact opposite values should be
        // set to all variables for succeeding the opposite animation.
        
        if (self.menuDirection == menuDirectionLeftToRight) {
            gravityDirectionX = -1.0;
            collisionPointFrom = CGPointMake(-self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(-self.menuFrame.size.width, self.menuFrame.size.height);
            
            // Set to the pushMagnitude variable the opposite value.
            pushMagnitude = (-1) * pushMagnitude;
        }
        else{
            gravityDirectionX = 1.0;
            collisionPointFrom = CGPointMake(self.targetView.frame.size.width + self.menuFrame.size.width, self.menuFrame.origin.y);
            collisionPointTo = CGPointMake(self.targetView.frame.size.width + self.menuFrame.size.width, self.menuFrame.size.height);
        }
        
        // Make the background view fully transparent.
        [self.backgroundView setAlpha:0.0];
    }
    
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.menuView]];
    [gravityBehavior setGravityDirection:CGVectorMake(gravityDirectionX, 0.0)];
    [self.animator addBehavior:gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    [collisionBehavior addBoundaryWithIdentifier:@"collisionBoundary"
                                       fromPoint:collisionPointFrom
                                         toPoint:collisionPointTo];
    [self.animator addBehavior:collisionBehavior];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.menuView]];
    [itemBehavior setElasticity:0.35];
    [self.animator addBehavior:itemBehavior];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.menuView] mode:UIPushBehaviorModeInstantaneous];
    [pushBehavior setMagnitude:pushMagnitude];
    [self.animator addBehavior:pushBehavior];
}


- (void)showMenuWithSelectionHandler:(void (^)(NSInteger))handler
{
    if (!self.isMenuShown) {
        self.selectionHandler = handler;
        
        [self toggleMenu];
        
        self.isMenuShown = YES;
    }
}

- (void)hideMenuWithGesture:(UISwipeGestureRecognizer *)gesture {
    // Make a call to toggleMenu method for hiding the menu.
    [self toggleMenu];
    
    // Indicate that the menu is not shown.
    self.isMenuShown = NO;
}

//************************************
// Setup for the Table
//************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuOptions count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.optionCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"optionCell"];
    }
    
    // set the selection style
    [cell setSelectionStyle:[[self.tableSettings objectForKey:@"selectionStyle"] intValue]];
    
    // set text and properties for the cell
    cell.textLabel.text = [self.menuOptions objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[self.tableSettings objectForKey:@"font"]];
    [cell.textLabel setTextAlignment:[[self.tableSettings objectForKey:@"textAlignment"] intValue]];
    [cell.textLabel setTextColor:[self.tableSettings objectForKey:@"textColor"]];
    
    // add images if specified
    if (self.menuOptionImages != nil) {
        [cell.imageView setImage:[UIImage imageNamed:[self.menuOptionImages objectAtIndex:indexPath.row]]];
        [cell.imageView setTintColor:[UIColor whiteColor]];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if (self.selectionHandler) {
        self.selectionHandler(indexPath.row);
    }
}

@end
