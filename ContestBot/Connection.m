//
//  Connection.m
//  ContestBot
//
//  Created by Иван Зырянов on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Connection.h"
#import "JSONKit.h"
#import "AsyncSocket.h"

#define Token @"74a9ca2820e701352511df5e"

enum
{
    StateStarted = 1,
    StateLogining,
    StateLogined
};

@implementation Connection
@synthesize socket, delegate;

+ (id)shared
{
    static Connection* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [Connection new];
    });
    return instance;
}

- (void)connect
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    [socket connectToHost:@"cloudcontest.ru" onPort:8000 error:0];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"connected!");
    [socket readDataWithTimeout:-1 tag:StateStarted];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"willDisconnectWithError");  
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"onSocketDidDisconnect");  
}

- (void)sendMove:(Moves)move
{
    NSDictionary* dict;
    switch (move)
    {
        case MoveStay:
            dict = [NSDictionary dictionaryWithObject:@"s" forKey:@"command"];
            break;
        case MoveUp:
            dict = [NSDictionary dictionaryWithObject:@"u" forKey:@"command"];
        break;
        case MoveDown:
            dict = [NSDictionary dictionaryWithObject:@"d" forKey:@"command"];
            break;
        case MoveLeft:
            dict = [NSDictionary dictionaryWithObject:@"l" forKey:@"command"];
            break;
        case MoveRight:
            dict = [NSDictionary dictionaryWithObject:@"r" forKey:@"command"];
            break;
    }
    [self sendDict:dict];
}

- (void)sendDict:(NSDictionary*)dict
{
    NSString* string = [[dict JSONString] stringByAppendingString:@"\n"];
    [socket writeData:[string dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSLog(@"ddiRead %@\n", string);
    NSMutableArray* msgs = [NSMutableArray array];
    for (NSString* str in [string componentsSeparatedByString:@"\n"])
    {
        if ([str objectFromJSONString])
            [msgs addObject:[str objectFromJSONString]];
    }
    
    //NSLog(@"msgs:\n%@", msgs);
    
    if (tag == StateStarted)
    {
        NSDictionary* dict = [msgs objectAtIndex:0];
        if (![dict isKindOfClass:[NSDictionary class]])
            return;
        if (![[dict objectForKey:@"status"] isEqualToString:@"ok"])
            return;
        
        NSDictionary* loginDict = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"message_type", Token, @"user_token", nil];
        [self sendDict:loginDict];
    }
    else if (tag == StateLogining)
    {
        NSDictionary* dict = [msgs objectAtIndex:0];
        if (![dict isKindOfClass:[NSDictionary class]])
            return;
        if (![[dict objectForKey:@"status"] isEqualToString:@"ok"])
            return;
        
        [delegate fieldReceived:[msgs objectAtIndex:1]];
        [delegate turnReceived:[msgs objectAtIndex:2]];
    }
    else if (tag == StateLogined)
    {
        //NSDictionary* dict = [msgs objectAtIndex:0];
        [delegate turnReceived:[msgs lastObject]];
    }
    
    [socket readDataWithTimeout:-1 tag:(tag < StateLogined)?tag + 1:tag];
}

@end
