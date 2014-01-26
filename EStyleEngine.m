//
//  EStyleEngine.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#include <objc/message.h>
#import "EStyleEngine.h"
#import "EStyleHelper.h"
#import "EStylesheet.h"
#import "EStyleRuleset.h"
#import "UIView+EStyling.h"



typedef NSString ResPath;

typedef NSArray * (^BuildinFuction)(NSString *);


@interface EStyleEngine () 

@property (nonatomic, strong) NSCharacterSet *selectorSet;

@end

@implementation EStyleEngine

- (id)init {
    self = [super init];
    if(self) {
        _selectorSet = [NSCharacterSet characterSetWithCharactersInString:@"\x20>+#."];
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
    NSArray *paddingRule = [EStyleEngine updateStyleNonRecursively:styleable isPadding:NO];
    for (id<EStyleable> child in [styleable styleChildren]) {
        [EStyleEngine updateStyle:child];
    }
    if(paddingRule.count > 0) {
        [EStyleEngine updateStyleNonRecursively:styleable isPadding:YES];
    }
    //[styleable setPhase:Idle];
}

+ (NSArray *)updateStyleNonRecursively:(id<EStyleable>)styleable isPadding:(BOOL)isPadding {
    NSMutableArray *paddingRules = [NSMutableArray array];
    NSDictionary *rulesets = [styleable rulesets];
    [rulesets enumerateKeysAndObjectsUsingBlock:^(id pesudoClass, EStyleRuleset *obj, BOOL *stop) {
        [obj enumerateRulesAndActionsUsingBlock:^(id rule, id action, BOOL *stop) {
            if([styleable phase] == Styling) {
                BOOL excuted = RUN_RULE_ACTION(styleable, rule, action, pesudoClass, isPadding);
                if(!isPadding && !excuted) {
                    [paddingRules addObject:rule];
                }
            } else if([styleable phase] == Building) {
                BOOL excuted = RUN_BUILDING_PHASE_RULE_ACTION(styleable, rule, action, pesudoClass, isPadding);
                if(!isPadding && !excuted) {
                    [paddingRules addObject:rule];
                }
                if(excuted) {
                    [obj removeRule:rule];
                }
            }
            
        }];
    }];
    return paddingRules;
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

// \x20是空格的十六进制表示
DEF_SELECTOR(DescendantSelector, \x20);
DEF_SELECTOR(ChildSelector, >);
DEF_SELECTOR(AdjacentSiblingSelector, +);
DEF_SELECTOR(IdSelector, #);
DEF_SELECTOR(ClassSelector, .);
DEF_SELECTOR(_none_, ^);

+ (void)mergeRulesets:(NSDictionary *)src toRulesets:(NSMutableDictionary *)dest {
    [src enumerateKeysAndObjectsUsingBlock:^(NSString *pesudoClass, EStyleRuleset *ruleset, BOOL *stop) {
        EStyleRuleset *destRuleset = dest[pesudoClass];
        if(destRuleset) {
            [destRuleset merge:ruleset];
        } else {
            [dest setObject:ruleset forKey:pesudoClass];
        }
    }];
}

+ (void)applyStylesheet:(EStylesheet *)stylesheet toStyleable:(id<EStyleable>)styleable {
    NSDictionary *sheet = stylesheet.sheet;
    if(!styleable) return;
    [sheet enumerateKeysAndObjectsUsingBlock:^(id selector, NSDictionary *rulesets, BOOL *stop) {
        if(IS_SELECTOR(selector)) {
            NSArray *styleables = [EStyleEngine selectFromStyleable:styleable usingSelector:selector];
            [styleables enumerateObjectsUsingBlock:^(id<EStyleable> s, NSUInteger idx, BOOL *stop) {
                if([s rulesets]) {
                    [EStyleEngine mergeRulesets:rulesets toRulesets:[s rulesets]];
                } else {
                    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:rulesets];
                    [s setRulesets:tmp];
                }
                [s setPhase:Styling];
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
        NSSet *classSet = [[NSSet alloc] initWithArray:[[obj styleClass] componentsSeparatedByString:@" "]];
        if([classes isSubsetOfSet:classSet]) {
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
    if([styleable styleId] != nil || [styleable styleClass] != nil) {
        [set addObject:styleable];
    }
    for (id<EStyleable> style in [styleable styleChildren]) {
        [EStyleEngine flatten:style to:set];
    }
}

+ (id)buildViewFromSource:(NSString *)source {
    NSDictionary *config = [EStyleHelper stringToJsonDict:source];
    UIView *view = [EStyleEngine buildViewFromConfig:config];
    [EStyleEngine updateStyle:view];
    /*
    NSString *style = config[@"style"];
    if(style == nil) return view;
    NSString *filePath = nil;
    do {
        if([style hasPrefix:@"bundle://"]) {
            NSString *path = [EStyleHelper bundleResource:style];
            NSString *name = [path stringByDeletingPathExtension];
            NSString *extension = [path pathExtension];
            filePath = [[NSBundle mainBundle] pathForResource:name ofType:extension];
            break;
        }
        if([style hasPrefix:@"documents://"]) {
            filePath = [EStyleHelper documentsResource:style];
            break;
        }
    } while (false);
    EStylesheet *sheet = [EStylesheet stylesheet];
    [sheet loadFromFile:filePath];
    [EStyleEngine applyStylesheet:sheet toStyleable:view];
     */
    return view;
}

+ (id)buildViewFromConfig:(NSDictionary *)config {
    NSString *class = config[@"class"];
    UIView *view = [[NSClassFromString(class) alloc] init];
    view.phase = Building;
    EStyleRuleset *ruleset = [[EStyleRuleset alloc] initWithPesudoclass:PSEUDO_CLASS(normal)];
    [ruleset addRulesFrom:config];
    NSMutableDictionary *rulesets = [NSMutableDictionary dictionaryWithObject:ruleset forKey:ruleset.pesudoClass];
    [view setRulesets:rulesets];
    //[EStyleEngine updateStyleNonRecursively:view isPadding:NO];
    return view;
}

#pragma mark - rule action


#pragma mark - value convert


@end
