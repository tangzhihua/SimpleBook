//
//  DreamBook
//
//  Created by 唐志华 on 13-9-26.
//
//

#import "BookStoreViewController_ipad.h"

//
#import "MKStoreManager.h"
#import "MKNetworkKit.h"
#import "Reachability.h"
#import "GlobalDataCacheForMemorySingleton.h"
#import "BookCategoriesNetRespondBean.h"
#import "GetBookDownloadUrlNetRequestBean.h"
#import "GetBookDownloadUrlNetRespondBean.h"

#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalBookList.h"

#import "BookListInBookstoresNetRequestBean.h"
#import "BookListInBookstoresNetRespondBean.h"

#import "LogonNetRespondBean.h"

#import "BookStoreTableCell_ipad.h"

#import "DAPagesContainer.h"
#import "BookCategoryViewController.h"
#import "BookCategory.h"

@interface BookStoreViewController_ipad () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewHeader;
@property (weak, nonatomic) IBOutlet UIButton *refurbishButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;


@property (weak, nonatomic) IBOutlet UIView *firstLayerView;
@property (weak, nonatomic) IBOutlet UIView *secondLayerView;
@property (weak, nonatomic) IBOutlet UIView *thirdLayerView;


@property (strong, nonatomic) DAPagesContainer *pagesContainer;

// 最后的搜索条件
@property (nonatomic, copy) NSString *latestSearchCriteria;

// 标识当前界面是 "公共账户" 还是企业账户, 根据不同的账号, UI会有所变化
@property (nonatomic, assign) BOOL isPublicAccount;
@end


@implementation BookStoreViewController_ipad

#pragma mark -
#pragma mark 私有方法
-(void)clearSearchCriteria {
  self.searchTextField.text = @"";
  self.latestSearchCriteria = @"";
}

-(void)openBookWithBookSaveDirPath:(NSString *)bookSaveDirPath {
  
}

#pragma mark -
#pragma mark Controller 生命周期
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    
    // 先同步下 "搜索输入框控件" 和 "最后的搜索条件", 都设为 @""
    [self clearSearchCriteria];
    
    // 判断当前界面是否是 "公共账号"
    self.isPublicAccount = [[GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon isEqualToString:PUBLIC_USERNAME];
  }
  return self;
}

-(void)dealloc {
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.pagesContainer = [[DAPagesContainer alloc] init];
  [self.pagesContainer willMoveToParentViewController:self];
  self.pagesContainer.view.frame = self.view.bounds;
  self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.firstLayerView addSubview:self.pagesContainer.view];
  [self.pagesContainer didMoveToParentViewController:self];
  
  NSMutableArray *bookCategoryViewControllerArray = [NSMutableArray array];
  for (BookCategory *bookCategory in [GlobalDataCacheForMemorySingleton sharedInstance].bookCategoriesNetRespondBean.categories) {
    BookCategoryViewController *bookCategoryViewController = [[BookCategoryViewController alloc]initWithNibName:@"BookCategoryViewController" bundle:nil];
    bookCategoryViewController.title = bookCategory.name;
    //[bookCategoryViewControllerArray addObject:bookCategoryViewController];
    
    UIViewController *beaverViewController = [[UIViewController alloc] init];
    UIImageView *beaverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beaver.jpg"]];
    beaverImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [beaverViewController.view addSubview:beaverImageView];
    beaverViewController.title = @"BEAVER";
    [bookCategoryViewControllerArray addObject:beaverViewController];
  }
  
  self.pagesContainer.viewControllers = bookCategoryViewControllerArray;
  
  self.pagesContainer.tabPageChangeHandleBlock = ^(NSUInteger selectedIndex) {
    NSLog(@"------ %d", selectedIndex);
  };
}


- (void)viewDidUnload NS_DEPRECATED_IOS(3_0,6_0) {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBar.hidden = NO;
  
  
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

// New Autorotation support.
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0) {
  NSLog(@"shouldAutorotate");
  
  //画面回転を許可する
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0) {
  return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration; {
  NSLog(@"willRotateToInterfaceOrientation ifOrientation=%d", toInterfaceOrientation);
  
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [self.pagesContainer updateLayoutForNewOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
  // ios6以降 viewDidUnloadがCALLされない。
  if([self isViewLoaded] && self.view.window == nil) {
    self.view = nil;
  }
}

#pragma mark -
#pragma mark UITextFieldDelegate 代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  [self searchButtonOnClickListener:nil];
  return YES;
}

// テキストフィールドをクリア
-(BOOL)textFieldShouldClear:(UITextField*)textField {
  [self clearSearchCriteria];
  
  return YES;
}

#pragma mark -
#pragma mark Button IBAction
// "返回 按钮"
-(IBAction) backButtonOnClickListener:(UIButton *)sender{
  // 自身のビューを削除してhomeに戻る
  // 子でdismissした場合、親にforwardされる。
  [self dismissViewControllerAnimated:YES completion:nil];
}

// "刷新 按钮"
-(IBAction) refreshButtonOnClickListener:(UIButton *)sender{
  
  // ネットワークエラー
  NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
  if(NotReachable == networkStatus){
    
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                         message:NSLocalizedString(@"Network is not available", @"Network is not available")
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [alertView show];
    return;
  }
  
  
  
}

// "搜索 按钮"
-(IBAction) searchButtonOnClickListener:(UIButton *)sender{
  if ([NSString isEmpty:self.searchTextField.text] && [NSString isEmpty:self.latestSearchCriteria]) {
    // 搜索条件没有变化
    return;
  }
  if ([self.searchTextField.text isEqualToString:self.latestSearchCriteria]) {
    // 搜索条件没有变化
    return;
  }
  
  // 更新最新的搜索条件
  self.latestSearchCriteria = self.searchTextField.text;
  
}


@end
