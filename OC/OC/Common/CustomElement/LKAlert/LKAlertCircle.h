//
//  LKAlertCircle.h
//  App
//
//  Created by yier on 2019/5/17.
//  Copyright © 2019 yooli. All rights reserved.
//
/*window显示规则
 1、window即使设置成makeKeyAndVisible，局部变量也只会显示一瞬间，只有被持有才会长时间显示(比如：controller持有、单例、互相持有)
 2、同windowLevel，后实例化显示在最上层可见，UIWindowLevelAlert=2000，UIWindowLevelStatusBar=1000,normal=0，越大越在上层
 3、keywindow并不一定是最上层的，因此添加的view到keywindow，不一定能显示出来，可能被上层window挡住
 4、不用的window记得resignKeyWindow，然后=nil销毁
 5、window可以设置rootViewController
 6、UIAlertView是window的方式，strongSelf，所以会有内存泄漏
 */

#import <Foundation/Foundation.h>

@class LKAlert;
@interface LKAlertCircle : NSObject
@property (nonatomic, strong) LKAlert *alert;

@end

