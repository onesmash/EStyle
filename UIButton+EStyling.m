//
//  UIButton+EStyling.m
//
//  Created by Xuhui on 14-1-24.
//

#include <objc/message.h>
#import "UIButton+EStyling.h"
#import "EStyleHelper.h"

@implementation UIButton (EStyling)

DEF_RULE_ACTION(text) {
    UIControlState state = STRING_TO(pesudoClass, UIControlState);
    [self setTitle:value forState:state];
    return YES;
}

DEF_RULE_ACTION(padding_top) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.contentEdgeInsets = UIEdgeInsetsMake(unit.value, 0, 0, 0);
    }
    return YES;
}

DEF_RULE_ACTION(padding_left) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.contentEdgeInsets = UIEdgeInsetsMake(0, unit.value, 0, 0);
    }
    return YES;
}

DEF_RULE_ACTION(padding_bottom) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, unit.value, 0);
    }
    return YES;
}

DEF_RULE_ACTION(padding_right) {
    StyleUnit unit = STRING_TO(value, StyleUnit);
    if(unit.type == PIXEL_UNIT) {
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, unit.value);
    }
    return YES;
}

DEF_RULE_ACTION(padding) {
    StyleUnitArray *array = STRING_TO_P(value, StyleUnitArray);
    CGFloat insets[] = {0, 0, 0, 0};
    for (NSInteger i = 0; i < array.count; i++) {
        NSValue *tmp = array[i];
        StyleUnit unit;
        [tmp getValue:&unit];
        insets[i] = unit.value;
    }
    if(array.count == 1) {
        self.contentEdgeInsets = UIEdgeInsetsMake(insets[0], insets[0], insets[0], insets[0]);
    } else {
        self.contentEdgeInsets = UIEdgeInsetsMake(insets[0], insets[1], insets[2], insets[3]);
    }
    return YES;
}

DEF_RULE_ACTION(font) {
    UIFont *font = STRING_TO_P(value, UIFont);
    self.titleLabel.font = font;
    return YES;
}

DEF_RULE_ACTION(text_color) {
    UIColor *color = STRING_TO_P(value, UIColor);
    UIControlState state = STRING_TO(pesudoClass, UIControlState);
    [self setTitleColor:color forState:state];
    return YES;
}

DEF_RULE_ACTION(image) {
    UIImage *image = STRING_TO_P(value, UIImage);
    UIControlState state = STRING_TO(pesudoClass, UIControlState);
    [self setImage:image forState:state];
    return YES;
}

DEF_RULE_ACTION(text_align) {
    NSTextAlignment textAlign = STRING_TO(value, NSTextAlignment);
    self.titleLabel.textAlignment = textAlign;
    return YES;
}

DEF_RULE_ACTION(text_shadow) {
    NSArray *shadow = STRING_TO_P(value, Shadow);
    NSValue *_shadowOffset = shadow[0];
    CGSize shadowOffset;
    [_shadowOffset getValue:&shadowOffset];
    UIColor *color = shadow[1];
    self.titleLabel.shadowOffset = shadowOffset;
    UIControlState state = STRING_TO(pesudoClass, UIControlState);
    [self setTitleShadowColor:color forState:state];
    return YES;
}


@end
