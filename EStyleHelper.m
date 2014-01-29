//
//  EStyleHelper.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-22.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStyleHelper.h"

DEF_PSEUDO_CLASS(_none_);
DEF_PSEUDO_CLASS(normal);
DEF_PSEUDO_CLASS(selected);
DEF_PSEUDO_CLASS(highlighted);
DEF_PSEUDO_CLASS(disabled);

@implementation EStyleHelper

+ (NSDictionary *)stringToJsonDict:(NSString *)str {
    if(str == nil || [str isEqual:[NSNull null]]) return nil;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+ (NSString *)bundleResource:(NSString *)path {
    return [path substringFromIndex:9];
}

+ (NSString *)documentsResource:(NSString *)path {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[path substringFromIndex:12]];
}

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
        unit.type = PIXEL_UNIT;
        unit.value = value.floatValue;
    } while (false);
    return unit;
}

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

DEF_STRING_TO_P(UIColor) {
    static NSDictionary *colorTable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                      RGBCOLOR(240,248,255), @"aliceblue",
                      RGBCOLOR(250,235,215), @"antiquewhite",
                      RGBCOLOR(0,255,255), @"aqua",
                      RGBCOLOR(127,255,212), @"aquamarine",
                      RGBCOLOR(240,255,255), @"azure",
                      RGBCOLOR(245,245,220), @"beige",
                      RGBCOLOR(255,228,196), @"bisque",
                      RGBCOLOR(0,0,0), @"black",
                      RGBCOLOR(255,235,205), @"blanchedalmond",
                      RGBCOLOR(0,0,255), @"blue",
                      RGBCOLOR(138,43,226), @"blueviolet",
                      RGBCOLOR(165,42,42), @"brown",
                      RGBCOLOR(222,184,135), @"burlywood",
                      RGBCOLOR(95,158,160), @"cadetblue",
                      RGBCOLOR(127,255,0), @"chartreuse",
                      RGBCOLOR(210,105,30), @"chocolate",
                      RGBCOLOR(255,127,80), @"coral",
                      RGBCOLOR(100,149,237), @"cornflowerblue",
                      RGBCOLOR(255,248,220), @"cornsilk",
                      RGBCOLOR(220,20,60), @"crimson",
                      RGBCOLOR(0,255,255), @"cyan",
                      RGBCOLOR(0,0,139), @"darkblue",
                      RGBCOLOR(0,139,139), @"darkcyan",
                      RGBCOLOR(184,134,11), @"darkgoldenrod",
                      RGBCOLOR(169,169,169), @"darkgray",
                      RGBCOLOR(0,100,0), @"darkgreen",
                      RGBCOLOR(169,169,169), @"darkgrey",
                      RGBCOLOR(189,183,107), @"darkkhaki",
                      RGBCOLOR(139,0,139), @"darkmagenta",
                      RGBCOLOR(85,107,47), @"darkolivegreen",
                      RGBCOLOR(255,140,0), @"darkorange",
                      RGBCOLOR(153,50,204), @"darkorchid",
                      RGBCOLOR(139,0,0), @"darkred",
                      RGBCOLOR(233,150,122), @"darksalmon",
                      RGBCOLOR(143,188,143), @"darkseagreen",
                      RGBCOLOR(72,61,139), @"darkslateblue",
                      RGBCOLOR(47,79,79), @"darkslategray",
                      RGBCOLOR(47,79,79), @"darkslategrey",
                      RGBCOLOR(0,206,209), @"darkturquoise",
                      RGBCOLOR(148,0,211), @"darkviolet",
                      RGBCOLOR(255,20,147), @"deeppink",
                      RGBCOLOR(0,191,255), @"deepskyblue",
                      RGBCOLOR(105,105,105), @"dimgray",
                      RGBCOLOR(105,105,105), @"dimgrey",
                      RGBCOLOR(30,144,255), @"dodgerblue",
                      RGBCOLOR(178,34,34), @"firebrick",
                      RGBCOLOR(255,250,240), @"floralwhite",
                      RGBCOLOR(34,139,34), @"forestgreen",
                      RGBCOLOR(255,0,255), @"fuchsia",
                      RGBCOLOR(220,220,220), @"gainsboro",
                      RGBCOLOR(248,248,255), @"ghostwhite",
                      RGBCOLOR(255,215,0), @"gold",
                      RGBCOLOR(218,165,32), @"goldenrod",
                      RGBCOLOR(128,128,128), @"gray",
                      RGBCOLOR(0,128,0), @"green",
                      RGBCOLOR(173,255,47), @"greenyellow",
                      RGBCOLOR(128,128,128), @"grey",
                      RGBCOLOR(240,255,240), @"honeydew",
                      RGBCOLOR(255,105,180), @"hotpink",
                      RGBCOLOR(205,92,92), @"indianred",
                      RGBCOLOR(75,0,130), @"indigo",
                      RGBCOLOR(255,255,240), @"ivory",
                      RGBCOLOR(240,230,140), @"khaki",
                      RGBCOLOR(230,230,250), @"lavender",
                      RGBCOLOR(255,240,245), @"lavenderblush",
                      RGBCOLOR(124,252,0), @"lawngreen",
                      RGBCOLOR(255,250,205), @"lemonchiffon",
                      RGBCOLOR(173,216,230), @"lightblue",
                      RGBCOLOR(240,128,128), @"lightcoral",
                      RGBCOLOR(224,255,255), @"lightcyan",
                      RGBCOLOR(250,250,210), @"lightgoldenrodyellow",
                      RGBCOLOR(211,211,211), @"lightgray",
                      RGBCOLOR(144,238,144), @"lightgreen",
                      RGBCOLOR(211,211,211), @"lightgrey",
                      RGBCOLOR(255,182,193), @"lightpink",
                      RGBCOLOR(255,160,122), @"lightsalmon",
                      RGBCOLOR(32,178,170), @"lightseagreen",
                      RGBCOLOR(135,206,250), @"lightskyblue",
                      RGBCOLOR(119,136,153), @"lightslategray",
                      RGBCOLOR(119,136,153), @"lightslategrey",
                      RGBCOLOR(176,196,222), @"lightsteelblue",
                      RGBCOLOR(255,255,224), @"lightyellow",
                      RGBCOLOR(0,255,0), @"lime",
                      RGBCOLOR(50,205,50), @"limegreen",
                      RGBCOLOR(250,240,230), @"linen",
                      RGBCOLOR(255,0,255), @"magenta",
                      RGBCOLOR(128,0,0), @"maroon",
                      RGBCOLOR(102,205,170), @"mediumaquamarine",
                      RGBCOLOR(0,0,205), @"mediumblue",
                      RGBCOLOR(186,85,211), @"mediumorchid",
                      RGBCOLOR(147,112,219), @"mediumpurple",
                      RGBCOLOR(60,179,113), @"mediumseagreen",
                      RGBCOLOR(123,104,238), @"mediumslateblue",
                      RGBCOLOR(0,250,154), @"mediumspringgreen",
                      RGBCOLOR(72,209,204), @"mediumturquoise",
                      RGBCOLOR(199,21,133), @"mediumvioletred",
                      RGBCOLOR(25,25,112), @"midnightblue",
                      RGBCOLOR(245,255,250), @"mintcream",
                      RGBCOLOR(255,228,225), @"mistyrose",
                      RGBCOLOR(255,228,181), @"moccasin",
                      RGBCOLOR(255,222,173), @"navajowhite",
                      RGBCOLOR(0,0,128), @"navy",
                      RGBCOLOR(253,245,230), @"oldlace",
                      RGBCOLOR(128,128,0), @"olive",
                      RGBCOLOR(107,142,35), @"olivedrab",
                      RGBCOLOR(255,165,0), @"orange",
                      RGBCOLOR(255,69,0), @"orangered",
                      RGBCOLOR(218,112,214), @"orchid",
                      RGBCOLOR(238,232,170), @"palegoldenrod",
                      RGBCOLOR(152,251,152), @"palegreen",
                      RGBCOLOR(175,238,238), @"paleturquoise",
                      RGBCOLOR(219,112,147), @"palevioletred",
                      RGBCOLOR(255,239,213), @"papayawhip",
                      RGBCOLOR(255,218,185), @"peachpuff",
                      RGBCOLOR(205,133,63), @"peru",
                      RGBCOLOR(255,192,203), @"pink",
                      RGBCOLOR(221,160,221), @"plum",
                      RGBCOLOR(176,224,230), @"powderblue",
                      RGBCOLOR(128,0,128), @"purple",
                      RGBCOLOR(255,0,0), @"red",
                      RGBCOLOR(188,143,143), @"rosybrown",
                      RGBCOLOR(65,105,225), @"royalblue",
                      RGBCOLOR(139,69,19), @"saddlebrown",
                      RGBCOLOR(250,128,114), @"salmon",
                      RGBCOLOR(244,164,96), @"sandybrown",
                      RGBCOLOR(46,139,87), @"seagreen",
                      RGBCOLOR(255,245,238), @"seashell",
                      RGBCOLOR(160,82,45), @"sienna",
                      RGBCOLOR(192,192,192), @"silver",
                      RGBCOLOR(135,206,235), @"skyblue",
                      RGBCOLOR(106,90,205), @"slateblue",
                      RGBCOLOR(112,128,144), @"slategray",
                      RGBCOLOR(112,128,144), @"slategrey",
                      RGBCOLOR(255,250,250), @"snow",
                      RGBCOLOR(0,255,127), @"springgreen",
                      RGBCOLOR(70,130,180), @"steelblue",
                      RGBCOLOR(210,180,140), @"tan",
                      RGBCOLOR(0,128,128), @"teal",
                      RGBCOLOR(216,191,216), @"thistle",
                      RGBCOLOR(255,99,71), @"tomato",
                      RGBCOLOR(64,224,208), @"turquoise",
                      RGBCOLOR(238,130,238), @"violet",
                      RGBCOLOR(245,222,179), @"wheat",
                      RGBCOLOR(255,255,255), @"white",
                      RGBCOLOR(245,245,245), @"whitesmoke",
                      RGBCOLOR(255,255,0), @"yellow",
                      RGBCOLOR(154,205,50), @"yellowgreen",
                      
                      // System colors
                      [UIColor lightTextColor],                @"lightTextColor",
                      [UIColor darkTextColor],                 @"darkTextColor",
                      [UIColor groupTableViewBackgroundColor], @"groupTableViewBackgroundColor",
                      [UIColor viewFlipsideBackgroundColor],   @"viewFlipsideBackgroundColor",
                      nil];
    });
    UIColor* color = [colorTable objectForKey:value];
    if(color != nil) return color;
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

