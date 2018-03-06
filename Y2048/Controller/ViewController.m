//
//  ViewController.m
//  Y2048
//
//  Created by jackey on 2018/1/3.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ViewController.h"
#import "Position.h"
#import "Cell.h"
#import "CellMove.h"
#import "CellCombine.h"

@interface ViewController () <cellAnimationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestLabel;
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UIView *bestView;
@property (weak, nonatomic) IBOutlet UIButton *restartBtn;
@property (nonatomic,strong) UIView *overlay;
@property (nonatomic,strong) UILabel *transitionLabel;

@property (nonatomic,strong) NSMutableArray *cellArray;
@property (nonatomic,strong) NSMutableArray *moveArray;
@property (nonatomic,strong) NSMutableArray *combineArray;

@property (nonatomic,assign) BOOL lock;
@property (nonatomic,assign) BOOL win;

@property (nonatomic,assign) NSInteger score;
@property (nonatomic,assign) NSInteger turnScore;
@property (nonatomic,assign) NSInteger bestScore;

/** 棋盘 */
@property (weak, nonatomic) IBOutlet UIView *boardView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.score = 0;
    self.bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"BestScore"];
    
    
    [self subviewClipToCircle];
    
    [self setupGesture];
    
    [self gameStart];
    
}

- (void)gameStart {
    
    int a = arc4random_uniform(16);
    int b = arc4random_uniform(16);

    while (a==b) {
        b = arc4random_uniform(16);
    }
    
    Cell *c1 = [Cell cellWithlevel:a];
    c1.delegate = self;
    [self.boardView addSubview:c1];
    [self.cellArray addObject:c1];
    Cell *c2 = [Cell cellWithlevel:b];
    c2.delegate = self;
    [self.boardView addSubview:c2];
    [self.cellArray addObject:c2];
    [c1 showWithScore:[self getCellScore]];
    [c2 showWithScore:[self getCellScore]];
    
    self.lock = YES;
    self.win = NO;

}

- (int) getCellScore{
    int i = arc4random_uniform(6);
    if (i == 2) {
        return 4;
    }
    return 2;
}

- (void)setupGesture {
    self.view.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
}


- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (!self.lock ) {
        return;
    }
    self.lock = NO;
    switch (swipe.direction) {
        case 1:  //right
            [self handleSwipeRight];
            break;
            
        case 2:  //left
            [self handleSwipeLeft];
            break;
            
        case 4:  //up
            [self handleSwipeUp];
            break;
            
        case 8:  //down
            [self handleSwipeDown];
            break;
            
        default:
            break;
    }
    [self handleAnimation];
    
    
   
}

- (void)turnOver {
    
//    self.score += self.turnScore;
    [self scoreAdd:self.turnScore];
    self.turnScore = 0;
    
    [self.combineArray removeAllObjects];
    [self.moveArray removeAllObjects];
    
    if (self.win) {
        [self showOverLay];
    } else {
        [self nextTurn];
    }
    
}

- (void)scoreAdd:(NSInteger)i {
    self.score += i;
    NSString *string = [NSString stringWithFormat:@"+%zd",i];
    
    
    CGRect labelFrame = self.scoreLabel.frame;
    CGSize labelSize = labelFrame.size;
    CGSize textSize = [self.scoreLabel.text sizeWithAttributes:@{
                                                                 NSFontAttributeName : [UIFont systemFontOfSize:20],
                                                                 }];
    
    CGPoint point = CGPointMake(labelSize.width * 0.5 + textSize.width *0.5, labelSize.height * 0.5 - textSize.height * 0.5);

    
    CGSize ss = [string sizeWithAttributes:@{
                                               NSFontAttributeName : [UIFont systemFontOfSize:20],
                                               }];
    CGFloat x = point.x - ss.width;
    CGFloat y = point.y - ss.height;
    
    
    CGRect rect = CGRectMake(x, y+5, ss.width, ss.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    
    
    label.textAlignment = NSTextAlignmentRight;
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor colorWithRed:252.0/255 green:248.0/255 blue:241.0/255 alpha:1.0];
    [self.scoreLabel addSubview:label];
    [label setText:string];
    
    //实现分数累加的动画
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, -10);
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (void)nextTurn {

    [self addOneCell];
    
    if (self.cellArray.count == 16) {
        [self handleSwipeRight];
        [self handleSwipeLeft];
        [self handleSwipeUp];
        [self handleSwipeDown];
        if (self.moveArray.count == 0 && self.combineArray.count == 0) {
            //延时操作
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showOverLay];
            });
            
        }
        [self.combineArray removeAllObjects];
        [self.moveArray removeAllObjects];
    }
    self.lock = YES;
}

