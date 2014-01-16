//
//  EStyleRuleset.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStyleRuleset.h"
#import "EStyleEngine.h"

@implementation EStyleRuleset

- (id)init {
    self = [super init];
    if(self) {
        _pesudoClass = [PSEUDO_CLASS(_none_) copy];
        _rawRuleset = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithPesudoclass:(NSString *)pesudoClass {
    self = [self init];
    if(self) {
        [_pesudoClass release];
        _pesudoClass = [pesudoClass copy];
    }
    return self;
}

- (id)initWithPesudoclass:(NSString *)pesudoClass from:(NSDictionary *)dict {
    self = [self initWithPesudoclass:pesudoClass];
    if(self) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self addRule:key withValue:obj];
        }];
    }
    return self;
}

- (void)dealloc {
    [_rawRuleset release];
    [_pesudoClass release];
    [super dealloc];
}

- (NSDictionary *)ruleset {
    return _rawRuleset;
}

- (void)addRule:(NSString *)rule withValue:(NSString *)value {
    [_rawRuleset setObject:value forKey:rule];
}

- (void)addRulesFrom:(NSDictionary *)rules {
    [rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self addRule:key withValue:obj];
    }];
}

- (void)merge:(EStyleRuleset *)ruleset {
    if([self.pesudoClass isEqualToString:ruleset.pesudoClass]) {
        [ruleset.ruleset enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self addRule:key withValue:obj];
        }];
    } else {
        return;
    }
}

@end
