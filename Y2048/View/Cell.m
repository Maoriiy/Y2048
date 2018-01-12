//
//  Cell.m
//  Y2048
//
//  Created by jackey on 2018/1/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "Cell.h"
#import "Position.h"


@implementation Cell


-(instancetype)initWithPosition:(Position *)position {
    if (self = [super init]) {
        static CGFloat gap = 6.0;
        static CGFloat width = 87.5;
        _positon = position;
        _level =position.row *4 + position.line;
        self.frame = CGRectMake(position.line * (gap + width) + gap, position.row * (gap + width) + gap, width, width);
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;

        _score = 0;
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.bgImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        
        [self addSubview:self.bgImgView];
       
    }
    return self;
}

+(instancetype)cellWithPosition:(Position *)position {
    Cell *cell = [[Cell alloc] initWithPosition:position];
    return cell;
}

+(instancetype)cellWithlevel:(NSInteger)level {
    Cell *cell = [Cell cellWithPosition:[Position positonWithLevel:level]];
    return cell;
}

- (void)showWithScore:(NSInteger)score {
    self.score = score;

    self.bgImgView.frame = CGRectZero;
    
    self.bgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"score%zd",score]];
    
    CGRect nowBounds = self.layer.bounds;
    self.bounds = CGRectZero;

    __weak typeof(self) wSelf = self;
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:100 initialSpringVelocity:5.0 options:UIViewAnimationOptionPreferredFramesPerSecond60 animations:^{
        __strong typeof(self) sSelf = wSelf;
        sSelf.bounds = nowBounds;

        sSelf.bgImgView.frame = nowBounds;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)scoreLevelUp {
    
    NSInteger score = self.score;
    _score = score *2;
    
    self.bgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"score%zd",_score]];
    [self popAnimation];
}

- (void)popAnimation {
    CGRect realBounds = self.bounds;
    __weak typeof(self) wSelf = self;
    [UIView animateWithDuration:0.07 delay:0.0 usingSpringWithDamping:3 initialSpringVelocity:10.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong typeof(self) sSelf = wSelf;
        sSelf.bounds = CGRectMake(0, 0, 100, 100);
        
        sSelf.bgImgView.frame = CGRectMake(0, 0, 100, 100);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            __strong typeof(self) sSelf = wSelf;
            sSelf.bounds = realBounds;
            
            sSelf.bgImgView.frame = realBounds;
        } completion:^(BOOL finished) {
            [self.delegate cellAnimationCompelete];
        }];

    }];
}

- (BOOL)isleftWithCell:(Cell *)cell {
    if (self.positon.line < cell.positon.line) {
        return YES;
    }
    return  NO;
    
}

- (BOOL)isUpWithCell:(Cell *)cell {
    if (self.positon.row  < cell.positon.row) {
        return YES;
    }
    return NO;
}

- (void)setPositon:(Position *)positon {
    _positon = positon;
    _level = positon.row *4 + positon.line;
}

@end
