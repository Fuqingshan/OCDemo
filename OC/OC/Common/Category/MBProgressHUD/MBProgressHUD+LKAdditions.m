//  MBProgressHUD+LKAdditions.m
//  App
//
//  Created by yier on 2018/8/23.
//  Copyright © 2018 yier. All rights reserved.
//

#import "MBProgressHUD+LKAdditions.h"
#import <objc/runtime.h>

static const NSString * kStackSymbolsArr = @"kStackSymbolsArr";
static const NSInteger ktime = 20.0f;

@implementation MBProgressHUD (LKAdditions)

#pragma mark - monitor --- 启动记录MBProgressHUD超过20s不隐藏的堆栈代码
+(void)load{
#if DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class c = [self class];
        SEL origShowSEL = @selector(showAnimated:);
        SEL currentShowSEL = @selector(searchShowAnimated:);
        Method origShowMethod = class_getInstanceMethod(c, origShowSEL);
        Method currentShowMethod = class_getInstanceMethod(c, currentShowSEL);
        const char *origShowEncoding = method_getTypeEncoding(origShowMethod);
        
        //如果添加成功，说明MBProgressHUD替换了方法，这儿也要做相应的替换
        BOOL addShow = class_addMethod(c, origShowSEL, method_getImplementation(currentShowMethod), origShowEncoding);
        NSAssert(!addShow, @"MBProgressHUD --- MB替换了方法 showAnimated 的实现");
        method_exchangeImplementations(origShowMethod, currentShowMethod);

        SEL origHiddenSEL = @selector(hideAnimated:);
        SEL currentHiddenSEL = @selector(searchHideAnimated:);
        Method origHiddenMethod = class_getInstanceMethod(c, origHiddenSEL);
        Method currentHiddenMethod = class_getInstanceMethod(c, currentHiddenSEL);
        const char *origHiddenEncoding = method_getTypeEncoding(origHiddenMethod);
 
        //如果添加成功，说明MBProgressHUD替换了方法，这儿也要做相应的替换
        BOOL addHide = class_addMethod(c, origHiddenSEL, method_getImplementation(origHiddenMethod), origHiddenEncoding);
        NSAssert(!addHide, @"MBProgressHUD --- MB替换了方法 hideAnimated 实现");
        method_exchangeImplementations(origHiddenMethod, currentHiddenMethod);
    });
#endif
}

//防止0.5秒多次触发
static BOOL canPerform = YES;
- (void)searchShowAnimated:(BOOL)animation{
    self.stackSymbolsArr = [NSThread callStackSymbols];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (canPerform){
            canPerform = NO;
            [self performSelector:@selector(recordStackSymbols) withObject:nil afterDelay:ktime];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                canPerform = YES;
            });
        }
    });
    
    [self searchShowAnimated:animation];
}

- (void)searchHideAnimated:(BOOL)animation{
    self.stackSymbolsArr = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recordStackSymbols) object:nil];
    [self searchHideAnimated:animation];
}

- (void)recordStackSymbols{
    LKLogm(@"MBProgressHUD --- 记录超过%zd秒的菊花堆栈:%@",ktime,self.stackSymbolsArr);
}

- (NSArray *)stackSymbolsArr
{
    return objc_getAssociatedObject(self, &kStackSymbolsArr) ;
}

- (void)setStackSymbolsArr:(NSArray *)stackSymbolsArr
{
    objc_setAssociatedObject(self, &kStackSymbolsArr,stackSymbolsArr, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - HUD

+ (instancetype)lk_showHUDWithTitle:(NSString *)title
                            message:(NSString *)message
                     hideAfterDelay:(NSTimeInterval)delay {
    if (![message isValide]) {
        return nil;
    }
    
    UIView *window_ = [UIApplication sharedApplication].keyWindow;
    // 需要在主线程中显示和设置hud 否则会报错
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window_ animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor whiteColor];
    hud.bezelView.layer.cornerRadius = 14.0f;
    hud.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    hud.label.text = title;
    hud.label.font = PingFangSCMedium(18.0f);
    hud.detailsLabel.text = message;
    hud.detailsLabel.font = PingFangSCRegular(16.0f);
    hud.contentColor = [UIColor colorWithWhite:0 alpha:0.4f];
    hud.offset = CGPointMake(0, -100.0f);
    hud.removeFromSuperViewOnHide = YES;

//    [hud hide:YES afterDelay:delay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
    return hud;
}

+ (instancetype)lk_showRequestHUDWithMessage:(NSString *)message inView:(UIView *)view {
    if (!view) {
        return nil;
    }
    [[self class] hideHUDForView:view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.bezelView.color = [UIColor whiteColor];
    hud.bezelView.layer.cornerRadius = 14.0f;
    hud.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    hud.label.text = nil;
    hud.label.font = PingFangSCMedium(18.0f);
    hud.detailsLabel.text = message;
    hud.detailsLabel.font = PingFangSCRegular(16.0f);
    hud.contentColor = [UIColor colorWithWhite:0 alpha:0.4f];
    hud.offset = CGPointMake(0, -100.0f);
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    return hud;
}

+ (instancetype)lk_showInfoWithStatus:(NSString *)message hideAfterDelay:(NSTimeInterval)delay{
    return [self lk_showSuccessWithMessage:message icon:[UIImage imageNamed:@"MBProgressHUD_info.png"] view:nil hideAfterDelay:delay];
}

+ (instancetype)lk_showSuccessWithStatus:(NSString *)message hideAfterDelay:(NSTimeInterval)delay{
    return [self lk_showSuccessWithMessage:message icon:[UIImage imageNamed:@"MBProgressHUD_success.png"] view:nil hideAfterDelay:delay];
}

+ (instancetype)lk_showErrorWithStatus:(NSString *)message hideAfterDelay:(NSTimeInterval)delay{
    return [self lk_showSuccessWithMessage:message icon:[UIImage imageNamed:@"MBProgressHUD_error.png"] view:nil hideAfterDelay:delay];
}

+ (instancetype)lk_showSuccessWithMessage:(NSString *)message icon:(UIImage *)icon view:(UIView *)view hideAfterDelay:(NSTimeInterval)delay{
    if (![message isValide]) {
        return nil;
    }
    
    if (!view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:icon];
    hud.bezelView.color = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    hud.bezelView.layer.cornerRadius = 14.0f;
    hud.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    hud.label.text = nil;
    hud.label.font = PingFangSCMedium(18.0f);
    hud.detailsLabel.text = message;
    hud.detailsLabel.font = PingFangSCRegular(16.0f);
    hud.contentColor = [UIColor colorWithWhite:0 alpha:0.4f];
    hud.offset = CGPointMake(0, -100.0f);
    hud.removeFromSuperViewOnHide = YES;
    
    // 0.7秒之后再消失
    //    [hud hide:YES afterDelay:0.7];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
    return hud;
}

+ (void)lk_dismiss{
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        [[self class] hideHUDForView:view animated:NO];
    }
}
@end
