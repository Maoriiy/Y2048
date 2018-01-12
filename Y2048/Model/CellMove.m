//
//  CellMove.m
//  Y2048
//
//  Created by jackey on 2018/1/4.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "CellMove.h"
#import "Cell.h"
#import "Position.h"

@implementation CellMove

+(instancetype)cellMoveWithMainCell:(Cell *)main afterPos:(Position *)pos {
    CellMove *cm = [[CellMove alloc] init];
    cm.mainCell  = main;

    cm.cellBeforePos = main.positon;
    cm.cellAfterPos = pos;
    return cm;
}

@end
