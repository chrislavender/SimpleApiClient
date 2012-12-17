//
//  ApiClient+AppDelegate.m
//  Braindex
//
//  Created by Chris Lavender on 12/16/12.
//  Copyright (c) 2012 TouchFrame. All rights reserved.
//

#import "ApiClient+AppDelegate.h"

@implementation ApiClient (AppDelegate)

+ (ApiClient *)client
{
    ApiClient *client = nil;
    
    id appDel = [[UIApplication sharedApplication] delegate];
    
    if ([appDel respondsToSelector:@selector(apiClient)]) {
        client = [appDel valueForKey:@"apiClient"];
    } 
    
    return client;
}

@end
