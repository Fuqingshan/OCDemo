//
//  TagsCollectionViewFlowLayout.m
//  searchBar
//
//  Created by yier on 16/7/8.
//  Copyright © 2016年 yier. All rights reserved.
//

#import "TagsCollectionViewFlowLayout.h"

@implementation TagsCollectionViewFlowLayout

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attributes = [self deepCopyWithArray:[super layoutAttributesForElementsInRect:rect]];
    for (int i = 1 ; i < attributes.count ; i += 1){
        UICollectionViewLayoutAttributes * curAttr = attributes[i];//当前cell的位置信息
        UICollectionViewLayoutAttributes * preAttr = attributes[i - 1]; //下一个cell 位置信息
        //下面这块代码是对于一行只有一个cell进行位置调整
        UICollectionViewLayoutAttributes * nextAttr = nil ;//上一个cell 位置信息
        if( i+1 < attributes.count){
            nextAttr = attributes[i+1];
        }
        
        if(nextAttr != nil){
            CGFloat preY = CGRectGetMaxY(preAttr.frame);
            CGFloat curY = CGRectGetMaxY(curAttr.frame);
            CGFloat nextY = CGRectGetMaxY(nextAttr.frame);
            //根据cell的Y轴位置来判断cell是否是单独一行
            if(curY > preY && curY < nextY){
                //这个判断方式也会对区头进行判断 如果是区头则X轴还是从0开始
                if(curAttr.representedElementKind == UICollectionElementKindSectionHeader){
                    CGRect frame = curAttr.frame;
                    frame.origin.x = 0;
                    curAttr.frame = frame;
                }
                else{
                    //单独一行的cell的X轴从5开始
                    CGRect frame = curAttr.frame;
                    frame.origin.x = 5;
                    curAttr.frame = frame;
                }
            }
            else if(i == 1)
            {
                CGRect frame = preAttr.frame;
                frame.origin.x = self.maximumInteritemSpacing;
                preAttr.frame = frame;
            }
        }
        //下面是对一行多个cell的间距进行调整
        CGFloat origin = CGRectGetMaxX(preAttr.frame);
        CGFloat targetX = origin + self.maximumInteritemSpacing;
        if(CGRectGetMinX(curAttr.frame) > targetX){
            //如果下一个cell换行了则不进行调整
            if(targetX + CGRectGetWidth(curAttr.frame) < [self collectionViewContentSize].width){
                CGRect frame = curAttr.frame;
                if (self.scrollDirection != UICollectionViewScrollDirectionHorizontal) {
                    frame.origin.x = targetX;
                }
                curAttr.frame = frame;
            }
        }
    }
    return attributes;
}

- (NSMutableArray *)deepCopyWithArray:(NSArray *)array
{
    NSMutableArray *copys = [NSMutableArray arrayWithCapacity:array.count];
    
    for (UICollectionViewLayoutAttributes *attris in array) {
        [copys addObject:[attris copy]];
    }
    return copys;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    return attributes;
}

@end
