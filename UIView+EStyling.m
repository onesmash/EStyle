//
//  UIView+EStyling.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#include <objc/message.h>
#import <objc/runtime.h>
#import "UIView+EStyling.h"
#import "EStyleHelper.h"
#import "EStylesheet.h"
#import "EStyleEngine.h"

static NSString *const kEStyleIdKey = @"kEStyleIdKey";
static NSString *const kEStyleClassKey = @"kEStyleClassKey";
static NSString *const kEStyleRulesetKey = @"kEStyleRulesetKey";
static NSString *const kEStylePhaseKey = @"kEStylePhasetKey";

@implementation UIView (EStyling)

- (NSString *)styleId {
    return objc_getAssociatedObject(self, (__bridge const void *)(kEStyleIdKey));
}

- (void)setStyleId:(NSString *)styleId {
    objc_setAssociatedObject(self, (__bridge const void *)(kEStyleIdKey), styleId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)styleClass {
    return objc_getAssociatedObject(self, (__bridge const void *)(kEStyleClassKey));
}

- (void)setStyleClass:(NSString *)styleClass {
    objc_setAssociatedObject(self, (__bridge const void *)(kEStyleClassKey), styleClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableDictionary *)rulesets {
    return objc_getAssociatedObject(self, (__bridge const void *)(kEStyleRulesetKey));
}

- (void)setRulesets:(NSMutableDictionary *)rulesets {
    objc_setAssociatedObject(self, (__bridge const void *)(kEStyleRulesetKey), rulesets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (StylePhase)phase {
    NSValue *phaseValue = objc_getAssociatedObject(self, (__bridge const void *)(kEStylePhaseKey));
    if(phaseValue) {
        StylePhase _phase;
        [phaseValue getValue:&_phase];
        return _phase;
    } else {
        return Idle;
    }
    
}

- (void)setPhase:(StylePhase)phase {
    NSValue *phaseValue = [NSValue valueWithBytes:&phase objCType:@encode(StylePhase)];
    objc_setAssociatedObject(self, (__bridge const void *)(kEStylePhaseKey), phaseValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (id)styleParent {
    return [self superview];
}

- (NSArray *)styleChildren {
    return [self subviews];
}

- (void)addCustomSubview:(UIView *)view {
    [self addSubview:view];
}

-(void)updateStyleRules:(NSDictionary *)rules withPseudoClass:(NSString *)pseudoClass {
    [EStyleEngine updateStyleRules:rules withPseudoClass:pseudoClass toStyleavle:self];
}

#pragma mark - build phase rule action

DEF_BUILDING_PHASE_RULE_ACTION(class) {
    return YES;
}

DEF_BUILDING_PHASE_RULE_ACTION(initWithFrame) {
    [self initWithFrame:STRING_TO(value, CGRect)];
    return YES;
}

DEF_BUILDING_PHASE_RULE_ACTION(initWithStyle_reuseIdentifier) {
    return YES;
}

DEF_BUILDING_PHASE_RULE_ACTION(styleId) {
    self.styleId = value;
    return YES;
}

DEF_BUILDING_PHASE_RULE_ACTION(styleClass) {
    self.styleClass = value;
    return YES;
}

DEF_BUILDING_PHASE_RULE_ACTION_WITH_ID_PARAMS(style) {
    if(isPaddingRule) {
        EStylesheet *sheet = [EStylesheet stylesheet];
        if([value isKindOfClass:[NSString class]]) {
            NSString *filePath = STRING_TO_P(value, FilePath);
            [sheet loadFromFile:filePath];
        } else {
            [sheet loadFromDict:value];
        }
        [EStyleEngine applyStylesheet:sheet toStyleable:self];
        return YES;
    } else {
        return  NO;
    }
}

DEF_BUILDING_PHASE_RULE_ACTION_WITH_ID_PARAMS(subviews) {
    NSArray *configs = value;
    for (NSDictionary *config in configs) {
        id view = [EStyleEngine buildViewFromConfigNonRecursively:config];
        [self addSubview:view];
    }
    return YES;
}

DEF_BUILDING_PHASE_RULE_ACTION(frame) {
    CGRect frame = STRING_TO(value, CGRect);
    self.frame = frame;
    return YES;
}

#pragma mark - style phase rule action

DEF_RULE_ACTION(background_color) {
    self.backgroundColor = STRING_TO_P(value, UIColor);
    return YES;
}

DEF_RULE_ACTION(hidden) {
    [self setHidden:STRING_TO(value, BOOL)];
    return YES;
    //objc_msgSend(styleable, @selector(setHidden:), STRING_TO(value, BOOL));
}

DEF_RULE_ACTION(top) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.origin.y = unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.origin.y = self.superview.bounds.size.height * unit.value;
            self.frame = frame;
        } break;
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(left) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.origin.x = unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.origin.x = self.superview.bounds.size.width * unit.value;
            self.frame = frame;
        } break;
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(right) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.origin.x = self.superview.bounds.size.width - unit.value - frame.size.width;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.origin.x = self.superview.bounds.size.width * unit.value - frame.size.width;
            self.frame = frame;
        } break;
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(bottom) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.origin.y = self.superview.bounds.size.height - unit.value - frame.size.height;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.origin.y = self.superview.bounds.size.height * unit.value - frame.size.height;
            self.frame = frame;
        } break;
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(opacity) {
    self.alpha = STRING_TO(value, CGFloat);
    return YES;
}

DEF_RULE_ACTION(border_radius) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.layer.cornerRadius = unit.value;
    }
    return YES;
}

