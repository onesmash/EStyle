//
//  UILabel+EStyling.m
//
//  Created by Xuhui on 14-1-23.
//

#import "UILabel+EStyling.h"
#import "EStyleHelper.h"

@implementation UILabel (EStyling)

DEF_RULE_ACTION(text) {
    self.text = value;
    return YES;
}

DEF_RULE_ACTION(text_color) {
    UIColor *color = STRING_TO_P(value, UIColor);
    self.textColor = color;
    return YES;
}

DEF_RULE_ACTION(font) {
    UIFont *font = STRING_TO_P(value, UIFont);
    self.font = font;
    return YES;
}

DEF_RULE_ACTION(text_align) {
    NSTextAlignment textAlign = STRING_TO(value, NSTextAlignment);
    self.textAlignment = textAlign;
    return YES;
}

DEF_RULE_ACTION(text_shadow) {
    NSArray *shadow = STRING_TO_P(value, Shadow);
    NSValue *_shadowOffset = shadow[0];
    CGSize shadowOffset;
    [_shadowOffset getValue:&shadowOffset];
    UIColor *color = shadow[1];
    self.shadowOffset = shadowOffset;
    self.shadowColor = color;
    return YES;
}

@end
