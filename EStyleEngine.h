//
//  EStyleEngine.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EStyleable.h"

@class EStylesheet;

@interface EStyleEngine : NSObject

+ (id)instance;

+ (NSArray *)selectFromStyleable:(id<EStyleable>)styleable usingSelector:(NSString *)source;

+ (id)stylesheetFromSource:(NSString *)source;

+ (id)stylesheetFromFile:(NSString *)filePath;

+ (id)stylesheetFromFile:(NSString *)filePath withPrefix:(NSString *)prefix;

+ (void)applyStylesheet:(EStylesheet *)stylesheet toStyleable:(id<EStyleable>)styleable;

+ (void)applyStylesheet:(EStylesheet *)stylesheet toController:(UIViewController *)controller;

//+ (void)updateStyleForAllView;

+ (void)updateControllerStyle:(UIViewController *)controller;

+ (void)updateStyle:(id<EStyleable>)styleable;

+ (void)updateStyleNonRecursively:(id<EStyleable>)styleable;

@end
