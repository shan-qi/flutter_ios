//
//  ViewController.m
//  flutter_ios
//
//  Created by 小琦 on 2020/7/31.
//  Copyright © 2020 单琦. All rights reserved.
//

#import "ViewController.h"
#import <Flutter/Flutter.h>
#import "AppDelegate.h"
#import "BaseFlutterRouter.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButton];
}

-(void)setupButton{
    [self setButton:@"push到VC" action:@selector(pushButtonAction) height:210];
    [self setButton:@"present到VC" action:@selector(presentButtonAction) height:270];
}


-(void)setButton:(NSString *)title action:(SEL )action height:(CGFloat)height{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
              action:action
    forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    button.frame = CGRectMake((375 - 160) / 2, height, 160.0, 40);
    [self.view addSubview:button];
}



-(void)pushButtonAction{
    [BaseFlutterRouter.sharedRouter open:@"first" urlParams:@{} exts:@{@"animated":@(YES),@"title":@"我是push进来的页面"} completion:^(BOOL f){}];
}
-(void)presentButtonAction{
    [BaseFlutterRouter.sharedRouter present:@"second" urlParams:@{} exts:@{@"animated":@(YES),@"title":@"我是present进来的页面"} completion:^(BOOL f){}];
}

@end