DEF_RULE_ACTION(border_width) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.layer.borderWidth = unit.value;
    }
    return YES;
}

DEF_RULE_ACTION(border_color) {
    UIColor *color = STRING_TO_P(value, UIColor);
    self.layer.borderColor = color.CGColor;
    return YES;
}

DEF_RULE_ACTION(autoresizing) {
    self.autoresizingMask = STRING_TO(value, UIViewAutoresizing);
    return YES;
}

DEF_RULE_ACTION(width) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.size.width = unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.size.width = self.superview.bounds.size.width * unit.value;
            self.frame = frame;
        } break;
        case AUTO_UNIT: {
            if(isPaddingRule) {
                CGRect frame = self.frame;
                CGFloat height = frame.size.height;
                [self sizeToFit];
                frame = self.frame;
                frame.size.height = height;
                self.frame = frame;
            } else {
                return NO;
            }
        } break;
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(height) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.size.height = unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.size.height = self.superview.bounds.size.height * unit.value;
            self.frame = frame;
        } break;
        case AUTO_UNIT: {
            if(isPaddingRule) {
                CGRect frame = self.frame;
                CGFloat width = frame.size.width;
                [self sizeToFit];
                frame = self.frame;
                frame.size.width = width;
                self.frame = frame;
            } else {
                return NO;
            }
            
        } break;
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(halign) {
    do {
        if([value isEqualToString:@"left"]) {
            CGRect frame = self.frame;
            frame.origin.x = 0;
            self.frame = frame;
            break;
        }
        if([value isEqualToString:@"right"]) {
            CGRect frame = self.frame;
            frame.origin.x = self.superview.bounds.size.width - frame.size.width;
            self.frame = frame;
            break;
        }
        if([value isEqualToString:@"center"]) {
            CGRect frame = self.frame;
            frame.origin.x = (self.superview.bounds.size.width - frame.size.width) / 2;
            self.frame = frame;
            break;
        }
    } while (false);
    return YES;
}

DEF_RULE_ACTION(valign) {
    do {
        if([value isEqualToString:@"top"]) {
            CGRect frame = self.frame;
            frame.origin.y = 0;
            self.frame = frame;
            break;
        }
        if([value isEqualToString:@"bottom"]) {
            CGRect frame = self.frame;
            frame.origin.y = self.superview.bounds.size.height - frame.size.height;
            self.frame = frame;
            break;
        }
        if([value isEqualToString:@"middle"]) {
            CGRect frame = self.frame;
            frame.origin.y = (self.superview.bounds.size.height - frame.size.height) / 2;
            self.frame = frame;
            break;
        }
    } while (false);
    return YES;
}

DEF_RULE_ACTION(padding_top) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.size.height += frame.size.height + unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.size.height *= 1 + unit.value;
            self.frame = frame;
            break;
        }
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(padding_left) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.size.width += frame.size.width + unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.size.width *= 1 + unit.value;
            self.frame = frame;
            break;
        }
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(padding_bottom) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.size.height += frame.size.height + unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.size.height *= 1 + unit.value;
            self.frame = frame;
            break;
        }
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(padding_right) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    switch (unit.type) {
        case PIXEL_UNIT: {
            CGRect frame = self.frame;
            frame.size.width += frame.size.width + unit.value;
            self.frame = frame;
        } break;
        case PERCENTAGE_UNIT: {
            CGRect frame = self.frame;
            frame.size.width *= 1 + unit.value;
            self.frame = frame;
        } break;
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(padding) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    switch (components.count) {
        case 1: {
            RUN_RULE_ACTION(self, RULE(padding_top), value, pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_left), value, pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_bottom), value, pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_right), value, pesudoClass, NO);
        } break;
        case 2: {
            RUN_RULE_ACTION(self, RULE(padding_top), components[0], pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_left), components[1], pesudoClass, NO);
        } break;
        case 3: {
            RUN_RULE_ACTION(self, RULE(padding_top), components[0], pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_left), components[1], pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_bottom), components[2], pesudoClass, NO);
        } break;
        case 4: {
            RUN_RULE_ACTION(self, RULE(padding_top), components[0], pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_left), components[1], pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_bottom), components[2], pesudoClass, NO);
            RUN_RULE_ACTION(self, RULE(padding_right), components[3], pesudoClass, NO);
        } break;
            
        default:
            break;
    }
    return YES;
}

DEF_RULE_ACTION(text) {
    return YES;
}

DEF_RULE_ACTION(text_color) {
    return YES;
}

DEF_RULE_ACTION(image) {
    return YES;
}

DEF_RULE_ACTION(image_web) {
    return YES;
}

DEF_RULE_ACTION(font) {
    return YES;
}

DEF_RULE_ACTION(text_align) {
    return YES;
}

DEF_RULE_ACTION(text_shadow) {
    return YES;
}


@end
