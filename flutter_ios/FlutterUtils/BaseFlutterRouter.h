//
//  BaseFlutterRouter.h
//  flutter_ios
//
//  Created by 小琦 on 2020/8/3.
//  Copyright © 2020 单琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FlutterBoost.h>
NS_ASSUME_NONNULL_BEGIN

@interface BaseFlutterRouter : NSObject<FLBPlatform>
@property(nonatomic,weak)FlutterViewController *flutterViewController;
@property(nonatomic,strong) UINavigationController *navigationController;
+(instancetype)sharedRouter;

/**
 原生调用flutter
 @param name 定义号的名字
 @param params 参数
 */
- (void)callFluterWithName:(NSString *)name params:(id)params;
@end

NS_ASSUME_NONNULL_END
