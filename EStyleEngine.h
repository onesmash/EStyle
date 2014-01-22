//
//  EStyleEngine.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+EStyling.h"

#define CONST_STRING(name, value) \
NSString *const name = @#value;

#define PSEUDO_CLASS(name) \
kPseudoClass_ ## name

#define DEF_PSEUDO_CLASS(name) \
CONST_STRING(PSEUDO_CLASS(name), name)

#define EXTERN_PSEUDO_CLASS(name) \
extern NSString *const PSEUDO_CLASS(name);

EXTERN_PSEUDO_CLASS(_none_)
EXTERN_PSEUDO_CLASS(normal)
EXTERN_PSEUDO_CLASS(selected)
EXTERN_PSEUDO_CLASS(highlighted)
EXTERN_PSEUDO_CLASS(disable)

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
