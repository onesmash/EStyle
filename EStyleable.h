//
//  EStyleable.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Building,
    Styling,
    Idle
} StylePhase;


@protocol EStyleable <NSObject>

@required

@property (nonatomic, copy) NSString *styleId;

@property (nonatomic, copy) NSString *styleClass;

@property (readonly, nonatomic, weak) id styleParent;

@property (readonly, nonatomic, copy) NSArray *styleChildren;

@property (nonatomic) StylePhase phase;

@optional

@property (nonatomic, strong) NSMutableDictionary *rulesets;

- (void)addCustomSubview:(UIView *)view;

- (UIView *)creatViewFromConfig:(NSDictionary *)config;

- (void)updateStyleRules:(NSDictionary *)rules withPseudoClass:(NSString *)pseudoClass;

@end
