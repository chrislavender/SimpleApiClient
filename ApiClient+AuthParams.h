//
//  ApiClient+AuthParams.h
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient.h"

@interface ApiClient (AuthParams)

+ (NSDictionary *)authorizationGetParams;
+ (NSDictionary *)packAuthorizationGetParamsWithGetParams:(NSDictionary *)getParams;

@end
