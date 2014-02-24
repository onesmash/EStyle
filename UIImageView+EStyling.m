//
//  UIImageView+EStyling.m
//
//  Created by Xuhui on 14-1-27.
//

#import "UIImageView+EStyling.h"
#import "UIImageView+WebCache.h"
#import "EStyleHelper.h"

@implementation UIImageView (EStyling)

DEF_RULE_ACTION(image) {
    UIImage *image = STRING_TO_P(value, UIImage);
    if(PESUDOCLASS_HASTYPE_OF(pesudoClass, normal)) {
        self.image = image;
    } else {
        self.highlightedImage = image;
    }
    return YES;
}

DEF_RULE_ACTION(image_web) {
    if([value hasPrefix:@"http://"] || [value hasPrefix:@"https://"]) {
        NSArray *components = [value componentsSeparatedByString:@" "];
        NSURL *url = [NSURL URLWithString:components[0]];
        UIImage *placeholderImage = components.count == 2 ? STRING_TO_P(components[1], UIImage) : nil;
        [self setImageWithURL:url placeholderImage:placeholderImage];
    }
    return YES;
}

@end
