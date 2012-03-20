//
//  Connection.h
//  ContestBot
//
//  Created by Иван Зырянов on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject

+ (id)shared;

- (void)start;

//private
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* receivedData;

@end
