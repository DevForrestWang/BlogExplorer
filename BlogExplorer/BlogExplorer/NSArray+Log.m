//
//  NSArray+Log.m
//  BlogExplorer
//
//  Created by Allison on 15/6/18.
//
//

#import "NSArray+Log.h"

@implementation NSArray (Log)

// 数组打印中文解决方法
- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *str = [NSMutableString stringWithFormat:@"%lu (\n", (unsigned long)self.count];
    
    for (id obj in self) {
        [str appendFormat:@"\t%@, \n", obj];
    }
    
    [str appendString:@")"]; return str;
}

@end
