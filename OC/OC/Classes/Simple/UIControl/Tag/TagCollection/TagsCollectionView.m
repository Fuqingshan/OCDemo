//
//  TagsCollectionView.m
//  searchBar
//
//  Created by yier on 16/7/7.
//  Copyright © 2016年 yier. All rights reserved.
//

#import "TagsCollectionView.h"
#import "TagsViewCell.h"
#import "TagsCollectionViewFlowLayout.h"
#import <objc/runtime.h>

static void * TagCollectionViewHightContext = &TagCollectionViewHightContext;
static NSString * KScrollVertical = @"KScrollVertical";
@interface TagsCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSMutableArray * tagsBtnWidthArr;
@property (strong, nonatomic) NSMutableArray <NSString *> * tagsArr;
@property (assign, nonatomic) CGRect tagsViewFrame;

@property (assign, nonatomic) BOOL isChange;
@property (strong, nonatomic) NSMutableArray * cellAttributesArray;
@end

@implementation TagsCollectionView

- (BOOL)scrollVertical
{
    return [objc_getAssociatedObject(self, &KScrollVertical) boolValue];
}

- (void)setScrollVertical:(BOOL)scrollVertical
{
    objc_setAssociatedObject(self, &KScrollVertical,@(scrollVertical), OBJC_ASSOCIATION_ASSIGN);
}

- (instancetype __nonnull)setUpCollectionViewByScrollVerticalEnable:(BOOL)scrollVertical frame:(CGRect)frame{
    if (!self.tagsView) {
        self.scrollVertical = self.scrollVertical || scrollVertical;
        self.tagsViewFrame = frame;
        if (self.tagsViewFrame.size.width > 0 && self.tagsViewFrame.size.height > 0) {
            [self initCollectionView];
        }
    }
    return self;
}

- (void)updateCollectionViewFrame:(CGRect)frame
{
    self.tagsViewFrame = frame;
    if (self.tagsViewFrame.size.width == 0 || self.tagsViewFrame.size.width > [UIScreen mainScreen].bounds.size.width) {
        self.tagsViewFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
    }
    
    self.tagsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tagsViewFrame), CGRectGetHeight(self.tagsViewFrame));
}

- (void)updateLayoutByFrame:(CGRect)frame
{
    [self updateCollectionViewFrame:frame];
    
    TagsCollectionViewFlowLayout * flowLayout = (TagsCollectionViewFlowLayout *)self.tagsView.collectionViewLayout;
    
    if (self.tagsViewFrame.size.height<=50 && (flowLayout.scrollDirection !=UICollectionViewScrollDirectionHorizontal)) {
        [self updateScrollDurationByDirection:UICollectionViewScrollDirectionHorizontal maximumInteritemSpacing:6 animated:NO completion:^(BOOL finished) {
        }];
    }
    else if(self.tagsViewFrame.size.height>50 && (flowLayout.scrollDirection !=UICollectionViewScrollDirectionVertical))
    {
        [self updateScrollDurationByDirection:UICollectionViewScrollDirectionVertical maximumInteritemSpacing:6 animated:NO completion:^(BOOL finished) {
        }];
    }
    
}

- (void)initCollectionView
{
    TagsCollectionViewFlowLayout * flowLayout = [[TagsCollectionViewFlowLayout  alloc]init];
    //设置滚动方向
    flowLayout.scrollDirection= UICollectionViewScrollDirectionHorizontal;
    if (self.scrollVertical) {
        flowLayout.scrollDirection= UICollectionViewScrollDirectionVertical;
    }
    flowLayout.maximumInteritemSpacing = 6;
    
    self.tagsView = [[UICollectionView alloc]initWithFrame:self.tagsViewFrame collectionViewLayout:flowLayout];
    self.tagsView.scrollsToTop = NO;
    self.tagsView.delegate = self;
    self.tagsView.dataSource = self;
    self.tagsView.showsVerticalScrollIndicator = NO;
    self.tagsView.showsHorizontalScrollIndicator = NO;
    self.tagsView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tagsView];
    
    //调整frame
    [self updateCollectionViewFrame:self.tagsViewFrame];
    
    [self.tagsView registerNib:[UINib nibWithNibName:[TagsViewCell cellReuseIdentifier] bundle:nil] forCellWithReuseIdentifier:[TagsViewCell cellReuseIdentifier]];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:TagCollectionViewHightContext];
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 方式1.匹配keypath
    if ([keyPath isEqualToString:@"frame"]) {
        [self updateLayoutByFrame:self.bounds];
    }
    
    // 方式2.上下文
    if (context == TagCollectionViewHightContext) {
        //        NSLog(@"%@",self.bounds);
    }
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tagsArr.count;
}


