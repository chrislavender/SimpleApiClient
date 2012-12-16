//
//  ApiClient+Singleton.m
//  Braindex
//
//  Created by Chris Lavender on 6/19/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient+Singleton.h"

@implementation ApiClient (Singleton)

#pragma mark - Singleton Methods
static ApiClient *shared = nil;

// CL: Don't use @synchronized. Particularly for shared singletons
+ (ApiClient *)shared 
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ApiClient alloc] initWithBaseUrl:_BaseUrl_];
    });
    return shared;
} 

@end
