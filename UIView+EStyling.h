//
//  UIView+EStyling.h
//
//  Created by Xuhui on 14-1-13.
//

#import <UIKit/UIKit.h>
#import "EStyleable.h"

@interface UIView (EStyling) <EStyleable>

@property (nonatomic, copy) NSString *styleId;

@property (nonatomic, copy) NSString *styleClass;

@property (nonatomic, strong) NSMutableDictionary *rulesets;

@property (readonly, nonatomic, weak) id styleParent;

@property (readonly, nonatomic, copy) NSArray *styleChildren;

@property (nonatomic) StylePhase phase;

- (void)addCustomSubview:(UIView *)view;

- (void)updateStyleRules:(NSDictionary *)rules withPseudoClass:(NSString *)pseudoClass;

- (void)sizeToFitSubviews;

@end
