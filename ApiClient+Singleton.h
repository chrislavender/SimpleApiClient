//
//  ApiClient+Singleton.h
//  Braindex
//
//  Created by Chris Lavender on 6/19/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient.h"

/*
 If you absolutely must use a Singleton (are you sure?)
 You can set the api base url below.
 
 This class uses dispatch_once to ensure no duplicates
 are created.
 */

#define _BaseUrl_ @"api.somesite.com"

@interface ApiClient (Singleton)

+ (ApiClient *)shared;

@end
