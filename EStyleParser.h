//
//  EStyleParser.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EStyleParser : NSObject

+ (NSDictionary *)parse:(NSString *)source;

+ (NSDictionary *)parseFromDict:(NSDictionary *)dict;

@end
