//
//  CellCombine.m
//  Y2048
//
//  Created by jackey on 2018/1/4.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "CellCombine.h"
#import "Cell.h"

@implementation CellCombine

+ (instancetype)CellCombineWithMainCell:(Cell *)main subCell:(Cell *)sub endPositon:(Position *)pos {
    CellCombine *cc = [[CellCombine alloc] init];
    cc.score = main.score *2;
    cc.mainCell = main;
    cc.subCell = sub;
    cc.endPosition = pos;
    return cc;
}

@end