typedef UIImage NormalImage;

typedef UIImage ResizableImage;

typedef UIImage ColorImage;

typedef UIImage WebImage;

DEF_STRING_TO_P(NormalImage) {
    UIImage *image = nil;
    do {
        if([value hasPrefix:@"bundle://"]) {
            image = [UIImage imageNamed:[EStyleHelper bundleResource:value]];
            break;
        }
        if([value hasPrefix:@"documents://"]) {
            image = [UIImage imageWithContentsOfFile:[EStyleHelper documentsResource:value]];
            break;
        }
       image = [UIImage imageNamed:value];
    } while (false);
    return image;
}

DEF_STRING_TO_P(ResizableImage) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    UIImage *image = STRING_TO_P(components[0], NormalImage);
    StyleUnit _top = STRING_TO(components[1], StyleUnit);
    StyleUnit _left = STRING_TO(components[2], StyleUnit);
    StyleUnit _bottom = STRING_TO(components[3], StyleUnit);
    StyleUnit _right = STRING_TO(components[4], StyleUnit);
    CGSize size = [image size];
    CGFloat top = 0;
    if(_top.type == PIXEL_UNIT) {
        top = _top.value;
    } else {
        top = size.height * _top.value;
    }
    CGFloat left = 0;
    if(_left.type == PIXEL_UNIT) {
        left = _left.value;
    } else {
        left = size.width * _left.value;
    }
    CGFloat bottom = 0;
    if(_bottom.type == PIXEL_UNIT) {
        bottom = _bottom.value;
    } else {
        bottom = size.height * _bottom.value;
    }
    CGFloat right = 0;
    if(_right.type == PIXEL_UNIT) {
        right = _right.value;
    } else {
        right = size.width * _right.value;
    }
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)];
}

