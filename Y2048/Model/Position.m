//
//  Position.m
//  Y2048
//
//  Created by jackey on 2018/1/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "Position.h"

@implementation Position


+(instancetype)positonWithRow:(NSInteger)row line:(NSInteger)line {
    Position *pos = [[Position alloc] init];
    pos.row = row;
    pos.line = line;
    return pos;
}

+(instancetype)positonWithLevel:(NSInteger)level {
    Position *pos = [[Position alloc] init];
    pos.row = level / 4;
    pos.line = level % 4;
    return pos;
}

@end