- (void)cellAnimationCompelete {
    if (self.combineArray.count >0) {
        [self turnOver];
        
    }
}

- (void)cellMoveAnimationComplete {
    if (self.combineArray.count == 0 && self.moveArray.count != 0) {
        
        [self turnOver];
    } else if (self.combineArray.count == 0 && self.moveArray.count == 0) {
        self.lock = YES;
    }
}

- (void)handleAnimation {
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        for (CellMove *cm in self.moveArray) {
            cm.mainCell.frame = [self getRectWithPosition:cm.cellAfterPos];
            cm.mainCell.positon = cm.cellAfterPos;
        }
        for (CellCombine *cc in self.combineArray) {
            cc.mainCell.frame = [self getRectWithPosition:cc.endPosition];
            cc.subCell.frame = [self getRectWithPosition:cc.endPosition];
            cc.mainCell.positon = cc.endPosition;
        }
        
    } completion:^(BOOL finished) {
        self.turnScore += self.moveArray.count;
        [self cellMoveAnimationComplete];
        for (CellCombine *cc in self.combineArray) {
            
            self.turnScore +=cc.score;
            
            if (cc.score == 2048) {
                self.win = YES;
            }
          
            [self.cellArray removeObject:cc.subCell];
            [cc.subCell removeFromSuperview];
            
            cc.subCell = nil;
            [cc.mainCell scoreLevelUp];
            
        }

    }];
    
}

- (void)addOneCell {
    int i = 0;
    
    BOOL flag = NO;
    do {
        i = arc4random_uniform(16);
        flag = NO;
        for (Cell *cell in self.cellArray) {
            if (cell.level == i) {
                flag = YES;
                break;
            }
        }
    } while (flag == YES);

    Cell *c1 = [Cell cellWithlevel:i];
    [self.boardView addSubview:c1];
    [self.cellArray addObject:c1];
    [c1 showWithScore:[self getCellScore]];
    c1.delegate = self;
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSInteger i = 0;  i < 16; i++) {
        for (Cell *cell in self.cellArray) {
            if (cell.level == i)
                [array addObject:cell];
        }
    }
    
    self.cellArray = array;
    
}

