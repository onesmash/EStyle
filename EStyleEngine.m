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

typedef enum {
    PIXEL_UNIT,
    PERCENTAGE_UNIT,
    AUTO_UNIT
} StyleUnitType;

typedef struct {
    StyleUnitType type;
    CGFloat value;
} StyleUnit;

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
+ (void)apply_ ## name ## _to:(UIView *)styleable param:(NSString *)value pesudoClass: pesudoClass

#define RULE_ACTION(name) \
NSSelectorFromString([NSString stringWithFormat:@"apply_%@_to:param:pesudoClass:", name])

#define RUN_RULE_ACTION(target, rule, value, pesudoClass) \
objc_msgSend([EStyleEngine class], RULE_ACTION(rule), target, value, pesudoClass)

#define STRING_TO_FUNC(type) \
_ ## type ## From:

#define STRING_TO_FUNC_P(type) \
_ ## type ## p ## From:

#define DEF_STRING_TO(type) \
+ (type) STRING_TO_FUNC(type) (NSString *)value

#define DEF_STRING_TO_P(type) \
+ (type *) STRING_TO_FUNC_P(type) (NSString *)value

#define STRING_TO(value, type) \
[EStyleEngine STRING_TO_FUNC(type) value]

#define STRING_TO_P(value, type) \
[EStyleEngine STRING_TO_FUNC_P(type) value]

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
        [obj enumerateRulesAndActionsUsingBlock:^(id rule, id action, BOOL *stop) {
            RUN_RULE_ACTION(styleable, rule, action, pesudoClass);
        }];
        
        //[obj.ruleset enumerateKeysAndObjectsUsingBlock:^(id rule, id action, BOOL *stop) {
        //    RUN_RULE_ACTION(styleable, rule, action, pesudoClass);
        //}];
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

// \x20是空格的十六进制表示
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
        NSSet *classSet = [[NSSet alloc] initWithArray:[[obj styleClass] componentsSeparatedByString:@" "]];
        if([classes isSubsetOfSet:classSet]) {
            [res addObject:obj];
        }
        [classSet release];
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

#pragma mark - rule action

DEF_RULE_ACTION(background_color) {
    styleable.backgroundColor = STRING_TO_P(value, UIColor);
}

DEF_RULE_ACTION(hidden) {
    [styleable setHidden:STRING_TO(value, BOOL)];
    //objc_msgSend(styleable, @selector(setHidden:), STRING_TO(value, BOOL));
}

DEF_RULE_ACTION(top) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.y = unit.value;
            styleable.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.y = styleable.superview.bounds.size.height * unit.value;
            styleable.frame = frame;
        } break;
            
        default:
            break;
    }
}

DEF_RULE_ACTION(left) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.x = unit.value;
            styleable.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.x = styleable.superview.bounds.size.width * unit.value;
            styleable.frame = frame;
        } break;
            
        default:
            break;
    }
}

DEF_RULE_ACTION(right) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.x = styleable.superview.bounds.size.width - unit.value - frame.size.width;
            styleable.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.x = styleable.superview.bounds.size.width * unit.value - frame.size.width;
            styleable.frame = frame;
        } break;
            
        default:
            break;
    }
}

DEF_RULE_ACTION(bottom) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.y = styleable.superview.bounds.size.height - unit.value - frame.size.height;
            styleable.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = styleable.frame;
            frame.origin.y = styleable.superview.bounds.size.height * unit.value - frame.size.height;
            styleable.frame = frame;
        } break;
            
        default:
            break;
    }
}

DEF_RULE_ACTION(opacity) {
    styleable.alpha = STRING_TO(value, CGFloat);
}

DEF_RULE_ACTION(border_radius) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        styleable.layer.cornerRadius = unit.value;
    }
}

DEF_RULE_ACTION(border_width) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        styleable.layer.borderWidth = unit.value;
    }
}

