//
//  EStyleHelper.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-22.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStyleHelper.h"

@implementation EStyleHelper

+ (NSString *)bundleResource:(NSString *)path {
    return [path substringFromIndex:9];
}

+ (NSString *)documentsResource:(NSString *)path {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[path substringFromIndex:12]];
}

@end
