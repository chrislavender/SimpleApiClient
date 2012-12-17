//
//  ApiClient+AppDelegate.m
//  Braindex
//
//  Created by Chris Lavender on 12/16/12.
//  Copyright (c) 2012 TouchFrame. All rights reserved.
//

#import "ApiClient+AppDelegate.h"
#import "AppDelegate.h"

@implementation ApiClient (AppDelegate)

+ (ApiClient *)client
{
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).apiClient;
}

@end
