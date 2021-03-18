//
//  OCRouter+Simple.m
//  App
//
//  Created by yier on 2019/1/22.
//  Copyright © 2019 yier. All rights reserved.
//

#import "OCRouter+Simple.h"
#import "OCRouter+Common.h"

@implementation OCRouter (Simple)

#pragma mark - 处理Simple相关的router
+ (BOOL)openSimpleURL:(NSURL *)url{
    if (![[url host] isEqualToString:@"simple"]) {
        return NO;
    }
    if ([[url path] isEqualToString:@""]) {
        [self showSimpleViewController];
    }
    //QRCode
    else if([[url path] isEqualToString:@"/QRCode"]){
        [self showViewControllerByIdentifier:@"QRCodeVC" storyboardName:@"QRCode"];
    }else if([[url path] isEqualToString:@"/QRCode/QRCodeCreate"]){
        [self showViewControllerByIdentifier:@"QRCodeCreateVC" storyboardName:@"QRCode"];
    }
    //advantage
    else if([[url path] isEqualToString:@"/advantage"]){
        [self showViewControllerByIdentifier:@"AdvantageVC" storyboardName:@"Advantage"];
    }
    //foundation
    else if([[url path] isEqualToString:@"/foundation"]){
        [self showViewControllerByIdentifier:@"FoundationVC" storyboardName:@"Foundation"];
    }
    //preprocessor
    else if([[url path] isEqualToString:@"/preprocessor"]){
        [self showViewControllerByIdentifier:@"PreprocessorVC" storyboardName:@"PreCompiling"];
    }
    //introduction
    else if([[url path] isEqualToString:@"/introduction"]){
        [self showViewControllerByIdentifier:@"IntroductionVC" storyboardName:@"Introduction"];
    }else if([[url path] isEqualToString:@"/introduction/property"]){
        [self showViewControllerByIdentifier:@"PropertyVC" storyboardName:@"Introduction"];
    }else if([[url path] isEqualToString:@"/introduction/constructor"]){
        [self showViewControllerByIdentifier:@"ConstructorVC" storyboardName:@"Introduction"];
    }else if([[url path] isEqualToString:@"/introduction/protocol"]){
        [self showViewControllerByIdentifier:@"ProtocolVC" storyboardName:@"Introduction"];
    }else if([[url path] isEqualToString:@"/introduction/msgforward"]){
        [self showViewControllerByIdentifier:@"MsgForwardVC" storyboardName:@"Introduction"];
    }
    
    //memory
    else if([[url path] isEqualToString:@"/memory"]){
        [self showViewControllerByIdentifier:@"MemoryVC" storyboardName:@"Memory"];
    }else if([[url path] isEqualToString:@"/memory/savedata"]){
        [self showViewControllerByIdentifier:@"SaveDataVC" storyboardName:@"Memory"];
    }else if([[url path] isEqualToString:@"/memory/ocmemory"]){
        [self showViewControllerByIdentifier:@"OCMemoryVC" storyboardName:@"Memory"];
    }else if([[url path] isEqualToString:@"/memory/arc"]){
        [self showViewControllerByIdentifier:@"ARCVC" storyboardName:@"Memory"];
    }else if([[url path] isEqualToString:@"/memory/arc/foundationbridge"]){
        [self showViewControllerByIdentifier:@"FoundationBridgeVC" storyboardName:@"Memory"];
    }
    //multithread
    else if([[url path] isEqualToString:@"/multithread"]){
        [self showViewControllerByIdentifier:@"MultithreadVC" storyboardName:@"Multithread"];
    }else if([[url path] isEqualToString:@"/multithread/gcd"]){
        [self showViewControllerByIdentifier:@"GCDVC" storyboardName:@"Multithread"];
    }else if([[url path] isEqualToString:@"/multithread/thread"]){
        [self showViewControllerByIdentifier:@"NSThreadVC" storyboardName:@"Multithread"];
    }else if([[url path] isEqualToString:@"/multithread/queue"]){
        [self showViewControllerByIdentifier:@"QueueVC" storyboardName:@"Multithread"];
    }else if([[url path] isEqualToString:@"/multithread/pthread"]){
        [self showViewControllerByIdentifier:@"PThreadVC" storyboardName:@"Multithread"];
    }
    //debug
    else if([[url path] isEqualToString:@"/debug"]){
        [self showViewControllerByIdentifier:@"DebugVC" storyboardName:@"Debug"];
    }
    //security
    else if([[url path] isEqualToString:@"/security"]){
        [self showViewControllerByIdentifier:@"SecurityVC" storyboardName:@"Security"];
    }
    //uicontrol
    else if([[url path] isEqualToString:@"/uicontrol"]){
        [self showViewControllerByIdentifier:@"UIControlVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/automaticdimension"]){
        [self showViewControllerByIdentifier:@"AutomaticDimensionVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/chatemoji"]){
        [self showViewControllerByIdentifier:@"ChatEmojiVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/pagecontrol"]){
        [self showViewControllerByIdentifier:@"PageControlVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/searchbar"]){
        [self showViewControllerByIdentifier:@"SearchBarVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/tag"]){
        [self showViewControllerByIdentifier:@"TagVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/photo"]){
        [self showViewControllerByIdentifier:@"PhotoVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/waterfallflow"]){
        [self showViewControllerByIdentifier:@"WaterfallFlowVC" storyboardName:@"UIControl"];
    }else if([[url path] isEqualToString:@"/uicontrol/cardcollection"]){
        [self showViewControllerByIdentifier:@"CardCollectionVC" storyboardName:@"UIControl"];
    }
    //Animation
    else if([[url path] isEqualToString:@"/animation"]){
        [self showViewControllerByIdentifier:@"AnimationVC" storyboardName:@"Animation"];
    }else if([[url path] isEqualToString:@"/animation/drawcircle"]){
        [self showViewControllerByIdentifier:@"DrawCircleVC" storyboardName:@"Animation"];
    }else if([[url path] isEqualToString:@"/animation/dynamicanimator"]){
        [self showViewControllerByIdentifier:@"DynamicAnimatorVC" storyboardName:@"Animation"];
    }
    else{
        return NO;
    }
    
    return YES;
}

+ (void)showSimpleViewController{
    [OCRouter shareInstance].rootViewController.tabbarVC.itemType = TabBarItemTypeSimple;
}

+ (void)showViewControllerByIdentifier:(NSString *)identifier{
    [self showViewControllerByIdentifier:identifier storyboardName:@"Simple"];
}

@end
