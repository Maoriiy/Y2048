//
//  CellCombine.h
//  Y2048
//
//  Created by jackey on 2018/1/4.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Cell,Position;
@interface CellCombine : NSObject

@property (nonatomic,weak) Cell *mainCell;

@property (nonatomic,weak) Cell *subCell;

@property (nonatomic,strong) Position *endPosition;

@property (nonatomic,assign) NSInteger score;

+ (instancetype)CellCombineWithMainCell:(Cell *)main subCell:(Cell *)sub endPositon:(Position *)pos;

@end