DEF_STRING_TO_P(ColorImage) {
    UIColor *color = STRING_TO_P(value, UIColor);
    CGFloat alphaChannel;
    [color getRed:NULL green:NULL blue:NULL alpha:&alphaChannel];
    BOOL opaqueImage = (alphaChannel == 1.0);
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, opaqueImage, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

DEF_STRING_TO_P(UIImage) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    if(components.count == 5) {
        return STRING_TO_P(value, ResizableImage);
    }
    UIImage *image = STRING_TO_P(value, NormalImage);
    if(image) {
        return image;
    } else {
        return STRING_TO_P(value, ColorImage);
    }
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

DEF_STRING_TO(UIControlState) {
    UIControlState state = UIControlStateNormal;
    do {
        if(PESUDOCLASS_HASTYPE_OF(value, normal)) {
            state = UIControlStateNormal;
            break;
        }
        if(PESUDOCLASS_HASTYPE_OF(value, highlighted)) {
            state = UIControlStateHighlighted;
            break;
        }
        if(PESUDOCLASS_HASTYPE_OF(value, selected)) {
            state = UIControlStateSelected;
            break;
        }
        if(PESUDOCLASS_HASTYPE_OF(value, disabled)) {
            state = UIControlStateDisabled;
            break;
        }
    } while (false);
    return state;
}

DEF_STRING_TO_P(StyleUnitArray) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *component in components) {
        StyleUnit unit = STRING_TO(component, StyleUnit);
        NSValue *tmp = [NSValue valueWithBytes:&unit objCType:@encode(StyleUnit)];
        [array addObject:tmp];
    }
    return  array;
}

