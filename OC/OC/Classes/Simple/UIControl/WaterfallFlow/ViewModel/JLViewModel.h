//
//  JLViewModel.h
//  JLWaterfallFlow
//
//  Created by Jasy on 16/1/25.
//  Copyright © 2016年 Jasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLViewModel : NSObject
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *nameArray;
- (void)getData;
@end
