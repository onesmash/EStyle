//
//  EStylesheet.h
//
//  Created by Xuhui on 14-1-13.
//

#import <Foundation/Foundation.h>

@interface EStylesheet : NSObject {
@private
    NSDictionary *_styleSheet;
}

@property (readonly, strong) NSArray *errors;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, copy) NSString *pathPrefix;

@property (readonly, strong) NSDictionary *sheet;

+ (instancetype)stylesheet;

- (BOOL)loadFromDict:(NSDictionary *)dict;

- (BOOL)loadFromSource:(NSString *)source;

- (BOOL)loadFromFile:(NSString *)filePath;

- (BOOL)loadFromFile:(NSString *)filePath withPrefix:(NSString *)prefix;

@end
