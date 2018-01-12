//
//  CellMove.h
//  Y2048
//
//  Created by jackey on 2018/1/4.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Cell,Position;
@interface CellMove : NSObject

@property (nonatomic,weak) Cell *mainCell;

@property (nonatomic,strong) Position *cellBeforePos;

@property (nonatomic,strong) Position *cellAfterPos;



+ (instancetype)cellMoveWithMainCell:(Cell *)main afterPos:(Position *)pos;

@end
