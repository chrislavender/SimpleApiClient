//
//  ApiClient.m
//  ApiProject
//
//  Created by Chris Lavender on 12/9/11.
//  Copyright (c) 2011 Chris Lavender. All rights reserved.
//

#import "ApiClient.h"

@interface ApiClient()
@property (strong, nonatomic) NSOperationQueue  *opQueue;
@property (strong, nonatomic, readwrite) Reachability *reachability;
@end

NSString *const kAlertViewPresentedNotification = @"AlertViewPresentedNotification";

@implementation ApiClient

+ (ApiClient *)shared
{
    static ApiClient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ApiClient alloc] initWithBaseUrl:kAPIBaseUrl];
    });
    return shared;
}

- (NSOperationQueue *)opQueue
{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc] init];
    }
    return _opQueue;
}

- (id)initWithBaseUrl:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _baseUrl = urlString;
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
    }
    return self;
}

#pragma mark- Build & Send Request Methods
- (void)requestWithPath:(NSString *)path
                 method:(NSString *)method
              getParams:(NSDictionary *)getParams
             postParams:(NSDictionary *)postParams
            andCallback:(CallbackHandlerBlock)handler
{
    NSString *pathString = nil;
    
    if (method) {
        pathString = [NSString stringWithFormat:@"/%@/%@?",path,method];
        
    } else {
        pathString = [NSString stringWithFormat:@"/%@?",path];
        
    }
    
    NSString *urlString = nil;
    
    // build the complete url"
    if (getParams) {
        urlString = [NSString stringWithFormat:@"%@%@%@", self.baseUrl, pathString, [getParams urlEncodedString]];
        
    } else {
        urlString = [NSString stringWithFormat:@"%@%@", self.baseUrl, pathString];
        
    }
    
#ifdef _LogRequests_
    NSLog(@" URL: %@", urlString);
#endif
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request;
    
    if (postParams) {
        
        NSString *post = [postParams urlEncodedString];
#ifdef _LogRequests_
        NSLog(@"POST: %@", post);
#endif
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
        [postRequest setHTTPMethod:@"POST"];
        [postRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [postRequest setHTTPBody:postData];
        
        request = postRequest;
        
    } else {
        request = [NSURLRequest requestWithURL:url];
        
    }
    
    [self sendRequestUsingNSURLConnectionWithURLRequest:request
                                            andCallback:handler];
    
}

- (void)sendRequestUsingNSURLConnectionWithURLRequest:(NSURLRequest *)request
                                          andCallback:(CallbackHandlerBlock)handler
{
    __weak ApiClient *weakSelf = self;
    
    // build a block to be run asynchronously
    void (^responseBlock)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        
        ApiClient *strongSelf = weakSelf;
        
#ifdef _LogResponses_
        printf("REPONSE:\n%s\n\n",[[[NSString alloc] initWithBytes:[data bytes] 
                                                            length:[data length] 
                                                          encoding:NSISOLatin1StringEncoding] UTF8String]);
#endif
        
        id result = nil;
        // http errors would be caught here.
        if (error) {
            NSLog(@"[%@ %@] HTTP error: %@",
                  NSStringFromClass([strongSelf class]),
                  NSStringFromSelector(_cmd),
                  error.localizedDescription);
            
            result = error;
        
        } else {
        // parse the JSON
            
            if (data) {
                result = [NSJSONSerialization JSONObjectWithData:data 
                                                         options:NSJSONReadingMutableContainers 
                                                           error:&error];
            
            } else {
                result = nil;
            
            }
            
            // json errors would be caught here.
            if (error) {
                
                NSLog(@"[%@ %@] JSON error: %@",
                      NSStringFromClass([strongSelf class]),
                      NSStringFromSelector(_cmd),
                      error.localizedDescription);
#ifndef _LogResponses_
                // if it isn't valid JSON, what the hell is it?
                NSLog(@"BAD JSON Data as string:\n%@\n",[[NSString alloc] initWithBytes:[data bytes]
                                                                                 length:[data length] 
                                                                               encoding:NSISOLatin1StringEncoding]);
#endif
                
                result = error;
            
            // Check for any API errors.
            } else if ([strongSelf checkForAPIError:result error:&error]) {
                // if there's an error, make the NSError object the result.
                if (error) result = error;
            }

        }
        // send result to the completion block
        handler(result);
    };

    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:self.opQueue 
                           completionHandler:responseBlock];
}

#pragma mark- ApiErrorChecking
- (BOOL)checkForAPIError:(id)incomingData error:(NSError **)anError
{
    BOOL result = NO;
    // it should be a dictionary
    if ([incomingData isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *responseDict = incomingData;
        
        // check for an error code
        if([responseDict valueForKey:@"error"]) {
            
            result = YES;
            
            // make sure we weren't passed a NULL pointer
            if (anError != NULL) {
                
                // set the provided pointer to a custom domain error.
                NSString *description = incomingData[@"error"];
                NSDictionary *userDict = @{NSLocalizedDescriptionKey: description};
                
                *anError = [[NSError alloc] initWithDomain:@"API"
                                                      code:0
                                                  userInfo:userDict];
            }
        }
    }
    
    return result;
}

@end

#pragma mark- NSDictionary API Specific Category Implementation

// helper function: get the string form of any object
static NSString * toString(id object) {
    
    return [NSString stringWithFormat: @"%@", object];

}

// helper function: get the url encoded string form of any object
static NSString * urlEncode(id object) {
    
    NSString * string = nil;
    
    // if the Dictionary item is an Array of other objects
    // than we need to pull them out and prep them.
    // otherwise, the memory addresses are sent rather than the values
    if ([object isKindOfClass:[NSArray class]]) string = [object componentsJoinedByString:@","];
    else string = toString(object);
    
    NSString * encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                     (__bridge CFStringRef)string,
                                                                                                     NULL,
                                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                     kCFStringEncodingUTF8);
    return encodedString;
}

@implementation NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString
{
    NSMutableArray *parts = [NSMutableArray array];
    
    for (id key in self) {
        
        id value = self[key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    
    }
    
    return [parts componentsJoinedByString: @"&"];
}

@end

