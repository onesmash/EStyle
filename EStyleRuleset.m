//
//  EStyleRuleset.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStyleRuleset.h"
#import "EStyleHelper.h"

#define RULE_PRIORTY_LIST_BEGIN \
rulePriorty = @{

#define DEF_RULE_PRIORTY(rule) \
@#rule: [NSString stringWithFormat:@"%d", priorty++]

#define RULE_PEIORTY_LIST_END \
};

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
                DEF_RULE_PRIORTY(class),
                DEF_RULE_PRIORTY(initWithFrame),
                DEF_RULE_PRIORTY(initWithStyle_reuseIdentifier),
                DEF_RULE_PRIORTY(styleId),
                DEF_RULE_PRIORTY(styleClass),
                DEF_RULE_PRIORTY(frame),
                DEF_RULE_PRIORTY(subviews),
                DEF_RULE_PRIORTY(opacity),
                DEF_RULE_PRIORTY(hidden),
                DEF_RULE_PRIORTY(background_color),
                DEF_RULE_PRIORTY(background_image),
                DEF_RULE_PRIORTY(border_radius),
                DEF_RULE_PRIORTY(border_width),
                DEF_RULE_PRIORTY(border_color),
                DEF_RULE_PRIORTY(text),
                DEF_RULE_PRIORTY(text_color),
                DEF_RULE_PRIORTY(text_shadow),
                DEF_RULE_PRIORTY(font),
                DEF_RULE_PRIORTY(image),
                DEF_RULE_PRIORTY(image_web),
                DEF_RULE_PRIORTY(width),
                DEF_RULE_PRIORTY(height),
                DEF_RULE_PRIORTY(left),
                DEF_RULE_PRIORTY(top),
                DEF_RULE_PRIORTY(right),
                DEF_RULE_PRIORTY(bottom),
                DEF_RULE_PRIORTY(padding_top),
                DEF_RULE_PRIORTY(padding_left),
                DEF_RULE_PRIORTY(padding_bottom),
                DEF_RULE_PRIORTY(padding_right),
                DEF_RULE_PRIORTY(padding),
                DEF_RULE_PRIORTY(halign),
                DEF_RULE_PRIORTY(valign),
                DEF_RULE_PRIORTY(style)
            RULE_PEIORTY_LIST_END

        });
    }
    return self;
}

- (id)initWithPesudoclass:(NSString *)pesudoClass {
    self = [self init];
    if(self) {
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

- (NSDictionary *)ruleset {
    return _rawRuleset;
}

- (NSString *)ruleWithPriortyfFrom:(NSString *)rule {
    return [NSString stringWithFormat:@"%@-%@", rule, [rulePriorty objectForKey:rule]];
}

- (void)addRule:(NSString *)rule withValue:(NSString *)action {
    NSString *ruleWithPriorty = [self ruleWithPriortyfFrom:rule];
    [_rawRuleset setObject:action forKey:ruleWithPriorty];
}

- (void)addRulesFrom:(NSDictionary *)rules {
    [rules enumerateKeysAndObjectsUsingBlock:^(id rule, id action, BOOL *stop) {
        [self addRule:rule withValue:action];
    }];
}

- (void)removeRule:(NSString *)rule {
    NSString *ruleWithPriorty = [self ruleWithPriortyfFrom:rule];
    [_rawRuleset removeObjectForKey:ruleWithPriorty];
}

- (void)merge:(EStyleRuleset *)ruleset {
    if([self.pesudoClass isEqualToString:ruleset.pesudoClass]) {
        [ruleset.ruleset enumerateKeysAndObjectsUsingBlock:^(id rule, id action, BOOL *stop) {
            [_rawRuleset setObject:action forKey:rule];
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

- (NSString *)actionForRule:(NSString *)rule {
    NSString *ruleWithPriorty = [self ruleWithPriortyfFrom:rule];
    return [_rawRuleset objectForKey:ruleWithPriorty];
}

@end
