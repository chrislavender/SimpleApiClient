//
//  ApiClient.h
//  ApiProject
//
//  Created by Chris Lavender on 12/9/11.
//  Copyright (c) 2011 TouchFrame. All rights reserved.
//

/*
 The ApiClient is the request handling portion of the 
 API. It receives all elements of a request, constructs the 
 url, does a reachability check, and initiates the request.  
 It also recieves the response, converts the JSON data, and 
 does HTTP, JSON, and  API error checking. If an error is 
 found, it is sent back up the chain via the requestor's 
 callback.
*/

#import <Foundation/Foundation.h>

typedef void (^CallbackHandlerBlock)(id);

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
