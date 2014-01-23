//
//  UIView+EStyling.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+EStyling.h"
#import "EStyleHelper.h"

static NSString *const kEStyleIdKey = @"kEStyleIdKey";
static NSString *const kEStyleClassKey = @"kEStyleClassKey";
static NSString *const kEStyleRulesetKey = @"kEStyleRulesetKey";

@implementation UIView (EStyling)

- (NSString *)styleId {
    return objc_getAssociatedObject(self, (__bridge const void *)(kEStyleIdKey));
}

- (void)setStyleId:(NSString *)styleId {
    objc_setAssociatedObject(self, (__bridge const void *)(kEStyleIdKey), styleId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)styleClass {
    return objc_getAssociatedObject(self, (__bridge const void *)(kEStyleClassKey));
}

- (void)setStyleClass:(NSString *)styleClass {
    objc_setAssociatedObject(self, (__bridge const void *)(kEStyleClassKey), styleClass, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)rulesets {
    return objc_getAssociatedObject(self, (__bridge const void *)(kEStyleRulesetKey));
}

- (void)setRulesets:(NSDictionary *)rulesets {
    objc_setAssociatedObject(self, (__bridge const void *)(kEStyleRulesetKey), rulesets, OBJC_ASSOCIATION_RETAIN);
}


- (id)styleParent {
    return [self superview];
}

- (NSArray *)styleChildren {
    return [self subviews];
}

DEF_RULE_ACTION(background_color) {
    self.backgroundColor = STRING_TO_P(value, UIColor);
}

DEF_RULE_ACTION(hidden) {
    [self setHidden:STRING_TO(value, BOOL)];
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
}

DEF_RULE_ACTION(opacity) {
    self.alpha = STRING_TO(value, CGFloat);
}

DEF_RULE_ACTION(border_radius) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.layer.cornerRadius = unit.value;
    }
}

DEF_RULE_ACTION(border_width) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.layer.borderWidth = unit.value;
    }
}

DEF_RULE_ACTION(border_color) {
    UIColor *color = STRING_TO_P(value, UIColor);
    self.layer.borderColor = color.CGColor;
}

DEF_RULE_ACTION(autoresizing) {
    self.autoresizingMask = STRING_TO(value, UIViewAutoresizing);
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
            CGRect frame = self.frame;
            CGFloat height = frame.size.height;
            [self sizeToFit];
            frame = self.frame;
            frame.size.height = height;
            self.frame = frame;
        } break;
        default:
            break;
    }
    
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
            CGRect frame = self.frame;
            CGFloat width = frame.size.width;
            [self sizeToFit];
            frame = self.frame;
            frame.size.width = width;
            self.frame = frame;
        } break;
        default:
            break;
    }
    
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
}


@end