DEF_RULE_ACTION(border_color) {
    UIColor *color = STRING_TO_P(value, UIColor);
    styleable.layer.borderColor = color.CGColor;
}

DEF_RULE_ACTION(autoresizing) {
    styleable.autoresizingMask = STRING_TO(value, UIViewAutoresizing);
}

DEF_RULE_ACTION(width) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = styleable.frame;
            frame.size.width = unit.value;
            styleable.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = styleable.frame;
            frame.size.width = styleable.superview.bounds.size.width * unit.value;
            styleable.frame = frame;
        } break;
        case AUTO_UNIT: {
            CGRect frame = styleable.frame;
            CGFloat height = frame.size.height;
            [styleable sizeToFit];
            frame = styleable.frame;
            frame.size.height = height;
            styleable.frame = frame;
        } break;
        default:
            break;
    }

}

DEF_RULE_ACTION(height) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = styleable.frame;
            frame.size.height = unit.value;
            styleable.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = styleable.frame;
            frame.size.height = styleable.superview.bounds.size.height * unit.value;
            styleable.frame = frame;
        } break;
        case AUTO_UNIT: {
            CGRect frame = styleable.frame;
            CGFloat width = frame.size.width;
            [styleable sizeToFit];
            frame = styleable.frame;
            frame.size.width = width;
            styleable.frame = frame;
        } break;
        default:
            break;
    }
    
}

DEF_RULE_ACTION(halign) {
    do {
        if([value isEqualToString:@"left"]) {
            CGRect frame = styleable.frame;
            frame.origin.x = 0;
            styleable.frame = frame;
            break;
        }
        if([value isEqualToString:@"right"]) {
            CGRect frame = styleable.frame;
            frame.origin.x = styleable.superview.bounds.size.width - frame.size.width;
            styleable.frame = frame;
            break;
        }
        if([value isEqualToString:@"center"]) {
            CGRect frame = styleable.frame;
            frame.origin.x = (styleable.superview.bounds.size.width - frame.size.width) / 2;
            styleable.frame = frame;
            break;
        }
    } while (false);
}

DEF_RULE_ACTION(valign) {
    do {
        if([value isEqualToString:@"top"]) {
            CGRect frame = styleable.frame;
            frame.origin.y = 0;
            styleable.frame = frame;
            break;
        }
        if([value isEqualToString:@"bottom"]) {
            CGRect frame = styleable.frame;
            frame.origin.y = styleable.superview.bounds.size.height - frame.size.height;
            styleable.frame = frame;
            break;
        }
        if([value isEqualToString:@"middle"]) {
            CGRect frame = styleable.frame;
            frame.origin.y = (styleable.superview.bounds.size.height - frame.size.height) / 2;
            styleable.frame = frame;
            break;
        }
    } while (false);
}

#pragma mark - value convert

DEF_STRING_TO(BOOL) {
    if([value isEqualToString:@"yes"]) {
        return YES;
    } else {
        return NO;
    }
}

DEF_STRING_TO(StyleUnit) {
    StyleUnit unit;
    do {
        if([value hasSuffix:@"px"]) {
            unit.type = PIXEL_UNIT;
            unit.value = [NSDecimalNumber decimalNumberWithString: [value substringToIndex:value.length - 1]].floatValue;
            break;
        }
        if([value hasSuffix:@"%"]) {
            unit.type = PERCENTAGE_UNIT;
            NSDecimalNumber *v = [NSDecimalNumber decimalNumberWithString: [value substringToIndex:value.length - 1]];
            unit.value = [v decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithMantissa:1 exponent:2 isNegative:NO]].floatValue;
            break;
        }
        if([value caseInsensitiveCompare:@"auto"] == NSOrderedSame) {
            unit.type = AUTO_UNIT;
            unit.value = 0;
            break;
        }
        if([value isEqualToString:@"0"]) {
            unit.type = PIXEL_UNIT;
            unit.value = 0;
            break;
        }
        
    } while (false);
    return unit;
}

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

