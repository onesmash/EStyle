//
//  EStyleParser.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStyleParser.h"
#import "EStyleEngine.h"
#import "EStyleRuleset.h"

@implementation EStyleParser

+ (NSDictionary *)parse:(NSString *)source {
    NSDictionary *json = [EStyleParser stringToJsonDict:source];
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    if(json != nil) {
        [json enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
            do {
                if([key hasPrefix:@"@"]) {
                    [res setObject:key forKey:obj];
                    break;
                }
                {
                    NSArray *strs = [key componentsSeparatedByString:@":"];
                    if(strs.count > 2) break;
                    
                    NSString *styleSelector = [strs objectAtIndex:0];
                    NSMutableDictionary *rulesets = [res objectForKey:styleSelector];
                    if(rulesets == nil) {
                        rulesets = [[NSMutableDictionary alloc] init];
                        [res setObject:rulesets forKey:styleSelector];
                        [rulesets release];
                    }
                    
                    NSString *pesudoClass = nil;

                    if(strs.count < 2) {
                        pesudoClass = PSEUDO_CLASS(_none_);
                    } else {
                        pesudoClass = [strs objectAtIndex:1];
                    }
                    
                    EStyleRuleset *ruleset = [rulesets objectForKey:pesudoClass];
                    if(ruleset == nil) {
                        ruleset = [[EStyleRuleset alloc] initWithPesudoclass:pesudoClass];
                        [rulesets setObject:ruleset forKey:pesudoClass];
                        [ruleset release];
                    }
                    [ruleset addRulesFrom:obj];
                    
                }
            } while (false);
        }];
        if(res.count > 0) return res;
        else return nil;
    } else {
        return nil;
    }
}

+ (NSDictionary *)stringToJsonDict:(NSString *)str {
    if(str == nil || [str isEqual:[NSNull null]]) return nil;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

@end
