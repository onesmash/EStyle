//
//  EStyleHelper.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-22.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONST_STRING(name, value) \
NSString *const name = @#value

#define PSEUDO_CLASS(name) \
kPseudoClass_ ## name

#define DEF_PSEUDO_CLASS(name) \
CONST_STRING(PSEUDO_CLASS(name), name)

#define EXTERN_PSEUDO_CLASS(name) \
extern NSString *const PSEUDO_CLASS(name)

#define RULE(name) \
kRule_ ## name

#define DEF_RULE(name) \
CONST_STRING(RULE(name), name)

#define DEF_RULE_ACTION(name) \
static DEF_RULE(name);  \
- (BOOL)apply_ ## name ## WithParam:(NSString *)value pesudoClass:(NSString *) pesudoClass isPaddingRule:(BOOL)isPaddingRule

#define DEF_RULE_ACTION_WITH_ID_PARAMS(name) \
static DEF_RULE(name);  \
- (BOOL)apply_ ## name ## WithParam:(id)value pesudoClass:(NSString *) pesudoClass isPaddingRule:(BOOL)isPaddingRule

#define RULE_ACTION(name) \
NSSelectorFromString([NSString stringWithFormat:@"apply_%@WithParam:pesudoClass:isPaddingRule:", name])

#define RUN_RULE_ACTION(target, rule, value, pesudoClass, isPaddingRule) \
objc_msgSend(target, RULE_ACTION(rule), value, pesudoClass, isPaddingRule)

#define BUILDING_PHASE_RULE(name) \
kBuildingPhaseRule_ ## name

#define DEF_BUILDING_PHASE_RULE(name) \
CONST_STRING(RULE(name), name)

#define DEF_BUILDING_PHASE_RULE_ACTION(name) \
static DEF_BUILDING_PHASE_RULE(name);  \
- (BOOL)apply_BuildingPhase_ ## name ## WithParam:(NSString *)value pesudoClass:(NSString *) pesudoClass isPaddingRule:(BOOL)isPaddingRule

#define DEF_BUILDING_PHASE_RULE_ACTION_WITH_ID_PARAMS(name) \
static DEF_BUILDING_PHASE_RULE(name); \
- (BOOL)apply_BuildingPhase_ ## name ## WithParam:(id)value pesudoClass:(NSString *) pesudoClass isPaddingRule:(BOOL)isPaddingRule

#define BUILDING_PHASE_RULE_ACTION(name) \
NSSelectorFromString([NSString stringWithFormat:@"apply_BuildingPhase_%@WithParam:pesudoClass:isPaddingRule:", name])

#define RUN_BUILDING_PHASE_RULE_ACTION(target, rule, value, pesudoClass, isPaddingRule) \
objc_msgSend(target, BUILDING_PHASE_RULE_ACTION(rule), value, pesudoClass, isPaddingRule)

#define STRING_TO_FUNC(type) \
_ ## type ## From:

#define STRING_TO_FUNC_P(type) \
_ ## type ## p ## From:

#define DEF_STRING_TO(type) \
+ (type) STRING_TO_FUNC(type) (NSString *)value

#define DEF_STRING_TO_P(type) \
+ (type *) STRING_TO_FUNC_P(type) (NSString *)value

#define STRING_TO(value, type) \
[EStyleHelper STRING_TO_FUNC(type) value]

#define STRING_TO_P(value, type) \
[EStyleHelper STRING_TO_FUNC_P(type) value]

#define SELECTOR(name) \
kSelector_ ## name

#define DEF_SELECTOR(name, value) \
CONST_STRING(SELECTOR(name), value)

#define SELECTOR_HASTYPE_OF(selector, type) \
([selector isEqualToString:SELECTOR(type)])

#define IS_SELECTOR(value) \
(![value hasPrefix:@"@"])

#define PESUDOCLASS_HASTYPE_OF(pesudoclass, type) \
([pesudoclass isEqualToString:PSEUDO_CLASS(type)])

EXTERN_PSEUDO_CLASS(_none_);
EXTERN_PSEUDO_CLASS(normal);
EXTERN_PSEUDO_CLASS(selected);
EXTERN_PSEUDO_CLASS(highlighted);
EXTERN_PSEUDO_CLASS(disabled);

typedef enum {
    PIXEL_UNIT,
    PERCENTAGE_UNIT,
    AUTO_UNIT
} StyleUnitType;

typedef struct {
    StyleUnitType type;
    CGFloat value;
} StyleUnit;

typedef NSArray Shadow;

typedef NSArray StyleUnitArray;

typedef NSString FilePath;

@interface EStyleHelper : NSObject

+ (NSDictionary *)stringToJsonDict:(NSString *)str;

+ (NSString *)bundleResource:(NSString *)path;

+ (NSString *)documentsResource:(NSString *)path;

DEF_STRING_TO(BOOL);

DEF_STRING_TO(StyleUnit);

DEF_STRING_TO_P(UIColor);

DEF_STRING_TO(CGFloat);

DEF_STRING_TO_P(UIImage);

DEF_STRING_TO(UIViewAutoresizing);

DEF_STRING_TO(UIControlState);

DEF_STRING_TO_P(StyleUnitArray);

DEF_STRING_TO_P(FilePath);

DEF_STRING_TO(CGRect);

DEF_STRING_TO(UITableViewCellStyle);

DEF_STRING_TO_P(UIFont);

DEF_STRING_TO(NSTextAlignment);

DEF_STRING_TO_P(Shadow);

@end