DEF_STRING_TO_P(UIColor) {
    UIColor* color = nil;
    if([value hasPrefix:@"#"]) {
        unsigned long colorValue = 0;
        switch (value.length) {
            case 6 + 1: {
                colorValue = strtol([value UTF8String] + 1, nil, 16);
                color = RGBCOLOR(((colorValue & 0xFF0000) >> 16),
                                 ((colorValue & 0xFF00) >> 8),
                                 (colorValue & 0xFF));
            } break;
            case 8 + 1: {
                colorValue = strtol([value UTF8String] + 1, nil, 16);
                color = RGBACOLOR(((colorValue & 0xFF000000) >> 24),
                                 ((colorValue & 0xFF0000) >> 16),
                                 ((colorValue & 0xFF00) >> 8),
                                  (colorValue & 0xFF));
            } break;
            default:
                break;
        }
    } else {
        NSArray *components = [value componentsSeparatedByString:@" "];
        NSString *red = [components objectAtIndex:0];
        NSString *green = [components objectAtIndex:1];
        NSString *yellow = [components objectAtIndex:2];
        switch (components.count) {
            case 3: {
                color = RGBCOLOR(red.floatValue, green.floatValue, yellow.floatValue);
            } break;
            case 4: {
                NSString *alpha = [components objectAtIndex:3];
                color = RGBACOLOR(red.floatValue, green.floatValue, yellow.floatValue, alpha.floatValue);
            }
            default:
                break;
        }
    }
    
    return color;
}

DEF_STRING_TO(CGFloat) {
    return [value floatValue];
}

#ifndef UIViewAutoresizingFlexibleMargins
#define UIViewAutoresizingFlexibleMargins (UIViewAutoresizingFlexibleLeftMargin \
                                           | UIViewAutoresizingFlexibleTopMargin \
                                           | UIViewAutoresizingFlexibleRightMargin \
                                           | UIViewAutoresizingFlexibleBottomMargin)
#endif

#ifndef UIViewAutoresizingFlexibleDimensions
#define UIViewAutoresizingFlexibleDimensions (UIViewAutoresizingFlexibleWidth \
                                              | UIViewAutoresizingFlexibleHeight)
#endif

DEF_STRING_TO(UIViewAutoresizing) {
    UIViewAutoresizing autoresizing = UIViewAutoresizingNone;
    NSArray *components = [value componentsSeparatedByString:@"|"];
    for (NSString *v in components) {
        do {
            if([v isEqualToString:@"left"]) {
                autoresizing |= UIViewAutoresizingFlexibleLeftMargin;
                break;
            }
            if([v isEqualToString:@"top"]) {
                autoresizing |= UIViewAutoresizingFlexibleTopMargin;
                break;
            }
            if([v isEqualToString:@"right"]) {
                autoresizing |= UIViewAutoresizingFlexibleRightMargin;
                break;
            }
            if([v isEqualToString:@"bottom"]) {
                autoresizing |= UIViewAutoresizingFlexibleBottomMargin;
                break;
            }
            if([v isEqualToString:@"width"]) {
                autoresizing |= UIViewAutoresizingFlexibleWidth;
                break;
            }
            if([v isEqualToString:@"height"]) {
                autoresizing |= UIViewAutoresizingFlexibleHeight;
                break;
            }
            if([v isEqualToString:@"all"]) {
                autoresizing |= UIViewAutoresizingFlexibleDimensions | UIViewAutoresizingFlexibleMargins;
                break;
            }
            if([v isEqualToString:@"margins"]) {
                autoresizing |= UIViewAutoresizingFlexibleMargins;
                break;
            }
            if([v isEqualToString:@"dim"]) {
                autoresizing |= UIViewAutoresizingFlexibleDimensions;
                break;
            }
        } while (false);
    }
    return autoresizing;
}

@end
