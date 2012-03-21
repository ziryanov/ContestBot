//
//  Connection.h
//  ContestBot
//
//  Created by Иван Зырянов on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConnectionDelegate <NSObject>

- (void)fieldReceived:(NSDictionary*)field;
- (void)turnReceived:(NSDictionary*)field;

@end

@class AsyncSocket;
@interface Connection : NSObject

+ (id)shared;

@property (nonatomic, weak) id<ConnectionDelegate> delegate;

- (void)connect;
typedef enum
{
    MoveStay = 0,
    MoveUp,
    MoveDown,
    MoveLeft,
    MoveRight
} Moves;
- (void)sendMove:(Moves)move;

//private
@property (nonatomic, strong) AsyncSocket* socket;

@end
