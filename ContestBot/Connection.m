//
//  Connection.m
//  ContestBot
//
//  Created by Иван Зырянов on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Connection.h"

#define Token @"1f1490e7aa81e9229de19886"

@implementation Connection
@synthesize connection, receivedData;

+ (id)shared
{
    static Connection* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [Connection new];
    });
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.receivedData = [NSMutableData data];
    }
    return self;
}

- (void)start
{
    self.connection = [[NSURLConnection alloc] initWithRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"cloudcontest.ru:8000"]] delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

@end
