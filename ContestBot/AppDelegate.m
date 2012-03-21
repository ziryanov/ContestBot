//
//  AppDelegate.m
//  ContestBot
//
//  Created by Иван Зырянов on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Connection.h"

@implementation UIView(removeAllSubviews)

- (void)removeAllSubviews
{
    while (self.subviews.count)
    {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

@end

@implementation AppDelegate

@synthesize window, bot, exit, turn, bricks;
@synthesize width, height, squareSize;
@synthesize botX, botY;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    window.backgroundColor = [UIColor greenColor];
    [[Connection shared] setDelegate:self];
    [[Connection shared] connect];
    return YES;
}

static CGFloat topY = 25;
- (void)fieldReceived:(NSDictionary*)field
{
    [window removeAllSubviews];

    width = [[field objectForKey:@"width"] intValue];
    height = [[field objectForKey:@"height"] intValue];
    squareSize = 320. / width;
    for (int i = 0; i < width; i++)
    {
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(squareSize * i, topY, 1, 320)];
        line.backgroundColor = [UIColor redColor];
        [window addSubview:line];
    }
    for (int i = 0; i < height + 1; i++)
    {
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, topY + squareSize * i, 320, 1)];
        line.backgroundColor = [UIColor redColor];
        [window addSubview:line];
    }
    self.bricks = [NSMutableArray arrayWithCapacity:width];
    for (int i = 0; i < width; i++)
    {
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:height];
        for (int j = 0; j < height; j++)
            [array addObject:[NSNull null]];
        [bricks addObject:array];
    }
    
    self.bot = [[UIView alloc] initWithFrame:CGRectZero];
    bot.backgroundColor = [UIColor redColor];
    [window addSubview:bot];
    
    self.exit = [[UIView alloc] initWithFrame:CGRectZero];
    exit.backgroundColor = [UIColor yellowColor];
    
    self.turn = [[UILabel alloc] initWithFrame:CGRectMake(20, 460, 300, 20)];
    turn.backgroundColor = [UIColor clearColor];
    [window addSubview:turn];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(75, 410, 50, 50);
    [button setTitle:@"l" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MoveLeft;
    [window addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(135, 410, 50, 50);
    [button setTitle:@"d" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MoveDown;
    [window addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(195, 410, 50, 50);
    [button setTitle:@"r" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MoveRight;
    [window addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(135, 355, 50, 50);
    [button setTitle:@"u" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = MoveUp;
    [window addSubview:button];
}

- (void)checkBricks:(BOOL)isBricks array:(NSArray*)array
{
    for (NSArray* point in array)
    {
        int ax = [[point objectAtIndex:0] intValue];
        int ay = [[point objectAtIndex:1] intValue];
        if ([[[bricks objectAtIndex:ax] objectAtIndex:ay] isKindOfClass:[NSNull class]])
        {
            [[bricks objectAtIndex:ax] replaceObjectAtIndex:ay withObject:[NSNumber numberWithBool:isBricks]];
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake(ax * squareSize + 1, topY + ay * squareSize + 1, squareSize - 1, squareSize - 1)];
            view.backgroundColor = (isBricks)?[UIColor blackColor]:[UIColor whiteColor];
            [window addSubview:view];
        }
    }
}

- (BOOL)checkMove:(int)move
{
    switch (move)
    {
        case MoveUp:
            return (botY > 0 && ![[[bricks objectAtIndex:botX] objectAtIndex:botY - 1] boolValue]);
        case MoveDown:
            return (botY < height - 1 && ![[[bricks objectAtIndex:botX] objectAtIndex:botY + 1] boolValue]);
        case MoveLeft:
            return (botX > 0 && ![[[bricks objectAtIndex:botX - 1] objectAtIndex:botY] boolValue]);
        case MoveRight:
            return (botX < width - 1 && ![[[bricks objectAtIndex:botX + 1] objectAtIndex:botY] boolValue]);
    }
    return NO;
}

- (int)getMove
{
    int move = MoveStay + 1 + rand() % 4;
    while (![self checkMove:move])
    {
        move = MoveStay + 1 + rand() % 4;
    }
    return move;
}

- (void)turnReceived:(NSDictionary*)dict
{
    turn.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"turn_no"]];   
    NSArray* bot_position = [dict objectForKey:@"bot_position"];
    botX = [[bot_position objectAtIndex:0] intValue];
    botY = [[bot_position objectAtIndex:1] intValue];
    bot.frame = CGRectMake(botX * squareSize + 2, topY + botY * squareSize + 2, squareSize - 3, squareSize - 3);
    
    [self checkBricks:YES array:[dict objectForKey:@"bricks"]];
    [self checkBricks:NO array:[dict objectForKey:@"empty"]];
    
    if ([[dict objectForKey:@"exits"] count] && ![exit superview])
    {
        NSArray* exitDict = [[dict objectForKey:@"exits"] objectAtIndex:0];
        exit.frame = CGRectMake(squareSize * [[exitDict objectAtIndex:0] intValue] + 1, topY + squareSize * [[exitDict objectAtIndex:1] intValue] + 1, squareSize - 1, squareSize - 1);
        [window addSubview:exit];
    }
    
    [window bringSubviewToFront:bot];
    
//    static int random = 0;
//    int prev = random;
//    if (![self checkMove:random])
//       random = [self getMove];
//    NSLog(@"send %d", random);
//    [[Connection shared] sendMove:random];
//    if ((prev == MoveUp && random == MoveDown) || (prev == MoveDown && random == MoveUp) || (prev == MoveLeft && random == MoveRight) || (prev == MoveRight && random == MoveLeft))
//        random = 0;
}

- (void)btnPressed:(UIButton*)btn
{
    if ([self checkMove:btn.tag])
        [[Connection shared] sendMove:btn.tag];
}


@end
