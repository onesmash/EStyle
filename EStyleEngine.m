//
//  EStyleEngine.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#include <objc/message.h>
#import "EStyleEngine.h"
#import "EStylesheet.h"
#import "EStyleRuleset.h"

DEF_PSEUDO_CLASS(_none_)
DEF_PSEUDO_CLASS(normal)
DEF_PSEUDO_CLASS(selected)
DEF_PSEUDO_CLASS(highlighted)
DEF_PSEUDO_CLASS(disable)

#define DEF_END \
}

#define RULE(name) \
kRule_ ## name

#define DEF_RULE(name) \
CONST_STRING(RULE(name), name)

#define DEF_RULE_ACTION(name) \
DEF_RULE(name) \
+ (void)apply_ ## name ## _to:(id)styleable param:(NSString *)value pesudoClass: pesudoClass

#define RULE_ACTION(name) \
NSSelectorFromString([NSString stringWithFormat:@"apply_%@_to:param:pesudoClass:", name])

#define RUN_RULE_ACTION(target, rule, value, pesudoClass) \
objc_msgSend([EStyleEngine class], RULE_ACTION(rule), target, value, pesudoClass)

#define STRING_TO_FUNC(type) \
_ ## type ## From:

#define DEF_STRING_TO(type) \
+ (type) STRING_TO_FUNC(type) (NSString *)value


#define STRING_TO(value, type) \
[EStyleEngine STRING_TO_FUNC(type) value]

#define SELECTOR(name) \
kSelector_ ## name

#define DEF_SELECTOR(name, value) \
CONST_STRING(SELECTOR(name), value)

#define SELECTOR_HASTYPE_OF(selector, type) \
([selector isEqualToString:SELECTOR(type)])

#define IS_SELECTOR(value) \
(![value hasPrefix:@"@"])

@interface EStyleEngine ()

@property (nonatomic, retain) NSCharacterSet *selectorSet;

@end

@implementation EStyleEngine

- (id)init {
    self = [super init];
    if(self) {
        _selectorSet = [[NSCharacterSet characterSetWithCharactersInString:@"\x20>+#."] retain];
    }
    return self;
}

+ (id)instance {
    static EStyleEngine *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[EStyleEngine alloc] init];
    });
    return _instance;
}

+ (void)updateControllerStyle:(UIViewController *)controller {
    [EStyleEngine updateStyle:controller.view];
    [EStyleEngine updateStyle:controller.navigationItem.leftBarButtonItem.customView];
    [EStyleEngine updateStyle:controller.navigationItem.rightBarButtonItem.customView];
    
}

+ (void)updateStyle:(id<EStyleable>)styleable {
    [EStyleEngine updateStyleNonRecursively:styleable];
    for (id<EStyleable> child in [styleable styleChildren]) {
        [EStyleEngine updateStyle:child];
    }
}

+ (void)updateStyleNonRecursively:(id<EStyleable>)styleable {
    NSDictionary *rulesets = [styleable rulesets];
    [rulesets enumerateKeysAndObjectsUsingBlock:^(id pesudoClass, EStyleRuleset *obj, BOOL *stop) {
        [obj.ruleset enumerateKeysAndObjectsUsingBlock:^(id rule, id action, BOOL *stop) {
            RUN_RULE_ACTION(styleable, rule, action, pesudoClass);
        }];
    }];
}

+ (id)stylesheetFromSource:(NSString *)source {
    EStylesheet *sheet = [EStylesheet stylesheet];
    if([sheet loadFromSource:source]) return sheet;
    else return nil;
}

+ (id)stylesheetFromFile:(NSString *)filePath {
    EStylesheet *sheet = [EStylesheet stylesheet];
    if([sheet loadFromFile:filePath]) return sheet;
    else return nil;
}

+ (id)stylesheetFromFile:(NSString *)filePath withPrefix:(NSString *)prefix {
    EStylesheet *sheet = [EStylesheet stylesheet];
    if([sheet loadFromFile:filePath withPrefix:prefix]) return sheet;
    else return nil;
}

