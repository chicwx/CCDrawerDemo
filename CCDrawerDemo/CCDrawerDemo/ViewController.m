//
//  ViewController.m
//  CCDrawerDemo
//
//  Created by wangxiao on 17/3/8.
//  Copyright © 2017年 chic. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Positioning.h"
#import "TimesSquare.h"

static void * const kCCDrawerListTableViewKVOContext = (void*)&kCCDrawerListTableViewKVOContext;
static void * const kCCDrawerListScrollerViewKVOContext = (void*)&kCCDrawerListScrollerViewKVOContext;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CGFloat ccDrawerListSelectDateViewHeight;
@property (nonatomic, assign) CGFloat ccDrawerListTableViewOffSetWhileTop;
@property (nonatomic, assign) CGFloat ccDrawerListTableViewOffSetWhileMiddle;
@property (nonatomic, assign) CGFloat ccDrawerListTableViewOffSetWhileBottom;

@property (nonatomic, strong) TSQCalendarView *calendarView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollerView;
@property (nonatomic, assign) CGFloat scrollViewOffsetY;
@property (nonatomic, assign) BOOL isObserving;//是否监听
@property (nonatomic, strong) NSArray *list;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareNativeData];
    
    [self prepareScrollerView];
    
    [self prepareTableView];
    
    [self prepareDrawerView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)prepareNativeData {
    self.ccDrawerListSelectDateViewHeight = 50.f;
    self.ccDrawerListTableViewOffSetWhileMiddle = self.ccDrawerListSelectDateViewHeight;
    self.ccDrawerListTableViewOffSetWhileBottom = (NSInteger)(self.view.height * 0.52);
    self.isObserving = YES;

    self.list = @[@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
}

#pragma mark - UI
- (void)prepareScrollerView {
    self.scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.scrollerView.contentOffset = CGPointMake(0, -self.ccDrawerListSelectDateViewHeight);
    self.scrollerView.backgroundColor = [UIColor clearColor];
    self.scrollerView.userInteractionEnabled = YES;
    self.scrollerView.delegate = self;
    
    [self.view addSubview:self.scrollerView];
    
    [self.scrollerView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(contentOffset))
                           options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                           context:kCCDrawerListScrollerViewKVOContext];
}

- (void)prepareTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollerView addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    [self.tableView addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(contentOffset))
                        options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                        context:kCCDrawerListTableViewKVOContext];
}

- (void)prepareDrawerView {
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSDate *firstDate = [[NSCalendar currentCalendar] dateFromComponents:todayDateComponents];
    
    NSDateComponents *oneYear = [NSDateComponents new];
    oneYear.year = 1;
    NSDate *lastDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneYear toDate:firstDate options:0];
    
    self.calendarView = [[TSQCalendarView alloc] initWithFrame:CGRectMake(0, 20.f, self.view.width, self.ccDrawerListTableViewOffSetWhileBottom + 20.f)];
    self.calendarView.calendar.locale = [NSLocale currentLocale];
    self.calendarView.rowCellClass = [TSQCalendarRowCell class];
    self.calendarView.headerCellClass = [TSQCalendarMonthHeaderCell class];
    
    self.calendarView.firstDate = firstDate;
    self.calendarView.lastDate = lastDate;
    
    self.calendarView.alpha = 0;
    self.calendarView.backgroundColor = [UIColor whiteColor];
    
    [self.view insertSubview:self.calendarView belowSubview:self.tableView];
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (!self.isObserving) {
        return;
    }
    
    self.isObserving = NO;
    
    //scrollerView向下滚动的最大值
    if (self.scrollerView.contentOffset.y < -self.ccDrawerListTableViewOffSetWhileBottom) {
        [self scrollView:self.scrollerView setContentOffset:CGPointMake(0, -self.ccDrawerListTableViewOffSetWhileBottom)];
    }
    if (self.scrollerView.contentOffset.y > 0) {
        [self scrollView:self.scrollerView setContentOffset:CGPointMake(0, 0)];
    }
    
    self.isObserving = YES;
    
    if (context == kCCDrawerListTableViewKVOContext) {
        
        CGPoint new = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint old = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        CGFloat diff = old.y - new.y;
        
        CGFloat scrollerViewOffSetY = -self.scrollerView.contentOffset.y;
        
        //下拉
        if (diff >= 0) {
            if (scrollerViewOffSetY < self.ccDrawerListTableViewOffSetWhileBottom && self.tableView.contentOffset.y <= 0) {
                [self scrollView:self.tableView setContentOffset:old];
                [self scrollView:self.scrollerView setContentOffset:CGPointMake(self.scrollerView.contentOffset.x, self.scrollerView.contentOffset.y - diff)];
            }
        }
        
        //上拉
        if (diff < 0) {
            //tableview的内容不滚动
            if (scrollerViewOffSetY > 0 && scrollerViewOffSetY < self.ccDrawerListTableViewOffSetWhileBottom) {
                [self scrollView:self.tableView setContentOffset:old];
                [self scrollView:self.scrollerView setContentOffset:CGPointMake(self.scrollerView.contentOffset.x, self.scrollerView.contentOffset.y - diff)];
            }
            
            //滚动tableview自己的内容
            if (scrollerViewOffSetY <= 0 || (scrollerViewOffSetY == self.ccDrawerListTableViewOffSetWhileBottom && self.tableView.contentOffset.y < 0)) {
                
            }
            //tableview的内容不滚动
            if (scrollerViewOffSetY >= self.ccDrawerListTableViewOffSetWhileBottom && self.tableView.contentOffset.y >= 0) {
                [self scrollView:self.tableView setContentOffset:CGPointMake(0, 0)];
                [self scrollView:self.scrollerView setContentOffset:CGPointMake(self.scrollerView.contentOffset.x, self.scrollerView.contentOffset.y - diff)];
            }
        }
    }
    [self startMoveAnimation];
}

