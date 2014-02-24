//
//  UITableViewCell+EStyling.m
//
//  Created by Xuhui on 14-1-22.
//

#import "UITableViewCell+EStyling.h"
#import "EStyleHelper.h"

@implementation UITableViewCell (EStyling)

- (void)addCustomSubview:(UIView *)view {
    [self.contentView addSubview:view];
}

DEF_BUILDING_PHASE_RULE_ACTION(initWithStyle_reuseIdentifier) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    [self initWithStyle:STRING_TO(components[0], UITableViewCellStyle) reuseIdentifier:components[1]];
    return YES;
}

DEF_RULE_ACTION(background_image) {
    UIImage *image = STRING_TO_P(value, UIImage);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    do {
        if(PESUDOCLASS_HASTYPE_OF(pesudoClass, normal)) {
            self.backgroundView = imageView;
            break;
        }
        if(PESUDOCLASS_HASTYPE_OF(pesudoClass, highlighted)) {
            self.selectedBackgroundView = imageView;
            break;
        }
    } while (false);
    return YES;
    
}

DEF_RULE_ACTION(background_color) {
    UIImage *image = STRING_TO_P(value, UIImage);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    do {
        if(PESUDOCLASS_HASTYPE_OF(pesudoClass, normal)) {
            self.backgroundView = imageView;
            break;
        }
        if(PESUDOCLASS_HASTYPE_OF(pesudoClass, highlighted)) {
            self.selectedBackgroundView = imageView;
            break;
        }
    } while (false);
    return YES;
}

@end