// 处理左滑手势
- (void)handleSwipeLeft {
    NSMutableArray *row0Array = [NSMutableArray array];
    NSMutableArray *row1Array = [NSMutableArray array];
    NSMutableArray *row2Array = [NSMutableArray array];
    NSMutableArray *row3Array = [NSMutableArray array];
    
    NSArray *array = @[row0Array, row1Array,row2Array,row3Array];

    for (Cell *cell in self.cellArray) {
        [array[cell.positon.row] addObject:cell];
    }
    
    for (NSInteger row = 0; row < 4; row++) {
        NSMutableArray *rowArray = array[row];

        switch (rowArray.count) { // 一行所有cell的数量
            case 1: {
                Cell *cell = rowArray[0];
                if (cell.positon.line > 0) {
                    CellMove *cm = [CellMove cellMoveWithMainCell:cell afterPos:[Position positonWithRow:row line:0]];
                    [self.moveArray addObject:cm];
                }
                break;
            }
                
            case 2: {
                Cell *c1 = rowArray[0];
                Cell *c2 = rowArray[1];
                if (c1.score == c2.score) { //两个cell分数相同，合并
                    CellCombine *cc= [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:0]];
                    
                    [self.combineArray addObject:cc];
                
                } else { //分数不同
                    if (c1.positon.line != 0) { // c1在第0列不需要移动
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:0]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.line != 1) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:row line:1]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
                
            case 3: {
                Cell *c1 = rowArray[0];
                Cell *c2 = rowArray[1];
                Cell *c3 = rowArray[2];
                
                if (c1.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:0]];
                    [self.combineArray addObject:cc];
                    CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:row line:1]];
                    [self.moveArray addObject:cm];
                } else if (c2.score == c3.score) {
                    if (c1.positon.line != 0) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:0]];
                        [self.moveArray addObject:cm];
                    }
                    CellCombine *cc =[CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:row line:1]];
                    [self.combineArray addObject:cc];
                    
                } else {
                    if (c3.positon.line == 3) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:row line:2]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.line == 2) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:row line:1]];
                        [self.moveArray addObject:cm];
                    }
                    if (c1.positon.line == 1) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:0]];
                        [self.moveArray addObject:cm];
                    }
                }
                
                break;
            }
            case 4: {
                Cell *c1 = rowArray[0];
                Cell *c2 = rowArray[1];
                Cell *c3 = rowArray[2];
                Cell *c4 = rowArray[3];
                
                if (c1.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:0]];
                    [self.combineArray addObject:cc];
                    if (c3.score == c4.score) {
                        CellCombine *cc2 = [CellCombine CellCombineWithMainCell:c3 subCell:c4 endPositon:[Position positonWithRow:row line:1]];
                        [self.combineArray addObject:cc2];
                    } else {
                        CellMove *cm1 = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:row line:1]];
                        CellMove *cm2 = [CellMove cellMoveWithMainCell:c4 afterPos:[Position positonWithRow:row line:2]];
                        [self.moveArray addObject:cm1];
                        [self.moveArray addObject:cm2];
                        
                    }
                } else if (c2.score == c3.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:row line:1]];
                    [self.combineArray addObject:cc];
                    
                    CellMove *cm = [CellMove cellMoveWithMainCell:c4 afterPos:[Position positonWithRow:row line:2]];
                    [self.moveArray addObject:cm];
                    
                } else if (c3.score == c4.score) {
                    CellCombine *cc2 = [CellCombine CellCombineWithMainCell:c3 subCell:c4 endPositon:[Position positonWithRow:row line:2]];
                    [self.combineArray addObject:cc2];
                }
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)handleSwipeRight {
    NSMutableArray *row0Array = [NSMutableArray array];
    NSMutableArray *row1Array = [NSMutableArray array];
    NSMutableArray *row2Array = [NSMutableArray array];
    NSMutableArray *row3Array = [NSMutableArray array];
    
    NSArray *array = @[row0Array, row1Array,row2Array,row3Array];
    
    for (Cell *cell in self.cellArray)
        [array[cell.positon.row] addObject:cell];
        
    
    for (NSInteger row = 0; row < 4; row++) {
        NSMutableArray *rowArray = array[row];
        
        switch (rowArray.count) { // 一行所有cell的数量
            case 1: {
                Cell *cell = rowArray[0];
                if (cell.positon.line != 3) {
                    CellMove *cm = [CellMove cellMoveWithMainCell:cell afterPos:[Position positonWithRow:row line:3]];
                    [self.moveArray addObject:cm];
                }
                break;
            }
                
            case 2: {
                Cell *c1 = rowArray[0];
                Cell *c2 = rowArray[1];
                
                if (c1.score == c2.score) { //两个cell分数相同，合并
                    CellCombine *cc= [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:3]];
                    
                    [self.combineArray addObject:cc];
                    
                } else { //分数不同
                    if (c2.positon.line != 3) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:row line:3]];
                        [self.moveArray addObject:cm];
                    }
                    if (c1.positon.line != 2) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:2]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
                
            case 3: {
                Cell *c1 = rowArray[0];
                Cell *c2 = rowArray[1];
                Cell *c3 = rowArray[2];
                
                if (c3.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c3 subCell:c2 endPositon:[Position positonWithRow:row line:3]];
                    [self.combineArray addObject:cc];
                    CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:2]];
                    [self.moveArray addObject:cm];
                } else if (c1.score == c2.score) {
                    if (!(c3.positon.line == 3)) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:row line:3]];
                        [self.moveArray addObject:cm];
                    }
                    CellCombine *cc =[CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:2]];
                    [self.combineArray addObject:cc];
                    
                } else {
                    if (c3.positon.line == 2) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:row line:3]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.line == 1) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:row line:2]];
                        [self.moveArray addObject:cm];
                    }
                    if (c1.positon.line == 0) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:1]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
            case 4: {
                Cell *c1 = rowArray[0];
                Cell *c2 = rowArray[1];
                Cell *c3 = rowArray[2];
                Cell *c4 = rowArray[3];
                
                if (c3.score == c4.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c3 subCell:c4 endPositon:[Position positonWithRow:row line:3]];
                    [self.combineArray addObject:cc];
                    if (c1.score == c2.score) {
                        CellCombine *cc2 = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:2]];
                        [self.combineArray addObject:cc2];
                    } else {
                        CellMove *cm1 = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:1]];
                        CellMove *cm2 = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:row line:2]];
                        [self.moveArray addObject:cm1];
                        [self.moveArray addObject:cm2];
                        
                    }
                } else if (c2.score == c3.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:row line:2]];
                    [self.combineArray addObject:cc];
                    
                    CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:row line:1]];
                    [self.moveArray addObject:cm];
                    
                } else if (c1.score == c2.score) {
                    CellCombine *cc2 = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:row line:1]];
                    [self.combineArray addObject:cc2];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)handleSwipeUp {
    NSMutableArray *line0Array = [NSMutableArray array];
    NSMutableArray *line1Array = [NSMutableArray array];
    NSMutableArray *line2Array = [NSMutableArray array];
    NSMutableArray *line3Array = [NSMutableArray array];
    
    NSArray *array = @[line0Array,line1Array,line2Array,line3Array];
    
    for (Cell *cell in self.cellArray) {
        [array[cell.positon.line] addObject:cell];
    }
    
    for (NSInteger line = 0; line < 4; line++) {
        NSMutableArray *lineArray = array[line];
       
        switch (lineArray.count) {
            case 1: {
                Cell *c1 = lineArray[0];
                if (c1.positon.row > 0) {
                    CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:0 line:line]];
                    [self.moveArray addObject:cm];
                }
                break;
            }
            case 2: {
                Cell *c1 = lineArray[0];
                Cell *c2 = lineArray[1];
                
                if (c1.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:0 line:line]];
                    [self.combineArray addObject:cc];
                } else {
                    if (c1.positon.row != 0) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:0 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.row != 1) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:1 line:line]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
                
            case 3: {
                Cell *c1 = lineArray[0];
                Cell *c2 = lineArray[1];
                Cell *c3 = lineArray[2];
                
                if (c1.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:0 line:line]];
                    [self.combineArray addObject:cc];
                    CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:1 line:line]];
                    [self.moveArray addObject:cm];
                } else if (c2.score == c3.score) {
                    if (c1.positon.row != 0) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:0 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:1 line:line]];
                    [self.combineArray addObject:cc];
                } else {
                    if (c1.positon.row == 1) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:0 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.row == 2) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:1 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    if (c3.positon.row == 3) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:2 line:line]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
                
            case 4: {
                Cell *c1 = lineArray[0];
                Cell *c2 = lineArray[1];
                Cell *c3 = lineArray[2];
                Cell *c4 = lineArray[3];
                
                if (c1.score == c2.score) {
                    CellCombine *cc  = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:0 line:line]];
                    [self.combineArray addObject:cc];
                    if (c3.score == c4.score) {
                        CellCombine *cc2 = [CellCombine CellCombineWithMainCell:c3 subCell:c4 endPositon:[Position positonWithRow:1 line:line]];
                        [self.combineArray addObject:cc2];
                    } else {
                        CellMove *cm1 = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:1 line:line]];
                        CellMove *cm2 = [CellMove cellMoveWithMainCell:c4 afterPos:[Position positonWithRow:2 line:line]];
                        [self.moveArray addObject:cm1];
                        [self.moveArray addObject:cm2];
                        
                    }
                } else if (c2.score == c3.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:1 line:line]];
                    [self.combineArray addObject:cc];
                    
                    CellMove *cm = [CellMove cellMoveWithMainCell:c4 afterPos:[Position positonWithRow:2 line:line]];
                    [self.moveArray addObject:cm];
                    
                } else if (c3.score == c4.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c3 subCell:c4 endPositon:[Position positonWithRow:2 line:line]];
                    [self.combineArray addObject:cc];
                }
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)handleSwipeDown {

    NSMutableArray *line0Array = [NSMutableArray array];
    NSMutableArray *line1Array = [NSMutableArray array];
    NSMutableArray *line2Array = [NSMutableArray array];
    NSMutableArray *line3Array = [NSMutableArray array];
    
    NSArray *array = @[line0Array,line1Array,line2Array,line3Array];
    
    for (Cell *cell in self.cellArray) {
        [array[cell.positon.line] addObject:cell];
    }
    
    for (NSInteger line = 0; line < 4; line++) {
        NSMutableArray *lineArray = array[line];
        
        switch (lineArray.count) {
            case 1: {
                Cell *c1 = lineArray[0];
                if (c1.positon.row != 3) {
                    CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:3 line:line]];
                    [self.moveArray addObject:cm];
                }
                break;
            }
            case 2: {
                Cell *c1 = lineArray[0];
                Cell *c2 = lineArray[1];
                
                if (c1.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:3 line:line]];
                    [self.combineArray addObject:cc];
                } else {
                    if (c1.positon.row != 2) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:2 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.row != 3) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:3 line:line]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
                
            case 3: {
                Cell *c1 = lineArray[0];
                Cell *c2 = lineArray[1];
                Cell *c3 = lineArray[2];
                
                if (c2.score == c3.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:3 line:line]];
                    [self.combineArray addObject:cc];
                    CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:2 line:line]];
                    [self.moveArray addObject:cm];
                } else if (c1.score == c2.score) {
                    if (c3.positon.row != 3) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:3 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:2 line:line]];
                    [self.combineArray addObject:cc];
                } else {
                    if (c1.positon.row == 0) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:1 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    if (c2.positon.row == 1) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:2 line:line]];
                        [self.moveArray addObject:cm];
                    }
                    if (c3.positon.row == 2) {
                        CellMove *cm = [CellMove cellMoveWithMainCell:c3 afterPos:[Position positonWithRow:3 line:line]];
                        [self.moveArray addObject:cm];
                    }
                }
                break;
            }
                
            case 4: {
                Cell *c1 = lineArray[0];
                Cell *c2 = lineArray[1];
                Cell *c3 = lineArray[2];
                Cell *c4 = lineArray[3];
                
                if (c3.score == c4.score) {
                    CellCombine *cc  = [CellCombine CellCombineWithMainCell:c3 subCell:c4 endPositon:[Position positonWithRow:3 line:line]];
                    [self.combineArray addObject:cc];
                    if (c1.score == c2.score) {
                        CellCombine *cc2 = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:2 line:line]];
                        [self.combineArray addObject:cc2];
                    } else {
                        CellMove *cm1 = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:1 line:line]];
                        CellMove *cm2 = [CellMove cellMoveWithMainCell:c2 afterPos:[Position positonWithRow:2 line:line]];
                        [self.moveArray addObject:cm1];
                        [self.moveArray addObject:cm2];
                        
                    }
                } else if (c2.score == c3.score) {
                    
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c2 subCell:c3 endPositon:[Position positonWithRow:2 line:line]];
                    [self.combineArray addObject:cc];
                    
                    CellMove *cm = [CellMove cellMoveWithMainCell:c1 afterPos:[Position positonWithRow:1 line:line]];
                    [self.moveArray addObject:cm];
                    
                } else if (c1.score == c2.score) {
                    CellCombine *cc = [CellCombine CellCombineWithMainCell:c1 subCell:c2 endPositon:[Position positonWithRow:1 line:line]];
                    [self.combineArray addObject:cc];
                }
                break;
            }
            default:
                break;
        }
    }
    
}

