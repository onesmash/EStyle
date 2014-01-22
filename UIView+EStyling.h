//
//  UIView+EStyling.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EStyleable.h"

@interface UIView (EStyling) <EStyleable> 

@property (nonatomic, copy) NSString *styleId;

@property (nonatomic, copy) NSString *styleClass;

@property (nonatomic, strong) NSDictionary *rulesets;

@property (readonly, nonatomic, weak) id styleParent;

@property (readonly, nonatomic, copy) NSArray *styleChildren;

@end
