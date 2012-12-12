//
//  ApiClient+Singleton.h
//  Braindex
//
//  Created by Chris Lavender on 6/19/12.
//  Copyright (c) 2012 TouchFrame. All rights reserved.
//

#import "ApiClient.h"

@interface ApiClient (Singleton)

+ (ApiClient *)shared;

@end