- (void)showOverLay {
    self.overlay.alpha = 0;
    [self.boardView addSubview:self.overlay];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.overlay.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (UIView *)overlay {
    if (!_overlay) {
        UIView *overlay = [[UIView alloc] initWithFrame:self.boardView.bounds];
        overlay.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 380, 100)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor= [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:64];
        label.text = (self.win ? @"You Win!" : @"Game Over");
        [overlay addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 0, 120, 40);
        btn.center = CGPointMake(190, 200);
        [btn setTitle:@"New Game" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:20]];
        btn.backgroundColor = [UIColor colorWithRed:115.0 /255 green:107.0 /255 blue:99.0 /255 alpha:0.9];
        btn.layer.cornerRadius = 5.0;
        btn.layer.masksToBounds = YES;
        [overlay addSubview:btn];
        
        [btn addTarget:self action:@selector(newGame) forControlEvents:UIControlEventTouchUpInside];
        
        _overlay = overlay;
    }
    return _overlay;
}

- (void) newGame {
    [self.overlay removeFromSuperview];
    NSLog(@"restart");
    for (Cell *cell  in self.cellArray) {
        [cell removeFromSuperview];
    }
    [self.cellArray removeAllObjects];
    self.score = 0;
    
    [self gameStart];
}


- (Cell *)getCellWithLevel:(NSInteger)level {
    for (Cell *c  in self.cellArray) {
        if (c.level == level) {
            return c;
        }
    }
    return nil;
}

