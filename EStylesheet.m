//
//  EStylesheet.m
//  yixin_iphone
//
//  Created by Xuhui on 14-1-13.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "EStylesheet.h"
#import "EStyleParser.h"

@interface EStylesheet ()



@end

@implementation EStylesheet

- (id)init {
    self = [super init];
    if(self) {
        _errors = nil;
        _filePath = nil;
        _pathPrefix = nil;
        _styleSheet = nil;
    }
    return self;
 
}

- (BOOL)loadFromSource:(NSString *) source {
    _styleSheet = [EStyleParser parse:source];
    if(_styleSheet) return YES;
    else return NO;
}

- (BOOL)loadFromFile:(NSString *)filePath {
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.filePath = filePath;
        NSString *source = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        return [self loadFromSource:source];
    } else {
        return NO;
    }
}

- (BOOL)loadFromFile:(NSString *)filePath withPrefix:(NSString *)prefix {
    NSString *path = [prefix stringByAppendingPathComponent:filePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.filePath = filePath;
        self.pathPrefix = prefix;
        NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        return [self loadFromSource:source];
    } else {
        return NO;
    }
}

- (NSDictionary *)sheet {
    return _styleSheet;
}

+ (instancetype)stylesheet {
    EStylesheet *sheet = [[EStylesheet alloc] init];
    return sheet;
}

@end
