//
//  MenuComponent.h
//  SlidingMenuUIKit
//
//  Created by Julian Schenkemeyer on 21/01/15.
//  Copyright (c) 2015 SchenkemeyerJulian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MenuDirectionOptionTypes {
    menuDirectionLeftToRight,
    menuDirectionRightToLeft
} MenuDirectionOptions;


@interface MenuComponent : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIColor *menuBackgroundColor;
@property (nonatomic, strong) NSMutableDictionary *tableSettings;
@property (nonatomic) CGFloat optionCellHeight;
@property (nonatomic) CGFloat acceleration;


- (id)initMenuWithFrame:(CGRect)frame targetView:(UIView *)targetView direction:(MenuDirectionOptions)direction options:(NSArray *)options optionImages:(NSArray *)optionImages;

@end
