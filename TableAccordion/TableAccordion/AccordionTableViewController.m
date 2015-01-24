//
//  AccordionTableViewController.m
//  TableAccordion
//
//  Created by Julian Schenkemeyer on 24/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import "AccordionTableViewController.h"

#define NUM_TOP_ITEMS 20
#define NUM_SUBITEMS 6

@interface AccordionTableViewController ()

@end

@implementation AccordionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.topItems = [[NSArray alloc] init];
    //self.subItems = [[NSMutableArray alloc] init];
    [self init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init {
    self = [super init];
    
    if (self) {
        _topItems = [[NSArray alloc] initWithArray:[self genTopLevelItems]];
        _subItems = [[NSMutableArray alloc] init];
        _currentExpandedIndex = -1;
        
        for (int i = 0; i < [_topItems count]; i++) {
            [_subItems addObject:[self genSubItems]];
        }
    }
    return self;
}

#pragma mark - Data generators

- (NSArray *)genTopLevelItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < NUM_TOP_ITEMS; i++) {
        [items addObject:[NSString stringWithFormat:@"Item %d", i + 1]];
    }
    
    return items;
}

- (NSArray *)genSubItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    int numItems = arc4random() % NUM_SUBITEMS + 2;
    
    for (int i = 0; i < numItems; i++) {
        [items addObject:[NSString stringWithFormat:@"SubItem %d", i + 1]];
    }
    
    return items;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.topItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // check if cell is already initialised, if not then initialise
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParentCell"];
    }
    
    
    // determine if current cell is parent or child
    BOOL isChild = self.currentExpandedIndex >= 0 && indexPath.row > 0 && indexPath.row <= self.currentExpandedIndex + [[self.subItems objectAtIndex:self.currentExpandedIndex] count];
    
    if (isChild) {
        //cell = [tableView dequeueReusableCellWithIdentifier:@"ChildCell" forIndexPath:indexPath];
        
        // set information for the childCell
        cell.detailTextLabel.text = [[self.subItems objectAtIndex:self.currentExpandedIndex] objectAtIndex:indexPath.row - (self.currentExpandedIndex + 1)];
        
    } else {
        //cell = [tableView dequeueReusableCellWithIdentifier:@"ParentCell" forIndexPath:indexPath];
        
        // is a cell currently expanded?
        NSInteger topIndex;
        if (self.currentExpandedIndex >= 0 && indexPath.row > self.currentExpandedIndex) {
            topIndex = indexPath.row - [[self.subItems objectAtIndex:self.currentExpandedIndex] count];
        } else {
            topIndex = indexPath.row;
        }
        
        // set inforamtion for the parentCell
        cell.textLabel.text = [self.topItems objectAtIndex:topIndex];
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChild = self.currentExpandedIndex >= 0 && indexPath.row > 0 && indexPath.row <= self.currentExpandedIndex + [[self.subItems objectAtIndex:self.currentExpandedIndex] count];

    if (isChild) {
        NSLog(@"Tapped");
        return;
    }
    
    // update the tableView
    //[self.tableView beginUpdates];
    
    if (self.currentExpandedIndex == indexPath.row) {
        [self collapseSubItemsAtIndex:self.currentExpandedIndex];
        self.currentExpandedIndex = -1;
        
    } else {
        
        BOOL shouldCollapse = self.currentExpandedIndex >= 0;
        
        if (shouldCollapse) {
            [self collapseSubItemsAtIndex:self.currentExpandedIndex];
        }
        
        if (shouldCollapse && indexPath.row > self.currentExpandedIndex) {
            self.currentExpandedIndex = indexPath.row - [[self.subItems objectAtIndex:self.currentExpandedIndex] count];
        } else {
            self.currentExpandedIndex = indexPath.row;
        }
        
        [self expandItemAtIndex:self.currentExpandedIndex];
    }
    //[self.tableView endUpdates];
    [self.tableView reloadData];
}


- (void)expandItemAtIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSArray *currentSubItems = [[NSArray alloc] initWithArray:[self.subItems objectAtIndex:index]];
                                
    NSInteger insertPos = index + 1;
    for (NSInteger i = 0; i < [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    NSLog([NSString stringWithFormat:@"%ld",(long)[self.tableView numberOfRowsInSection:0]]);
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    NSLog([NSString stringWithFormat:@"%ld",(long)[self.tableView numberOfRowsInSection:0]]);
}

- (void)collapseSubItemsAtIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (NSInteger i = index + 1; i <= index + [[self.subItems objectAtIndex:index] count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
