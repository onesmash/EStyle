//
//  EStyleable.h
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol EStyleable <NSObject>

@required

@property (nonatomic, copy) NSString *styleId;

@property (nonatomic, copy) NSString *styleClass;

@property (readonly, nonatomic, weak) id styleParent;

@property (readonly, nonatomic, copy) NSArray *styleChildren;

@optional

@property (nonatomic, strong) NSDictionary *rulesets;

//- (void)updateStyle;

//- (void)updateStyleNonRecursively;

@end