- (CGRect)getRectWithPosition:(Position *)pos {
    static CGFloat gap = 6.0;
    static CGFloat width = 87.5;
    return  CGRectMake(pos.line * (gap + width) + gap, pos.row * (gap + width) + gap, width, width);
}



- (IBAction)restartBtnClick:(id)sender {
    [self newGame];
}


- (void)subviewClipToCircle {
    [self viewClipToCircle:self.scoreView radius:5.0];
    [self viewClipToCircle:self.bestView radius:5.0];
    [self viewClipToCircle:self.boardView radius:5.0];
    [self viewClipToCircle:self.restartBtn radius:5.0];
}

- (void)viewClipToCircle:(UIView *)view radius:(CGFloat)radius {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

-(UILabel *)transitionLabel {
    if (_transitionLabel == nil) {
        CGRect labelFrame = self.scoreLabel.frame;
        CGSize labelSize = labelFrame.size;
        CGSize textSize = [self.scoreLabel.text sizeWithAttributes:@{
                                                                NSFontAttributeName : [UIFont systemFontOfSize:20],
                                                                }];
        
        CGPoint point = CGPointMake(labelSize.width * 0.5 + textSize.width *0.5, labelSize.height * 0.5 - textSize.height * 0.5);
//        NSLog(@"%@",NSStringFromCGPoint(point));
        
        CGSize ss = [@"00000" sizeWithAttributes:@{
                                                 NSFontAttributeName : [UIFont systemFontOfSize:20],
                                                 }];
        CGFloat x = point.x - ss.width;
        CGFloat y = point.y - ss.height;
        
        
        CGRect rect = CGRectMake(x, y+5, ss.width, ss.height);
        
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.alpha = 0.0;
        
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor colorWithRed:252.0/255 green:248.0/255 blue:241.0/255 alpha:1.0];
        [self.scoreLabel addSubview:label];
        _transitionLabel = label;
    }
    return _transitionLabel;
}

- (NSMutableArray *)cellArray {
    if (!_cellArray) {
        _cellArray = [NSMutableArray array];
    }
    return _cellArray;
}

- (NSMutableArray *)combineArray {
    if (_combineArray == nil) {
        _combineArray = [NSMutableArray array];
    }
    return _combineArray;
}

- (NSMutableArray *)moveArray {
    if (_moveArray == nil) {
        _moveArray = [NSMutableArray array];
    }
    return _moveArray;
}

- (void)setScore:(NSInteger)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%zd",score];
    if (score > self.bestScore) {
        self.bestScore = score;
    }
    
}

- (void)setBestScore:(NSInteger)bestScore {
    _bestScore = bestScore;
    self.bestLabel.text = [NSString stringWithFormat:@"%zd",bestScore];
    [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:@"BestScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
