//
//  FWUtility.m
//  BlogExplorer
//
//  Created by Allison on 15/3/9.
//
//

#import "FWUtility.h"

@implementation FWUtility

+ (BOOL)invalidString:(NSString *)value
{
    if (!value) {
        return YES;
    }
    
    if ([value length] == 0) {
        return YES;
    }
    
    return NO;
}

@end
