//
//  BaseTabBar.m
//  OC
//
//  Created by yier on 2019/2/13.
//  Copyright © 2019 yier. All rights reserved.
//

#import "BaseTabBar.h"

@interface BaseTabBar()
@property(nonatomic, strong) UIButton *centerBtn;

@end

@implementation BaseTabBar

#pragma mark - 给中间增加一个大范围可点击的按钮
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{

    UIView *view = [super hitTest:point withEvent:event];
    
    //检测点击是否落在了centerBtn上
    CGPoint hitPoint = [self.centerBtn convertPoint:point fromView:self];
    if (![self.centerBtn pointInside:hitPoint withEvent:event]) {
        return view;
    }

    return self.centerBtn;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!self.centerBtn && self.items.count > 0) {
        UIView *findCenterBarButton;
        CGFloat tabbarBtnWidth = self.frame.size.width/self.items.count;
        CGFloat centerX = CGRectGetCenter(self.frame).x;
        CGRect theoryCenterBtnRect = CGRectMake(centerX - tabbarBtnWidth/2, 0, tabbarBtnWidth, self.frame.size.height);

        for (UIView *v in self.subviews) {
            if ([NSStringFromClass([v class]) isEqualToString: @"UITabBarButton"]) {
                if (CGRectContainsRect(theoryCenterBtnRect, v.frame)) {
                    findCenterBarButton = v;
                    break;
                }
            }
        }
        
        if (!findCenterBarButton) {
            return;;
        }
        
        //-50表示Tabbar向上增加50可点击范围
        //这儿也可以不给item设置image，而是给centerBtn设置，不过没必要，除非这张图片需要动态替换，比如是个股票的缩略实时图，那就可以通过新写一个button来做
        self.centerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(findCenterBarButton.frame) - 50, tabbarBtnWidth, 102)];
        [self.centerBtn addTarget:self action:@selector(centerTap) forControlEvents:UIControlEventTouchUpInside];
        [findCenterBarButton addSubview:self.centerBtn];
    }
}

- (void)centerTap{
    [OCRouter openURL:[NSURL URLWithString:@"sumup://advance"]];
}

- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated{
    [self getBaseItemsByTabBarItems:items];
    [super setItems:items animated:animated];
}

- (void)getBaseItemsByTabBarItems:(NSArray<UITabBarItem *> *)items{
    ThemeStyle style = ThemeStyleName;
    switch ([LanguageManager shareInstance].type) {
        case LanguageTypeCH:
            style = ThemeStyleName;
            break;
        case LanguageTypeEN:
            style = ThemeStyleWriter;
    }
    
    NSString *symbol;
    switch (style) {
        case ThemeStyleName:
            symbol = @"name";
            break;
        case ThemeStyleWriter:
            symbol = @"writer";
    }
    if (!symbol) {
        return;
    }
    NSArray *titles = @[
                        @{
                            @"title":nilToEmptyString(LocalizedString(@"简单"))
                            ,@"image":[NSString stringWithFormat:@"tabbar_simple_%@.png",symbol]
                            ,@"selectedImage":[NSString stringWithFormat:@"tabbar_simple_%@_select.png",symbol]
                            }
                        ,@{
                            @"title":nilToEmptyString(LocalizedString(@"进阶"))
                            ,@"image":[NSString stringWithFormat:@"tabbar_advance_%@.png",symbol]
                            ,@"selectedImage":[NSString stringWithFormat:@"tabbar_advance_%@_select.png",symbol]
                            }
                        ,@{
                            @"title":nilToEmptyString(LocalizedString(@"练习"))
                            ,@"image":[NSString stringWithFormat:@"tabbar_practice_%@.png",symbol]
                            ,@"selectedImage":[NSString stringWithFormat:@"tabbar_practice_%@_select.png",symbol]
                            }
                        ];
    for (NSInteger i = 0; i < items.count; i++) {
        UITabBarItem *item = objectInArrayAtIndex(items, i);
        NSDictionary *dic = dictionaryInArrayAtIndex(titles, i);
//        NSString *title = stringInDictionaryForKey(dic, @"title");
        UIImage *image = [[UIImage imageNamed:stringInDictionaryForKey(dic, @"image")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:stringInDictionaryForKey(dic, @"selectedImage")] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        item.title = title;
        item.image = image;
        item.selectedImage = selectedImage;
    }
    self.backgroundImage = [[UIImage imageNamed:[NSString stringWithFormat:@"tabbar_%@_background.png",symbol]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
