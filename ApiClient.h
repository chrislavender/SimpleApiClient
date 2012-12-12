//
//  ApiClient.h
//  ApiProject
//
//  Created by Chris Lavender on 12/9/11.
//  Copyright (c) 2011 GnarlyDogMusic. All rights reserved.
//

/*
 The ApiClient receives all elements of a request, constructs the 
 url, does a reachability check, and initiates the request.  
 It also recieves the response, converts the JSON data, and 
 does HTTP, JSON, and  API error checking. If an error is 
 found, it is sent back up the chain via the requestor's 
 callback.
 
 Note: this class assumes REST-ful JSON requests ending in .json
 this is can be easily modified however in 
 requestWithPath:method:getParams:postParams:andCallback
*/

#import <Foundation/Foundation.h>

#define _LogRequests_ 0
#define _LogResponses_ 0

typedef void (^CallbackHandlerBlock)(id);

NSString *const kAPIBaseUrl;
NSString *const kAlertViewPresentedNotification;

@interface ApiClient : NSObject

- (void)requestWithPath:(NSString *)path 
                 method:(NSString *)method 
              getParams:(NSDictionary *)getParams 
             postParams:(NSDictionary *)postParams 
            andCallback:(CallbackHandlerBlock)handler;

+ (BOOL)internetIsReachable;

@end

// Category for NSDictionary to convert 
// key/values get params to NSString
@interface NSDictionary (UrlEncoding)
-(NSString *) urlEncodedString;
@end
