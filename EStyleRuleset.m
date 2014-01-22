//
//  EStyleRuleset.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStyleRuleset.h"
#import "EStyleEngine.h"

#define RULE_PRIORTY_LIST_BEGIN \
rulePriorty = [@{

#define DEF_RULE_PRIORTY(rule) \
@#rule: [NSString stringWithFormat:@"%d", priorty++]

#define RULE_PEIORTY_LIST_END \
} retain];

static NSDictionary *rulePriorty = nil;

static NSInteger priorty = 0;

@implementation EStyleRuleset

- (id)init {
    self = [super init];
    if(self) {
        _pesudoClass = [PSEUDO_CLASS(_none_) copy];
        _rawRuleset = [[NSMutableDictionary alloc] init];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            RULE_PRIORTY_LIST_BEGIN
                DEF_RULE_PRIORTY(opacity),
                DEF_RULE_PRIORTY(hidden),
                DEF_RULE_PRIORTY(background_color),
                DEF_RULE_PRIORTY(border_radius),
                DEF_RULE_PRIORTY(border_width),
                DEF_RULE_PRIORTY(border_color),
                DEF_RULE_PRIORTY(width),
                DEF_RULE_PRIORTY(height),
                DEF_RULE_PRIORTY(left),
                DEF_RULE_PRIORTY(top),
                DEF_RULE_PRIORTY(right),
                DEF_RULE_PRIORTY(bottom),
                DEF_RULE_PRIORTY(halign),
                DEF_RULE_PRIORTY(valign)
            RULE_PEIORTY_LIST_END

        });
    }
    return self;
}

- (id)initWithPesudoclass:(NSString *)pesudoClass {
    self = [self init];
    if(self) {
        [_pesudoClass release];
        _pesudoClass = [pesudoClass copy];
    }
    return self;
}

- (id)initWithPesudoclass:(NSString *)pesudoClass from:(NSDictionary *)dict {
    self = [self initWithPesudoclass:pesudoClass];
    if(self) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self addRule:key withValue:obj];
        }];
    }
    return self;
}

- (void)dealloc {
    [_rawRuleset release];
    [_pesudoClass release];
    [super dealloc];
}

- (NSDictionary *)ruleset {
    return _rawRuleset;
}

- (void)addRule:(NSString *)rule withValue:(NSString *)value {
    NSString *ruleWithPriorty = [NSString stringWithFormat:@"%@-%@", rule, [rulePriorty objectForKey:rule]];
    [_rawRuleset setObject:value forKey:ruleWithPriorty];
}

- (void)addRulesFrom:(NSDictionary *)rules {
    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self addRule:key withValue:obj];
    }];
}

- (void)merge:(EStyleRuleset *)ruleset {
    if([self.pesudoClass isEqualToString:ruleset.pesudoClass]) {
        [ruleset.ruleset enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self addRule:key withValue:obj];
        }];
    } else {
        return;
    }
}

- (void)enumerateRulesAndActionsUsingBlock:(void (^)(id , id , BOOL *))block {
    NSArray *allRules = [_rawRuleset allKeys];
    NSArray *sortedRules = [allRules sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        NSString *firstPriorty = [obj1 componentsSeparatedByString:@"-"][1];
        NSString *secondPriorty = [obj2 componentsSeparatedByString:@"-"][1];
        if(firstPriorty.integerValue > secondPriorty.integerValue) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if(firstPriorty.integerValue < secondPriorty.integerValue) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    BOOL stop = NO;
    
    for (NSString *rule in sortedRules) {
        NSString *realRule = [rule componentsSeparatedByString:@"-"][0];
        if(!stop) block(realRule, [_rawRuleset objectForKey:rule], &stop);
        else break;
    }
}

@end
