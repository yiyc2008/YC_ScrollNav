//
//  YC_ScrollNav.m
//  YC_ScrollNav
//
//  Created by Berton on 15/12/2.
//  Copyright © 2015年 Berton. All rights reserved.
//

#import "YC_ScrollNav.h"

@interface YC_ScrollNav ()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *titleScrollView;
@property (nonatomic, weak) UIScrollView *contentScrollView;

@property (nonatomic, weak) UIButton *selTitleButton;

// 保存所有的按钮
@property (nonatomic ,strong) NSMutableArray *titleButtons;

@end

@implementation YC_ScrollNav

static CGFloat const navBarH = 64;
static CGFloat const titleH = 44;
static CGFloat const maxTitleScale = 1.3;

#define YCScreenW [UIScreen mainScreen].bounds.size.width
#define YCScreenH [UIScreen mainScreen].bounds.size.height

- (NSMutableArray *)titleButtons
{
    if (_titleButtons == nil) {
        _titleButtons = [NSMutableArray array];
    }
    return _titleButtons;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.添加顶部标题滚动视图
    [self setUpTitleScrollView];
    
    // 2.添加底部内容滚动视图
    [self setUpContentScrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 只需要设置一次
    if (self.automaticallyAdjustsScrollViewInsets) {
        
        // 4.设置所有标题
        [self setUpAllTitle];
        
        // 不需要让系统自动添加顶部额外滚动区域
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        // 内容滚动范围
        _contentScrollView.contentSize = CGSizeMake(self.childViewControllers.count * YCScreenW, 0);
        
        // 开启分页
        _contentScrollView.pagingEnabled = YES;
        
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        
        // 监听滚动完成的事情
        _contentScrollView.delegate = self;
    }
}

#pragma mark - UIScrollViewDelegate
// 只要滚动UIScrollView就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    // 获取滚动偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger leftIndex = offsetX / YCScreenW;
    NSInteger rightIndex = leftIndex + 1;
    
    // 1.获取左右两边缩放按钮
    
    // 1.1 获取左边标题按钮
    UIButton *leftButton = self.titleButtons[leftIndex];
    
    // 1.2 获取右边标题按钮
    UIButton *rightButton = nil;
    // 3 0 1 2
    if (rightIndex < self.titleButtons.count) {
        rightButton = self.titleButtons[rightIndex];
    }
    
    // 2.让按钮缩放,计算缩放比例
    CGFloat scaleR = offsetX / YCScreenW - leftIndex;
    
    CGFloat scaleL = 1 - scaleR;
    
    // 最大缩放为2 0 ~ 1 * 0.3 + 1  1 ~ 1.3
    
    // 2.1 让左边按钮缩放
    CGFloat transScale = maxTitleScale - 1;
    leftButton.transform = CGAffineTransformMakeScale(scaleL * transScale + 1, scaleL * transScale + 1);
    
    // 2.2 让右边按钮缩放
    rightButton.transform = CGAffineTransformMakeScale(scaleR * transScale + 1, scaleR * transScale + 1);
    
    // 3.让按钮颜色渐变
    //     RGB
    // 黑色:0 0 0
    // 白色:1 1 1
    // 红色:1 0 0
    // 黑色 -> 红色 R:0 -> 1
    // 红色 -> 黑色 R:1 -> 0
    UIColor *rightColor = [UIColor colorWithRed:scaleR green:0 blue:0 alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    // 设置按钮颜色
    [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
    [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
    
    
    //    NSLog(@"%f %f",scaleL,scaleR);
    
    
}
// 滚动完成的时候就会调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    // 获取按钮,1.遍历标题滚动视图所有子控制器
    
    // 0.获取角标
    NSInteger i = scrollView.contentOffset.x / YCScreenW;
    
    // 1.选中按钮
    [self selectTitleButton:self.titleButtons[i]];
    
    // 2.添加对应子控制器的view
    // 2.1 获取子控制器
    [self setUpOneChildViewController:i];
    // 让当前控制器的下一个和上一个控制器也加载出来
    if (i >= self.titleButtons.count - 1 ) return;
    [self setUpOneChildViewController:i+1];
    if (i == 0) return;
    [self setUpOneChildViewController:i-1];
    
}

// 5.处理标题点击
// 点击按钮的时候就会调用
- (void)btnClick:(UIButton *)btn
{
    // 5.1 选中按钮
    [self selectTitleButton:btn];
    
    // 5.2 把对应控制器的view添加到内容滚动区域上去,添加对应位置
    NSInteger i = btn.tag;
    CGFloat x = i * YCScreenW;
    [self setUpOneChildViewController:i];
    // 让当前控制器的下一个和上一个控制也加载出来
    if (i >= self.titleButtons.count - 1 ) return;
    [self setUpOneChildViewController:i+1];
    if (i == 0) return;
    [self setUpOneChildViewController:i-1];
    
    // 5.3 设置内容视图偏移量
    _contentScrollView.contentOffset = CGPointMake(x, 0);
    
}

// 添加一个子控制器
- (void)setUpOneChildViewController:(NSInteger)i
{
    
    CGFloat x = i * YCScreenW;
    
    // 获取对应控制器
    UIViewController *vc = self.childViewControllers[i];
    // 已经加过一次 就不需要加了
    if (vc.view.superview) return;
    
    vc.view.frame = CGRectMake(x, 0, YCScreenW, YCScreenH - _contentScrollView.frame.origin.y);
    [_contentScrollView addSubview:vc.view];
    
}

// 选中按钮,点击和滚动完成都会调用
- (void)selectTitleButton:(UIButton *)btn
{
    // 恢复上一个按钮文字颜色
    [_selTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _selTitleButton.transform = CGAffineTransformIdentity;
    
    // 把当前按钮标题颜色变成红色
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.transform = CGAffineTransformMakeScale(maxTitleScale, maxTitleScale);
    
    // 记录下当前选中的按钮
    _selTitleButton = btn;
    
    // 让选中标题居中显示,设置标题滚动x轴偏移量
    [self setUpTitleCenter:btn];
    
}

- (void)setUpTitleCenter:(UIButton *)btn
{
    // 计算偏移量 = 选中按钮中心点x - screenw * 0.5
    CGFloat offsetX = btn.center.x - YCScreenW * 0.5;
    
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 计算最大滚动区域
    CGFloat maxOffsetX = _titleScrollView.contentSize.width - YCScreenW;
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    // 移动
    [_titleScrollView setContentOffset: CGPointMake(offsetX, 0) animated:YES];
    
    
}

// 4.设置所有标题
- (void)setUpAllTitle
{
    // 有多少标题是由子控制器决定
    NSInteger count = self.childViewControllers.count;
    
    CGFloat x = 0;
    CGFloat w = 100;
    CGFloat h = titleH;
    
    // 1.遍历所有的子控制器,创建对应标题
    for (int i = 0; i < count; i++) {
        
        // 获取对应控制器
        UIViewController *vc = self.childViewControllers[i];
        
        // 2.创建标题按钮
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        titleButton.tag = i;
        
        x = i * w;
        
        // 设置标题位置
        titleButton.frame = CGRectMake(x, 0, w, h);
        
        // 设置标题内容
        [titleButton setTitle:vc.title forState:UIControlStateNormal];
        
        // 设置标题颜色
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // 监听标题按钮点击
        [titleButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
        
        // 选中第0个标题按钮
        if (i == 0) {
            [self btnClick:titleButton];
        }
        
        // 保证按钮
        [self.titleButtons addObject:titleButton];
        
        [_titleScrollView addSubview:titleButton];
    }
    
    // 设置标题滚动视图范围
    _titleScrollView.contentSize = CGSizeMake(count * w, 0);
    _titleScrollView.showsHorizontalScrollIndicator = NO;
}



// 2.添加底部内容滚动视图
- (void)setUpContentScrollView
{
    CGFloat y = CGRectGetMaxY(_titleScrollView.frame);
    CGFloat h = YCScreenH - y;
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, YCScreenW, h)];
    _contentScrollView = contentScrollView;
    contentScrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:contentScrollView];
    
}


// 1.添加顶部标题滚动视图
- (void)setUpTitleScrollView
{
    
    CGFloat y = self.navigationController?navBarH : 0;
    
    UIScrollView *titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, YCScreenW, titleH)];
    titleScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleScrollView];
    _titleScrollView = titleScrollView;
    
}


@end
