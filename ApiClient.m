//
//  ApiClient.m
//  ApiProject
//
//  Created by Chris Lavender on 12/9/11.
//  Copyright (c) 2011 TouchFrame. All rights reserved.
//

#import "ApiClient.h"
#import "Reachability.h"
#import "SBJSON.h"

@interface ApiClient()
@property (strong, nonatomic) NSOperationQueue  *opQueue;
@property (strong, nonatomic) SBJSON *jsonParser;
@end

@implementation ApiClient
@synthesize opQueue = _opQueue;

#pragma mark- ApiErrorChecking
- (BOOL)checkForAPIError:(id)incomingData error:(NSError **)anError 
{
    BOOL result = NO;
    
    if ([incomingData isKindOfClass:[NSDictionary class]]) 
    {
        // CL: It's a dictionary so check for an error code
        NSDictionary *responseDict = incomingData;
        
        if([responseDict objectForKey:@"error"])
        {  
            result = YES;

            if (anError != NULL) {
                NSString *description = [incomingData objectForKey:@"error"];
                // Make and return custom domain error.
                NSDictionary *userDict = [NSDictionary dictionaryWithObject:description forKey:kAPIErrorKey];
                *anError = [[NSError alloc] initWithDomain:@"TouchFrameAPI" code:0 userInfo:userDict];
            }
        }
    }
    return result;
}

#pragma mark- Send Request Methods
- (void)sendRequestUsingNSURLConnectionWithURLRequest:(NSURLRequest *)request andCallback:(CallbackHandlerBlock)handler
{
    __weak ApiClient *blockSelf = self;
    
    // CL: build a block to be run asynchronously
    void (^responseBlock)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        
#if _LogResponses_
        printf("REPONSE:\n%s\n\n",[[[NSString alloc] initWithBytes:[data bytes] 
                                                        length:[data length] 
                                                      encoding:NSISOLatin1StringEncoding] UTF8String]);
#endif
        
        id result = nil;
        // CL: http errors would be caught here.
        if (error) {
            NSLog(@"[%@ %@] HTTP error: %@", NSStringFromClass([blockSelf class]), NSStringFromSelector(_cmd), error.localizedDescription);
            result = error;
        }
        else {
        // CL: parse the JSON
            if (data) {
                result = [NSJSONSerialization JSONObjectWithData:data 
                                                          options:NSJSONReadingMutableContainers 
                                                            error:&error];
            }
            else {
                result = nil;
            }
            // CL: json errors would be caught here.
            if (error) {
                NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([blockSelf class]), NSStringFromSelector(_cmd), error.localizedDescription);
#if _LogResponses_
#else
                // CL: if it isn't valid JSON, what the hell is it?
                NSLog(@"BAD JSON Data as string:\n%@\n",[[NSString alloc] initWithBytes:[data bytes]
                                                                                 length:[data length] 
                                                                               encoding:NSISOLatin1StringEncoding]);
#endif
                
                result = error;
            }
            // CL: Check for any API errors.
            else if ([blockSelf checkForAPIError:result error:&error]) {
                //CL: if there's an error make the NSError object the result.
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

- (void)sendRequestUsingGcdWithURLRequest:(NSURLRequest *)request andCallback:(void (^)(id))handler
{
    __weak ApiClient *blockSelf = self;
   
    void (^requestBlock)(void) = ^{
       
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        id results = nil;
    
        // CL: http errors would be caught here.
        if (error) {
             NSLog(@"[%@ %@] HTTP error: %@", NSStringFromClass([blockSelf class]), NSStringFromSelector(_cmd), error.localizedDescription);
             results = error;
        } else {
             // CL: convert NSURLResponse to an NSString
             NSString *jsonString = [[NSString alloc] initWithBytes:[responseData bytes]
                                                             length:[responseData length]
                                                           encoding:NSISOLatin1StringEncoding];           
            // CL: parse the JSON
            results = jsonString ? [self.jsonParser objectWithString:jsonString error:&error] : nil;
       
           // CL: json errors would be caught here.
            if (error) {
                   NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([blockSelf class]), NSStringFromSelector(_cmd), error.localizedDescription);
                   results = error;
            }
            // CL: Check for any Miso API errors.
            else if ([blockSelf checkForAPIError:results error:&error]) {
                //CL: if there's an error make the NSError object the result.
                if (error) results = error;
           }
        }
      	
        // If no errors send result to the completion block
        handler(results);
    };
    	
      dispatch_queue_t downloadQueue = dispatch_queue_create("BDXDownloadQueue", NULL);
      dispatch_async(downloadQueue, requestBlock);
      dispatch_release(downloadQueue);
}

#pragma mark- ApiClientProtocol Method Implementations
- (void)requestWithPath:(NSString *)path 
                 method:(NSString *)method 
              getParams:(NSDictionary *)getParams 
             postParams:(NSDictionary *)postParams 
            andCallback:(CallbackHandlerBlock)handler
{
    NSString *pathString = nil;
    if (method) {
        pathString = [NSString stringWithFormat:@"/%@/%@.json?",path,method];
    }
    else {
        pathString = [NSString stringWithFormat:@"/%@.json?",path];
    }

    NSString *urlString = nil;
    // build the complete url"
    if (getParams) {
        urlString = [NSString stringWithFormat:@"%@%@%@", kAPIBaseUrl, pathString, [getParams urlEncodedString]];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@%@", kAPIBaseUrl, pathString];
    }

#if _LogRequests_
    NSLog(@" URL: %@", urlString);
#endif
    
    NSURL *url = [NSURL URLWithString:urlString];  
    
    NSURLRequest *request;
    if (postParams)
    {
        NSString *post          = [postParams urlEncodedString];
#if _LogRequests_
        NSLog(@"POST: %@", post);
#endif
        NSData *postData        = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength    = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url];
        [postRequest setHTTPMethod:@"POST"];
        [postRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [postRequest setHTTPBody:postData];
        
        request = postRequest;
    }
    else 
    {
        request   = [NSURLRequest requestWithURL:url];
    }
    
    // CL: check for Reachability.
    if ([[self class] internetIsReachable]) 
    {
        [self sendRequestUsingNSURLConnectionWithURLRequest:request andCallback:handler];
        // [self sendRequestUsingGcdWithURLRequest:request andCallback:handler];
    }
}

#pragma mark- Setter/Getter Overrides
- (NSOperationQueue *)opQueue
{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc] init];
    }
    return _opQueue;
}

- (SBJSON *)jsonParser
{
    if (!_jsonParser) {
        _jsonParser = [[SBJSON alloc]init];
    }
    return _jsonParser;
}

#pragma mark- Reachability Methods
+ (BOOL)internetIsReachable 
{
    BOOL result = YES;

    Reachability *r = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" 
                                                        message:@"You do not seem to have internet connectivity at this time." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles: nil];
        [alert show];
        
		result = NO;
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
    
    // CL: if the Dictionary item is an Array of other objects
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
    for (id key in self) 
    {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end