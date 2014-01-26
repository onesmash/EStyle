//
//  EStyleRuleset.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EStyleRuleset : NSObject {
@private
    NSMutableDictionary *_rawRuleset;
}

@property (readonly, copy) NSString *pesudoClass;

//@property (readonly, strong) NSDictionary *ruleset;

- (id)initWithPesudoclass:(NSString *)pesudoClass;

- (id)initWithPesudoclass:(NSString *)pesudoClass from:(NSDictionary *)dict;

- (void)addRule:(NSString *)rule withValue:(NSString *)action;

- (void)addRulesFrom:(NSDictionary *)rules;

- (void)removeRule:(NSString *)rule;

- (void)merge:(EStyleRuleset *)ruleset;

- (void)enumerateRulesAndActionsUsingBlock:(void (^)(id rule, id action, BOOL *stop))block;

- (NSString *)actionForRule:(NSString *)rule;

@end