// \x20是空格的八进制表示
DEF_SELECTOR(DescendantSelector, \x20)
DEF_SELECTOR(ChildSelector, >)
DEF_SELECTOR(AdjacentSiblingSelector, +)
DEF_SELECTOR(IdSelector, #)
DEF_SELECTOR(ClassSelector, .)
DEF_SELECTOR(_none_, ^)

+ (void)applyStylesheet:(EStylesheet *)stylesheet toStyleable:(id<EStyleable>)styleable {
    NSDictionary *sheet = stylesheet.sheet;
    if(!styleable) return;
    [sheet enumerateKeysAndObjectsUsingBlock:^(id selector, id rulesets, BOOL *stop) {
        if(IS_SELECTOR(selector)) {
            NSArray *styleables = [EStyleEngine selectFromStyleable:styleable usingSelector:selector];
            [styleables enumerateObjectsUsingBlock:^(id<EStyleable> s, NSUInteger idx, BOOL *stop) {
                [s setRulesets:rulesets];
            }];
        }
    }];
}

+ (void)applyStylesheet:(EStylesheet *)stylesheet toController:(UIViewController *)controller {
    [EStyleEngine applyStylesheet:stylesheet toStyleable:controller.view];
    [EStyleEngine applyStylesheet:stylesheet toStyleable:controller.navigationItem.leftBarButtonItem.customView];
    [EStyleEngine applyStylesheet:stylesheet toStyleable:controller.navigationItem.rightBarButtonItem.customView];
}

+ (NSArray *)selectFromStyleable:(id<EStyleable>)styleable usingSelector:(NSString *)source {
    
    NSCharacterSet *selectorSet = [[EStyleEngine instance] selectorSet];
    NSArray *items = [source componentsSeparatedByString:@" "];
    
    NSMutableSet *result = [NSMutableSet setWithObject:styleable];
    
    NSString *lastSelector = SELECTOR(_none_);
    
    for (NSString *item in items) {
        NSString *selector = [item substringToIndex:1];
        do {
            if(SELECTOR_HASTYPE_OF(selector, IdSelector)) {
                if(!SELECTOR_HASTYPE_OF(lastSelector, _none_)) return nil;
                NSArray *tmp = [[item substringFromIndex:1] componentsSeparatedByCharactersInSet:selectorSet];
                if(tmp.count > 1) return nil;
                NSString *Id = [tmp objectAtIndex:0];
                id<EStyleable> style = [EStyleEngine selectFromStyleable:styleable byID:Id];
                if(style) {
                    [result removeAllObjects];
                    [result addObject:style];
                    lastSelector = SELECTOR(IdSelector);
                } else return nil;
                break;
            }
            if(SELECTOR_HASTYPE_OF(selector, ClassSelector)) {
                if(SELECTOR_HASTYPE_OF(lastSelector, ClassSelector) || SELECTOR_HASTYPE_OF(lastSelector, IdSelector)) {
                    selector = SELECTOR(DescendantSelector);
                } else {
                    NSArray *tmp = [[item substringFromIndex:1] componentsSeparatedByString:SELECTOR(ClassSelector)];
                    NSSet *classes = [NSSet setWithArray:tmp];
                    NSMutableSet *res = [NSMutableSet set];
                    for (id<EStyleable> i in result) {
                        [res addObjectsFromArray:[EStyleEngine selectFromStyleable:i byClasses:classes]];
                    }
                    [result setSet:res];
                    lastSelector = SELECTOR(ClassSelector);
                    break;
                }
            }
            if(SELECTOR_HASTYPE_OF(selector, DescendantSelector)) {
                NSMutableSet *res = [NSMutableSet set];
                for (id<EStyleable> i in result) {
                    NSMutableSet *tmp = [NSMutableSet set];
                    [EStyleEngine flatten:i to:tmp];
                    [tmp removeObject:i];
                    [res addObjectsFromArray:tmp.allObjects];
                }
                [result setSet:res];
                lastSelector = SELECTOR(DescendantSelector);
                break;
            }
            if(SELECTOR_HASTYPE_OF(selector, ChildSelector)) {
                NSMutableSet *res = [NSMutableSet set];
                for (id<EStyleable> i in result) {
                    [res addObjectsFromArray:[i styleChildren]];
                }
                [result setSet:res];
                lastSelector = SELECTOR(ChildSelector);
                break;
            }
            if(SELECTOR_HASTYPE_OF(selector, AdjacentSiblingSelector)) {
                NSMutableSet *res = [NSMutableSet set];
                for (id<EStyleable> i in result) {
                    id<EStyleable> tmp = [EStyleEngine selectAdjacentSiblingFromStyleable:i];
                    [res addObject:tmp];
                }
                [result setSet:res];
                lastSelector = SELECTOR(AdjacentSiblingSelector);
                break;
            }
            return nil;
            
        } while (false);

    }
    
    return result.allObjects;
}

+ (id<EStyleable>)selectFromStyleable:(id<EStyleable>)styleable byID:(NSString *)Id {
    if([Id isEqualToString:[styleable styleId]]) {
        return styleable;
    } else {
        NSArray *children = [styleable styleChildren];
        for (id<EStyleable> style in children) {
            id<EStyleable> tmp = [EStyleEngine selectFromStyleable:style byID:Id];
            if(tmp) return tmp;
        }
        return nil;
    }
}

+ (NSArray *)selectFromStyleable:(id<EStyleable>)styleable byClasses:(NSSet *)classes {
    NSMutableSet *set = [NSMutableSet set];
    [EStyleEngine flatten:styleable to:set];
    NSMutableArray *res = [NSMutableArray array];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if([classes isSubsetOfSet:[obj styleClass]]) {
            [res addObject:obj];
        }
    }];
    if(res.count > 0) return res;
    else return nil;
}

+ (id<EStyleable>)selectAdjacentSiblingFromStyleable:(id<EStyleable>)styleable {
    NSArray *siblings = [[styleable styleParent] styleChildren];
    for(int i = 0; i < siblings.count; i++) {
        if([siblings objectAtIndex:i] == styleable) {
            int next = i + 1;
            if(next < siblings.count) return [siblings objectAtIndex:next];
            else return nil;
        }
    }
    return nil;
}

+ (void)flatten:(id<EStyleable>)styleable to:(NSMutableSet *)set {
    [set addObject:styleable];
    for (id<EStyleable> style in [styleable styleChildren]) {
        [EStyleEngine flatten:style to:set];
    }
}

DEF_RULE_ACTION(hidden) {
    
    objc_msgSend(styleable, @selector(setHidden:), STRING_TO(value, BOOL));
    
}

DEF_STRING_TO(BOOL) {
    if([value isEqualToString:@"yes"]) {
        return YES;
    } else {
        return NO;
    }
}


@end