//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(12,6, 12, 6);//分别为上、左、下、右
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    return 6;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([self.tagsBtnWidthArr[indexPath.row] floatValue], [TagsViewCell cellHeight]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TagsViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TagsViewCell cellReuseIdentifier] forIndexPath:indexPath];
    NSString * tagName = self.tagsArr[indexPath.row];
    cell.tagName.text = tagName;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectBlock) {
        self.selectBlock(indexPath.row,self.tagsArr[indexPath.row]);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    //获取当前cell所对应的indexpath
    TagsViewCell *cell = (TagsViewCell *)longPress.view;
    NSIndexPath *cellIndexpath = [self.tagsView indexPathForCell:cell];
    
    //将此cell 移动到视图的前面
    [self.tagsView bringSubviewToFront:cell];
    
    _isChange = NO;
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            //使用数组将collectionView每个cell的 UICollectionViewLayoutAttributes 存储起来。
            [self.cellAttributesArray removeAllObjects];
            for (int i = 0; i < self.tagsArr.count; i++) {
                [self.cellAttributesArray addObject:[self.tagsView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
            }
            
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            //在移动过程中，使cell的中心与移动的位置相同。
            cell.center = [longPress locationInView:self.tagsView];
            
            for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
                //判断移动cell的indexpath，是否和目的位置相同，如果相同isChange为YES,然后将数据源交换
                if (CGRectContainsPoint(attributes.frame, cell.center) && cellIndexpath != attributes.indexPath) {
                    _isChange = YES;
                    NSString * tagName = self.tagsArr[cellIndexpath.row];
                    [self.tagsArr removeObjectAtIndex:cellIndexpath.row];
                    [self.tagsArr insertObject:tagName atIndex:attributes.indexPath.row];
                    [self.tagsView moveItemAtIndexPath:cellIndexpath toIndexPath:attributes.indexPath];
                }
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded: {
            //如果没有改变，直接返回原始位置
            if (!_isChange) {
                cell.center = [self.tagsView layoutAttributesForItemAtIndexPath:cellIndexpath].center;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - caculaterWidth

- (void)caculaterTagsBtnWidthWithTagsArray:(NSMutableArray<NSString *> * __nonnull)tagsArr
{
    if (tagsArr.count == 0) {
        return;
    }
    self.tagsArr = tagsArr;
    [self.tagsBtnWidthArr removeAllObjects];
    UIFont *tagFont = [UIFont systemFontOfSize:13.0f];
    NSDictionary *tagAttribute = @{NSFontAttributeName: tagFont};
    
    for (NSString * tagName in self.tagsArr) {
        
        CGRect tagRect = [tagName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                                     attributes:tagAttribute
                                                        context:nil];
        //判断items的宽度是否大于collectionView的cell - section左右的宽度，大于会报错,因此，过长的内容会显示省略号
        CGFloat tagCellWidth = ceil(tagRect.size.width) + 16;
        tagCellWidth = (tagCellWidth + 12) > self.tagsView.bounds.size.width
        ?
        (self.tagsView.bounds.size.width - 12)
        :
        tagCellWidth;
        
        [self.tagsBtnWidthArr addObject:@(tagCellWidth)];
    }
    
    [self.tagsView reloadData];
}

#pragma mark - lazyLoad

- (NSMutableArray *)cellAttributesArray
{
    if(!_cellAttributesArray)
    {
        self.cellAttributesArray = [[NSMutableArray alloc]init];
    }
    
    return _cellAttributesArray;
}

- (NSMutableArray *)tagsBtnWidthArr
{
    if(!_tagsBtnWidthArr)
    {
        self.tagsBtnWidthArr = @[].mutableCopy;
    }
    
    return _tagsBtnWidthArr;
}

- (NSMutableArray<NSString *>*)tagsArr
{
    if(!_tagsArr)
    {
        self.tagsArr = @[].mutableCopy;
    }
    
    return _tagsArr;
}

#pragma mark - reset layout
- (void)updateScrollDurationByDirection:(UICollectionViewScrollDirection)scrollDirection maximumInteritemSpacing:(CGFloat)maximumInteritemSpacing
                               animated:(BOOL)animated
                             completion:(void (^ __nullable)(BOOL finished))completion{
    TagsCollectionViewFlowLayout * flowLayout = (TagsCollectionViewFlowLayout *)self.tagsView.collectionViewLayout;
    flowLayout.scrollDirection= scrollDirection;
    flowLayout.maximumInteritemSpacing = maximumInteritemSpacing;
    
    [self.tagsView performBatchUpdates:^{
        [self.tagsView.collectionViewLayout invalidateLayout];
        [self.tagsView setCollectionViewLayout:flowLayout animated:animated];
    } completion:^(BOOL finished) {
        completion?completion(finished):nil;
    }];
}


-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame"];
}

@end

@implementation TagsCollectionView(Extension)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

@end

