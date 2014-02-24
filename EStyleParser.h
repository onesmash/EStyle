//
//  EStyleParser.h
//
//  Created by Xuhui on 14-1-13.
//

#import <Foundation/Foundation.h>

@interface EStyleParser : NSObject

+ (NSDictionary *)parse:(NSString *)source;

+ (NSDictionary *)parseFromDict:(NSDictionary *)dict;

@end
