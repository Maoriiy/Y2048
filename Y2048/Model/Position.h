//
//  Position.h
//  Y2048
//
//  Created by jackey on 2018/1/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject

/** 行 */
@property (nonatomic,assign) NSInteger row;


/** 列 */
@property (nonatomic,assign) NSInteger line;

+ (instancetype)positonWithRow:(NSInteger)row line:(NSInteger)line;
+ (instancetype)positonWithLevel:(NSInteger)level;
@end
