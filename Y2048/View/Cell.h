//
//  Cell.h
//  Y2048
//
//  Created by jackey on 2018/1/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Position;

@protocol cellAnimationDelegate<NSObject>

- (void)cellAnimationCompelete;

@end


@interface Cell : UIView

@property (nonatomic,strong) Position *positon;

@property (nonatomic,assign) NSInteger score;

@property (nonatomic,weak) id<cellAnimationDelegate> delegate;

@property (nonatomic,assign,readonly) NSInteger level;


@property (nonatomic,strong) UIImageView *bgImgView;


- (instancetype)initWithPosition:(Position *)postion;
+ (instancetype)cellWithPosition:(Position *)position;

+ (instancetype)cellWithlevel:(NSInteger)level;

- (void)showWithScore:(NSInteger)score;

- (void)scoreLevelUp;

- (BOOL)isleftWithCell:(Cell *)cell;

- (BOOL)isUpWithCell:(Cell *)cell;


@end
