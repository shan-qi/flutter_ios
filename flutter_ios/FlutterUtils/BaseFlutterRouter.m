//
//  BaseFlutterRouter.m
//  flutter_ios
//
//  Created by 小琦 on 2020/8/3.
//  Copyright © 2020 单琦. All rights reserved.
//

#import "BaseFlutterRouter.h"
#import <UIKit/UIKit.h>
#import "BaseFlutterViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "BaseViewController.h"
@interface BaseFlutterRouter() <FlutterStreamHandler>
@property(nonatomic,copy) FlutterEventSink eventSink;
@property(nonatomic,assign)BOOL animated;
@property(nonatomic,strong) NSObject<FlutterBinaryMessenger>* binaryMessenger;
@end

@implementation BaseFlutterRouter

+ (instancetype)sharedRouter{
    static BaseFlutterRouter *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[BaseFlutterRouter alloc]init];
        //在这里初始化FlutterViewController
        [FlutterBoostPlugin.sharedInstance startFlutterWithPlatform:_instance onStart:^(FlutterEngine * _Nonnull engine) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BaseFlutterRouter.sharedRouter.flutterViewController = engine.viewController;
                BaseFlutterRouter.sharedRouter.binaryMessenger = engine.binaryMessenger;
                [BaseFlutterRouter.sharedRouter setupNativeCallFlutter];
                [BaseFlutterRouter.sharedRouter setupFlutterCallNative];
            });
        }];
    });
    return _instance;
}

#pragma mark - FlutterCallNative
-(void)setupFlutterCallNative{
        
    // 用于Flutter 调用 Native
    // 这个channelname必须与Native里接收的一致
    FlutterMethodChannel *flutterCallNativeChannel = [FlutterMethodChannel methodChannelWithName:@"gkd.flutter.io/flutterCallNative" binaryMessenger:BaseFlutterRouter.sharedRouter.binaryMessenger];

    __weak typeof(self) weakSelf = self;
    [flutterCallNativeChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        NSLog(@"method :%@",call.method);
        NSLog(@"arguments: %@",call.arguments);
        if ([@"getBatteryLevel" isEqualToString:call.method]) {
            result(@"Battery info iOS 1234567");
        }else if([@"updateUserInfo" isEqualToString:call.method]){
            NSDictionary *params = call.arguments;
            NSInteger userId = [params[@"id"] integerValue];
            NSString *name = params[@"name"];
            result(@{@"id":@1000,
                     @"name":@"story",
                     @"fromId":@(userId),
                     @"fromName":name
                   });
        }else if([@"nativeCallFlutter" isEqualToString:call.method]){

        }else if([@"hideNav" isEqualToString:call.method]){
            weakSelf.navigationController.childViewControllers.lastObject.fd_prefersNavigationBarHidden = YES;
            BOOL animated = [call.arguments boolValue];
            [weakSelf.navigationController setNavigationBarHidden:YES animated:animated];
            result(@(NO));
        }else if([@"showNav" isEqualToString:call.method]){
            weakSelf.navigationController.childViewControllers.lastObject.fd_prefersNavigationBarHidden = NO;
            BOOL animated = [call.arguments boolValue];
            [weakSelf.navigationController setNavigationBarHidden:NO animated:animated];
            result(@(YES));
        }else{
            result(FlutterMethodNotImplemented);
        }
    }];
}

#pragma mark - NativeCallFlutter
-(void)setupNativeCallFlutter{
    //用于Native调用Flutter
    FlutterEventChannel *nativeCallFlutterChannel = [FlutterEventChannel eventChannelWithName:@"gkd.flutter.io/nativeCallFlutter" binaryMessenger:BaseFlutterRouter.sharedRouter.binaryMessenger];
    [nativeCallFlutterChannel setStreamHandler:self];
}


- (void)callFluterWithName:(NSString *)name params:(id)params{
    if(self.eventSink){
        self.eventSink(@{@"name":name?:@"",@"params":params?:[NSNull null]});
    }else{
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf callFluterWithName:name params:params];
        });
    }
}

#pragma mark - Flutter---调用---native
- (void)openNative:(nonnull NSString *)url urlParams:(nonnull NSDictionary *)urlParams exts:(nonnull NSDictionary *)exts completion:(nonnull void (^)(BOOL))completion{
    self.animated = NO;
    if (exts[@"animated"] != nil) {
        self.animated = exts[@"animated"];
    }    
    //与Flutter端约定跳转原生的url为三段结构 -- native/flutter_push/present_className
    NSArray<NSString *> *urlArr = [url componentsSeparatedByString:@"_"];
    if (urlArr.count == 3) {
        //通过类名找到相应页面
        Class a = NSClassFromString(urlArr[2]);
        id targetVC = [a new];
        //传进来的类名不存在
        if (![targetVC isKindOfClass:[UIViewController class]]) {
            NSLog(@"============类名不存在============");
            return;
        }
        
        BaseViewController *baseVC = targetVC;
        baseVC.params = urlParams;
        if ([@"push" isEqualToString:urlArr[1]]) {
            [self.navigationController pushViewController:targetVC animated:_animated];
            completion(YES);
        }else if([@"present" isEqualToString:urlArr[1]]){
            //将得到的类全屏展示
            baseVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:baseVC animated:_animated completion:^{}];
            completion(YES);
        }
    }
}
     
#pragma mark - push
- (void)open:(nonnull NSString *)url urlParams:(nonnull NSDictionary *)urlParams exts:(nonnull NSDictionary *)exts completion:(nonnull void (^)(BOOL))completion {
    if ([url hasPrefix:@"native"]) {
        [self openNative:url urlParams:urlParams exts:exts completion:completion];
    }else{
        self.animated = NO;
        if(exts[@"animated"] != nil){
            self.animated = exts[@"animated"];
        }
        BaseFlutterViewController *vc = BaseFlutterViewController.new;
        [vc setName:url params:urlParams];
        [self.navigationController pushViewController:vc animated:self.animated];
        completion(YES);
    }
}
                 
#pragma mark - present
- (void)present:(NSString *)url urlParams:(NSDictionary *)urlParams exts:(NSDictionary *)exts completion:(void (^)(BOOL))completion{
    self.animated = NO;
    if(exts[@"animated"] != nil){
        self.animated = exts[@"animated"];
    }
    BaseFlutterViewController *vc = BaseFlutterViewController.new;
    [vc setName:url params:urlParams];
    [self.navigationController presentViewController:vc animated:self.animated completion:^{}];
    completion(YES);
}

#pragma mark - close
- (void)close:(NSString *)uid result:(NSDictionary *)result exts:(NSDictionary *)exts completion:(void (^)(BOOL))completion{
    self.animated = false;
    if(exts[@"animated"] != nil){
        self.animated = exts[@"animated"];
    }
    FLBFlutterViewContainer *vc = (id)self.navigationController.presentedViewController;
    if([vc isKindOfClass:FLBFlutterViewContainer.class] && [vc.uniqueIDString isEqual: uid]){
        [vc dismissViewControllerAnimated:self.animated completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:self.animated];
    }
}


#pragma mark -- FlutterStreamHandler代理
//不再需要向Flutter传递消息
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if (events) {
        self.eventSink = events;
        self.eventSink(@"从原生传递过来的消息");
    }
    return nil;
}
@end