- (void)scrollView:(UIScrollView*)scrollView setContentOffset:(CGPoint)offset {
    self.isObserving = NO;
    scrollView.contentOffset = offset;
    self.isObserving = YES;
}

- (void)startMoveAnimation {
    CGFloat alpha = (-self.scrollerView.contentOffset.y - self.ccDrawerListTableViewOffSetWhileMiddle) / ((self.ccDrawerListTableViewOffSetWhileBottom - self.ccDrawerListTableViewOffSetWhileMiddle) / 3);
    
    if (alpha <= 0) {
        self.calendarView.alpha = 0;
    } else {
        self.calendarView.alpha = 1;
    }
    
    [self updateCalendarViewHeight];
    
}

- (void)updateCalendarViewHeight {
    CGFloat contentOffSetY = - self.scrollerView.contentOffset.y;
    
    if (contentOffSetY <= 0) {
        contentOffSetY = 0;
    }
    self.calendarView.height = contentOffSetY - 20.f;
    
    if (self.calendarView.height <= 0) {
        self.calendarView.height = 0;
    }
    self.calendarView.y = 20.f;

}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollerView.contentOffset.y < 0) {
        return;
    }
    static CGFloat scrollTheta = 10.0f;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY <= 0 || offsetY > scrollView.contentSize.height - scrollView.height) {
        return;
    }
    
    if (offsetY - self.scrollViewOffsetY > scrollTheta) { // 向上滚动
        self.scrollViewOffsetY = offsetY;
    }
    
    if (offsetY + scrollTheta < self.scrollViewOffsetY) { // 向下滚动
        self.scrollViewOffsetY = offsetY;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [self scrollerTableView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.tableView) {
        [self scrollerTableView];
    }
}

//上拉、下拉
- (void)scrollerTableView {
    CGFloat scrollerContentOffSetY = 0;
    
    if (-self.scrollerView.contentOffset.y <= (self.ccDrawerListTableViewOffSetWhileMiddle + self.ccDrawerListTableViewOffSetWhileTop)/2) {
        scrollerContentOffSetY = 0;
    } else if (-self.scrollerView.contentOffset.y >= (self.ccDrawerListTableViewOffSetWhileMiddle + (self.ccDrawerListTableViewOffSetWhileBottom - self.ccDrawerListTableViewOffSetWhileMiddle)/3)) {
        scrollerContentOffSetY = -self.ccDrawerListTableViewOffSetWhileBottom;
    } else {
        scrollerContentOffSetY = -self.ccDrawerListTableViewOffSetWhileMiddle;
    }
    
    [UIView animateWithDuration:0.25f delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.scrollerView.contentOffset = CGPointMake(0, scrollerContentOffSetY);
                         
                         [self updateCalendarViewHeight];
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"This is %@ line",@(indexPath.row)];
    cell.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:235.f/255.f alpha:1.f];
    return cell;
    
}

@end
