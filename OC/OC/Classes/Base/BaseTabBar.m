//
//  BaseTabBar.m
//  OC
//
//  Created by yier on 2019/2/13.
//  Copyright © 2019 yier. All rights reserved.
//

#import "BaseTabBar.h"

@implementation BaseTabBar

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