DEF_STRING_TO_P(FilePath) {
    NSString *filePath = nil;
    do {
        if([value hasPrefix:@"bundle://"]) {
            NSString *path = [EStyleHelper bundleResource:value];
            NSString *name = [path stringByDeletingPathExtension];
            NSString *extension = [path pathExtension];
            filePath = [[NSBundle mainBundle] pathForResource:name ofType:extension];
            break;
        }
        if([value hasPrefix:@"documents://"]) {
            filePath = [EStyleHelper documentsResource:value];
            break;
        }
    } while (false);
    return filePath;
}

DEF_STRING_TO(CGRect) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    StyleUnit x = STRING_TO(components[0], StyleUnit);
    StyleUnit y = STRING_TO(components[1], StyleUnit);
    StyleUnit width = STRING_TO(components[2], StyleUnit);
    StyleUnit height = STRING_TO(components[3], StyleUnit);
    return CGRectMake(x.value, y.value, width.value, height.value);
}

DEF_STRING_TO(UITableViewCellStyle) {
    UITableViewCellStyle cellStyle = UITableViewCellStyleDefault;
    do {
        if([value isEqualToString:@"UITableViewCellStyleDefault"]) {
            cellStyle = UITableViewCellStyleDefault;
            break;
        }
        if([value isEqualToString:@"UITableViewCellStyleValue1"]) {
            cellStyle = UITableViewCellStyleValue1;
            break;
        }
        if([value isEqualToString:@"UITableViewCellStyleValue2"]) {
            cellStyle = UITableViewCellStyleValue2;
            break;
        }
        if([value isEqualToString:@"UITableViewCellStyleSubtitle"]) {
            cellStyle = UITableViewCellStyleSubtitle;
            break;
        }
    } while (false);
    return cellStyle;
}

DEF_STRING_TO_P(UIFont) {
    // style|name| size = 17
    NSArray *components = [value componentsSeparatedByString:@" "];
    UIFont *font = nil;
    switch (components.count) {
        case 1: {
            font = [UIFont systemFontOfSize:STRING_TO(components[0], CGFloat)];
        } break;
        case 2: {
            NSString *style = components[0];
            CGFloat size = STRING_TO(components[1], CGFloat);
            do {
                if([style isEqualToString:@"normal"]) {
                    font = [UIFont systemFontOfSize:size];
                    break;
                }
                if([style isEqualToString:@"bold"]) {
                    font = [UIFont boldSystemFontOfSize:size];
                    break;
                }
                if([style isEqualToString:@"italic"]) {
                    font = [UIFont italicSystemFontOfSize:size];
                    break;
                }
                font = [UIFont fontWithName:style size:size];
            } while (false);
        } break;
        default:
            break;
    }
    return font;
}

DEF_STRING_TO(NSTextAlignment) {
    NSTextAlignment textAlign = NSTextAlignmentLeft;
    do {
        if([value isEqualToString:@"left"]) {
            textAlign = NSTextAlignmentLeft;
            break;
        }
        if([value isEqualToString:@"center"]) {
            textAlign = NSTextAlignmentCenter;
            break;
        }
        if([value isEqualToString:@"right"]) {
            textAlign = NSTextAlignmentRight;
            break;
        }
    } while (false);
    return textAlign;
}

DEF_STRING_TO_P(Shadow) {
    NSArray *components = [value componentsSeparatedByString:@" "];
    CGFloat hShadow = ((NSString *)components[0]).floatValue;
    CGFloat vShadow = ((NSString *)components[1]).floatValue;
    CGSize _shadowSize = CGSizeMake(hShadow, vShadow);
    NSValue *shadowSize = [NSValue valueWithBytes:&_shadowSize objCType:@encode(CGSize)];
    UIColor *color = STRING_TO_P(components[2], UIColor);
    return [NSArray arrayWithObjects:shadowSize, color, nil];
}

@end
