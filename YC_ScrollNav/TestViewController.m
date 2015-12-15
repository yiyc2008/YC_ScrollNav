//
//  TestViewController.m
//  YC_ScrollNav
//
//  Created by Berton on 15/12/15.
//  Copyright © 2015年 Berton. All rights reserved.
/*
 用法：
 只要继承自YCScrollNav就可以了
 */


#import "TestViewController.h"

#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"

@interface TestViewController ()


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpChildControllers];
}

// 添加子控制器
- (void)setUpChildControllers{
    
    OneViewController *oneVC = [[OneViewController alloc]init];
    oneVC.title = @"One";
    [self addChildViewController:oneVC];
    
    TwoViewController *twoVC = [[TwoViewController alloc]init];
    twoVC.title = @"Two";
    [self addChildViewController:twoVC];
    
    ThreeViewController *threeVC = [[ThreeViewController alloc]init];
    threeVC.title = @"Three";
    [self addChildViewController:threeVC];
    
    FourViewController *fourVC = [[FourViewController alloc]init];
    fourVC.title = @"Four";
    [self addChildViewController:fourVC];
    
    FiveViewController *fiveVC = [[FiveViewController alloc]init];
    fiveVC.title = @"Five";
    [self addChildViewController:fiveVC];
    
    SixViewController *sixVC = [[SixViewController alloc]init];
    sixVC.title = @"Six";
    [self addChildViewController:sixVC];
}


@end
