//
//  EStyleEngine.h
//
//  Created by Xuhui on 14-1-13.
//

#import <Foundation/Foundation.h>
#import "EStyleable.h"

@class EStylesheet;

@interface EStyleEngine : NSObject

+ (id)instance;

+ (NSArray *)selectFromStyleable:(id<EStyleable>)styleable usingSelector:(NSString *)source;

+ (id<EStyleable>)selectFromStyleable:(id<EStyleable>)styleable byID:(NSString *)Id;

+ (NSArray *)selectFromStyleable:(id<EStyleable>)styleable byClasses:(NSSet *)classes;

+ (id)stylesheetFromSource:(NSString *)source;

+ (id)stylesheetFromFile:(NSString *)filePath;

+ (id)stylesheetFromFile:(NSString *)filePath withPrefix:(NSString *)prefix;

+ (void)applyStylesheet:(EStylesheet *)stylesheet toStyleable:(id<EStyleable>)styleable;

+ (void)applyStylesheet:(EStylesheet *)stylesheet toController:(UIViewController *)controller;

//+ (void)updateStyleForAllView;

+ (void)updateControllerStyle:(UIViewController *)controller;

+ (void)updateStyle:(id<EStyleable>)styleable;

+ (NSArray *)updateStyleNonRecursively:(id<EStyleable>)styleable isPadding:(BOOL)isPadding;

+ (void)updateStyleRules:(NSDictionary *)rules withPseudoClass:(NSString *)pseudoClass toStyleavle:(id<EStyleable>)styleable;

+ (id)buildViewFromDict:(NSDictionary *)dict;

+ (id)buildViewFromSource:(NSString *)source;

+ (id)buildViewFromConfigNonRecursively:(NSDictionary *)config;

@end
