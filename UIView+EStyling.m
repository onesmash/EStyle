//
//  UIView+EStyling.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+EStyling.h"
#import "EStyleRuleset.h"

static NSString *const kEStyleIdKey = @"kEStyleIdKey";
static NSString *const kEStyleClassKey = @"kEStyleClassKey";
static NSString *const kEStyleRulesetKey = @"kEStyleRulesetKey";

@implementation UIView (EStyling)

- (NSString *)styleId {
    return objc_getAssociatedObject(self, kEStyleIdKey);
}

- (void)setStyleId:(NSString *)styleId {
    objc_setAssociatedObject(self, kEStyleIdKey, styleId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)styleClass {
    return objc_getAssociatedObject(self, kEStyleClassKey);
}

- (void)setStyleClass:(NSString *)styleClass {
    objc_setAssociatedObject(self, kEStyleClassKey, styleClass, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)rulesets {
    return objc_getAssociatedObject(self, kEStyleRulesetKey);
}

- (void)setRulesets:(NSDictionary *)rulesets {
    objc_setAssociatedObject(self, kEStyleRulesetKey, rulesets, OBJC_ASSOCIATION_RETAIN);
}


- (id)styleParent {
    return [self superview];
}

- (NSArray *)styleChildren {
    return [self subviews];
}

@end
