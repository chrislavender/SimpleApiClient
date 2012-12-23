//
//  ApiClient+AuthParams.m
//  SimpleApiClientExample
//
//  Created by Chris Lavender on 12/13/12.
//  Copyright (c) 2012 Chris Lavender. All rights reserved.
//

#import "ApiClient+AuthParams.h"
#import "AppDelegate.h"

@implementation ApiClient (AuthParams)

/*
 in a method like this, you can pack any needed authorizations
 For example, user_id, auth_token, api_key... etc.
*/


+ (NSDictionary *)authorizationGetParams
{
    NSDictionary *userGetParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   kApiKey, @"api_key",
                                   nil];
    
    
     // One implementation would be to hold a pointer to the "current user" via a property in the AppDelegate.
     // In this case, you can get a user_id and/or auth_token via code like:
    
//     NSDictionary *userGetParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    ((AppDelegate *)[UIApplication sharedApplication].delegate).currentUser.unique_id, @"user_id",
//                                    ((AppDelegate *)[UIApplication sharedApplication].delegate).currentUser.auth_token, @"auth_token",
//                                    nil];
    

    return userGetParams;
}

+ (NSDictionary *)packAuthorizationGetParamsWithGetParams:(NSDictionary *)getParams
{
    NSDictionary *packedParams = [[self class] authorizationGetParams];
    
    if (getParams) {
        NSMutableDictionary *combinedParams = [NSMutableDictionary dictionaryWithDictionary:packedParams];
        [combinedParams addEntriesFromDictionary:getParams];
        packedParams = [NSDictionary dictionaryWithDictionary:combinedParams];
    }
    
    return packedParams;
}

@end
