//
//  UITableViewCell+EStyling.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-22.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "UITableViewCell+EStyling.h"
#import "EStyleHelper.h"

@implementation UITableViewCell (EStyling)

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
    
}

@end
