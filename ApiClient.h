//
//  ApiClient.h
//  ApiProject
//
//  Created by Chris Lavender on 12/9/11.
//  Copyright (c) 2011 Chris Lavender. All rights reserved.
//

/*
 The ApiClient does a reachability check, and initiates the request.  
 It also recieves the response, converts the JSON data, and 
 does HTTP, JSON, and  API error checking. If an error is 
 found, it is sent back up the chain via the requestor's 
 callback.
*/

#import <Foundation/Foundation.h>

#define _LogRequests_ 1
#define _LogResponses_ 1

typedef void (^CallbackHandlerBlock)(id);

/* 
 notification sent if the ApiClient throws an alert
 this is so your view controllers can be notified
*/
NSString *const kAlertViewPresentedNotification;


@interface ApiClient : NSObject

@property (strong, nonatomic, readonly) NSString *baseUrl;

/*
 designated initializer. 
 Give the base url in this form: http://api.some-site-url.com
*/
- (id)initWithBaseUrl:(NSString *)urlString;

/*
 Constructs an NSURLRequest with the given arguments
 The handler will run when the request returns.
 In iOS 5 and newer (ARC), if the owner of the handler is
 automatically nil'd when dealloc'd, so there shouldn't be
 a need for cancelling any sent requests. Without ARC this
 scenario will cause a crash.
*/
- (void)requestWithPath:(NSString *)path
                 method:(NSString *)method
              getParams:(NSDictionary *)getParams
             postParams:(NSDictionary *)postParams
            andCallback:(CallbackHandlerBlock)handler;

/*
 added here as a convience for other classes
*/
+ (BOOL)internetIsReachable;

@end

// Category for NSDictionary to convert 
// key/values params to NSString
@interface NSDictionary (UrlEncoding)
-(NSString *) urlEncodedString;
@end
