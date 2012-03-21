//
//  AppDelegate.h
//  ContestBot
//
//  Created by Иван Зырянов on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) CGFloat squareSize;
@property (strong, nonatomic) UIView* bot;
@property (strong, nonatomic) UIView* exit;
@property (nonatomic) int botX;
@property (nonatomic) int botY;
@property (strong, nonatomic) UILabel* turn;
@property (strong, nonatomic) NSMutableArray* bricks;

@end
