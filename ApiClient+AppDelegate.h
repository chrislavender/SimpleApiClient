//
//  ApiClient+AppDelegate.h
//  Braindex
//
//  Created by Chris Lavender on 12/16/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient.h"

/*
 This category assumes that you're AppDelegate has a getter called "apiClient".
 If it doens't, the client class method will return nil.
 */

@interface ApiClient (AppDelegate)

+ (ApiClient *)client;

@end
