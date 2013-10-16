//
//  DreamBook
//
//  Created by 唐志华 on 13-10-8.
//
//

#import "BookShelfViewController_ipad.h"

#import "BookStoreViewController_ipad.h"
#import "MKNetworkKit.h"
#import "Reachability.h"
#import "GlobalDataCacheForMemorySingleton.h"
#import "GlobalDataCacheForNeedSaveToFileSystem.h"
// 登录接口
#import "LogonNetRequestBean.h"
#import "LogonNetRespondBean.h"
// 获取本地书籍分类列表
#import "LocalBookshelfCategoriesNetRequestBean.h"
#import "LocalBookshelfCategoriesNetRespondBean.h"
#import "LocalBookshelfCategory.h"

#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalBookList.h"

#import "BookShelfTableCell_ipad.h"

#define kBookShelfViewControllerProperty_editMode @"editMode"

//
@interface BookShelfViewController_ipad () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *bookTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewFooter;
@property (weak, nonatomic) IBOutlet UIButton *publicLibraryButton;
@property (weak, nonatomic) IBOutlet UIButton *privateLibraryButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *doneEditButton;
@property (weak, nonatomic) IBOutlet UIView     *headerView;



// 最后的搜索条件
@property (nonatomic, copy) NSString *latestSearchCriteria;

// 书籍列表 - cell 对应的 nib
@property (nonatomic, strong) UINib *bookListTableCellNib;
// 标识 当前书架是否处于 "编辑模式"
// 20131010 唐志华 : 发现对于 BOOL 类型的变量, 如果命名为 isEditMode(就是is开头的), 当使用KVO监听时, 会发生BAD_ACCESS_ADDRESS, 为了安全起见, BOOL类型以后不命名为is开头为好
// 这里具体原因我还未知....
@property (nonatomic, assign) BOOL editMode;

@property (nonatomic, strong) LocalBookshelfCategoriesNetRespondBean *localBookshelfCategoriesNetRespondBean;
@end


//
@implementation BookShelfViewController_ipad {
  // 登录"书院-公共图书馆" 网络请求
  NSInteger _netRequestIndexForLoginPublicLibrary;
  // 登录"企业-私有图书馆" 网络请求
  NSInteger _netRequestIndexForLoginPrivateLibrary;
  // 获取本地书籍分类列表 网络请求
  NSInteger _netRequestIndexForUserLocalBookshelfCategories;
}

-(UINib *)bookListTableCellNib {
  return [BookShelfTableCell_ipad nib];
}

#pragma mark -
#pragma mark 私有方法
-(void)closeEditButton {
  if (self.editMode) {
    [self editButtonOnClickListener:nil];
  }
}

-(void)clearSearchCriteria {
  self.searchTextField.text = @"";
  self.latestSearchCriteria = @"";
}

-(void)gotoBookStoreViewController {
  [self closeEditButton];
  
  BookStoreViewController_ipad *bookStoreView = [[BookStoreViewController_ipad alloc]initWithNibName:@"BookStoreViewController_ipad" bundle:nil];
  [bookStoreView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
  [self presentViewController:bookStoreView animated:YES completion:NULL];
}

-(void)openBookWithBookSaveDirPath:(NSString *)bookSaveDirPath {
  
}

#pragma mark -
#pragma mark Controller 生命周期
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
  if (self) {
    // Custom initialization
    
    //
    _netRequestIndexForLoginPublicLibrary = NETWORK_REQUEST_ID_OF_IDLE;
    _netRequestIndexForLoginPrivateLibrary = NETWORK_REQUEST_ID_OF_IDLE;
    _netRequestIndexForUserLocalBookshelfCategories = NETWORK_REQUEST_ID_OF_IDLE;
    //
    self.editMode = NO;
    
    // 先同步下 "搜索输入框控件" 和 "最后的搜索条件", 都设为 @""
    [self clearSearchCriteria];
    
    // 向通知中心注册通知
    [self registerBroadcastReceiver];
  }
  return self;
}

-(void)dealloc {
  // 注销通知
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// viewDidload
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 如果上次退出app时, 用户登录了某个 "企业账户", 那么就显示 "退出登录" 按钮
  if([GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean != nil){
    self.logoutButton.hidden = NO;
  } else {
    self.logoutButton.hidden = YES;
  }
    
    // 对iOS7以下版本来标题更换图片，重新布局
    if (!IS_IOS7) {
        CGRect frame = self.headerView.frame;
        frame.size.height -= 20.0f;
        self.headerView.frame = frame;
        
        frame = self.imgviewHeader.frame;
        frame.size.height -= 20.0f;
        self.imgviewHeader.frame = frame;
        
        frame = self.bookTableView.frame;
        frame.size.height += 20.0f;
        frame.origin.y -= 20.0f;
        self.bookTableView.frame = frame;
    }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // 设置Header/Footer图片
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    // 竖屏
    [self.imgviewHeader setImage:[UIImage imageNamed:@"d_wdsj.png"]];
    [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh.png"]];
      // 对iOS7以下版本来标题更换图片
      if (!IS_IOS7) {
          self.imgviewHeader.image = [UIImage imageNamed:@"d_wdsj_6"];
      }
  } else {
    // 横屏
    [self.imgviewHeader setImage:[UIImage imageNamed:@"d_wdsj_H.png"]];
    [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh_H.png"]];
      // 对iOS7以下版本来标题更换图片
      if (!IS_IOS7) {
          self.imgviewHeader.image = [UIImage imageNamed:@"d_wdsj_6_H"];
      }
  }
  
  // superクラスの呼び出し前にreloadDataやっておくと２回呼ばれないですむ
  [self.bookTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

// New Autorotation support.
- (BOOL)shouldAutorotate {
  //画面回転を許可する
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration; {
  NSLog(@"willRotateToInterfaceOrientation ifOrientation=%d", toInterfaceOrientation);
  
  [self.bookTableView reloadData];
  
  if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
      // 竖屏
      [self.imgviewHeader setImage:[UIImage imageNamed:@"d_wdsj.png"]];
      [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh.png"]];
      // 对iOS7以下版本来标题更换图片
      if (!IS_IOS7) {
          self.imgviewHeader.image = [UIImage imageNamed:@"d_wdsj_6"];
      }
  } else {
      // 横屏
      [self.imgviewHeader setImage:[UIImage imageNamed:@"d_wdsj_H.png"]];
      [self.imgviewFooter setImage:[UIImage imageNamed:@"ddh_H.png"]];
      // 对iOS7以下版本来标题更换图片
      if (!IS_IOS7) {
          self.imgviewHeader.image = [UIImage imageNamed:@"d_wdsj_6_H"];
      }
  }
  
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
  
  [self.bookTableView reloadData];
  return YES;
}

#pragma mark -
#pragma mark Button IBAction
// 搜索 按钮
- (IBAction)searchButtonOnClickListener:(UIButton *)sender {
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
  
  // 重刷界面
  [self.bookTableView reloadData];
}

// 退出登录 按钮
- (IBAction)logoutButtonOnClickListener:(UIButton *)sender {
  
  [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Confirm", @"Confirm") message:NSLocalizedString(@"LogoutConfirm", @"LogoutConfirm") cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:[NSArray arrayWithObject:NSLocalizedString(@"OK", @"OK")] alertViewStyle:UIAlertViewStyleDefault onDismiss:^(UIAlertView *alertView, int buttonIndex) {
    
    // 退出当前用户
    
    // 暂停跟当前用户绑定的所有书籍的下载进程
    NSString *account = [GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean.username;
    LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
    for (LocalBook *localBook in localBookFromBookshelf.localBookList) {
      if ([account isEqualToString:localBook.bindAccount] && localBook.bookStateEnum == kBookStateEnum_Downloading) {
        [localBook stopDownloadBook];
      }
    }
    
    // 登出当前账号.
    [GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean = nil;
    [GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon = nil;
    //[GlobalDataCacheForMemorySingleton sharedInstance].passwordForLastSuccessfulLogon = nil;
    
    // 隐藏 "退出登录" 按钮
    sender.hidden = YES;
  } onCancel:^{
    
  }];
}

// 公共图书馆(书院) 按钮
- (IBAction)publicLibraryButtonOnClickListener:(UIButton *)sender {
  
  // 如果点击了公共图书馆, 就中断对私有图书馆的请求.
  [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForLoginPrivateLibrary];
  self.privateLibraryButton.enabled = YES;
  
  // 开始登录 公共图书馆
  [self requestLoginWithUsername:PUBLIC_USERNAME password:PUBLIC_PASSWORD currentNetRequestIndexToOut:&_netRequestIndexForLoginPublicLibrary];
  
  if (_netRequestIndexForLoginPublicLibrary != NETWORK_REQUEST_ID_OF_IDLE) {
    // 暂时禁用 公共图书馆(书院) 按钮
    sender.enabled = NO;
  }
}

// 私有图书馆(企业) 按钮
- (IBAction)privateLibraryButtonOnClickListener:(UIButton *)sender {
    // 如果在编辑状态时，点击了登陆按钮，取消编辑状态
    [self closeEditButton];
  // 如果在搜索状态，点了登陆按钮时，取消搜索6
    [self.searchTextField resignFirstResponder];
  // 私有图书馆(企业) 按钮, 就中断对公有图书馆的请求.
  [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForLoginPublicLibrary];
  self.publicLibraryButton.enabled = YES;
  
  if ([GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean != nil
      && ![NSString isEmpty:[GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean.username]
      && ![NSString isEmpty:[GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean.password]) {
    // 直接登录 企业图书馆
    [self requestLoginWithUsername:[GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean.username
                          password:[GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean.password
       currentNetRequestIndexToOut:&_netRequestIndexForLoginPrivateLibrary];
    
    if (_netRequestIndexForLoginPrivateLibrary != NETWORK_REQUEST_ID_OF_IDLE) {
      // 暂时禁用 私有图书馆(企业) 按钮
      sender.enabled = NO;
    }
  } else {
    __weak BookShelfViewController_ipad *weakSelf = self;
    // 显示登录提示框
    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"LoginDialog_AccountAuth", @"LoginDialog_AccountAuth") message:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:[NSArray arrayWithObject:@"登录"] alertViewStyle:UIAlertViewStyleLoginAndPasswordInput onDismiss:^(UIAlertView *alertView, int buttonIndex) {
      
      UITextField *usernameITextField = [alertView textFieldAtIndex:0];
      UITextField *passwordITextField = [alertView textFieldAtIndex:1];
      NSString *username = usernameITextField.text;
      NSString *password = passwordITextField.text;
      NSString *errorMessage = @"";
      do {
        if ([NSString isEmpty:username]) {
          errorMessage = @"用户名不能为空!";
          break;
        }
        
        if ([NSString isEmpty:password]) {
          errorMessage = @"密码不能为空!";
          break;
        }
        
        // 开始登录 企业图书馆
        [weakSelf requestLoginWithUsername:username password:password currentNetRequestIndexToOut:&_netRequestIndexForLoginPrivateLibrary];
        
        if (_netRequestIndexForLoginPrivateLibrary != NETWORK_REQUEST_ID_OF_IDLE) {
          // 暂时禁用 私有图书馆(企业) 按钮
          sender.enabled = NO;
        }
        
        return;
      } while (NO);
      
      // 用户输入数据不完整时的错误提示.
      UIAlertView *loginFailAlertView  = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"LoginFail", @"LoginFail")
                                                                   message:errorMessage
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
      [loginFailAlertView show];
      
    } onCancel:^{
      
    }];
    
  }
}

// 编辑 按钮
- (IBAction)editButtonOnClickListener:(UIButton *)sender {
  self.editMode = !self.editMode;
  
  // 編集ボタン self.isDeleteMode/NO
  self.editButton.enabled = !self.editMode;
  self.editButton.hidden = self.editMode;
  
  // 完了ボタン self.isDeleteMode/YES
  self.doneEditButton.enabled = self.editMode;
  self.doneEditButton.hidden = !self.editMode;
}


#pragma mark -
#pragma mark - 网络相关方法群

-(void)requestLoginWithUsername:(NSString *)username password:(NSString*)password currentNetRequestIndexToOut:(out NSInteger *) pCurrentNetRequestIndexToOut{
  do {
    // 网络状态检测
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(NotReachable == networkStatus){
      
      UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                           message:NSLocalizedString(@"Network is not available", @"Network is not available")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK", nil];
      [alertView show];
      break;
    }
    
    // 入参检测
    if ([NSString isEmpty:username] || [NSString isEmpty:password]) {
      RNAssert(NO, @"用户名和密码不能为空.");
      break;
    }
    
    LogonNetRequestBean *netRequestBean = [[LogonNetRequestBean alloc] initWithUsername:username password:password];
    __weak BookShelfViewController_ipad *weakSelf = self;
    [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:netRequestBean currentNetRequestIndexToOut:pCurrentNetRequestIndexToOut successedBlock:^(id respondDomainBean) {
      
      LogonNetRespondBean *logonNetRespondBean = (LogonNetRespondBean *) respondDomainBean;
      
      // 用户登录成功, 保存 用户名和密码 等信息...
      [GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon = username;
      if (![username isEqualToString:PUBLIC_USERNAME]) {
        // "公共图书馆 账号, 不作为已登录的凭证"
        PRPLog(@"企业账号登录成功!");
        
        logonNetRespondBean.username = username;
        logonNetRespondBean.password = password;
        
        // 一定要在给 logonNetRespondBean 设置 username 和 password 之后再赋值给GlobalDataCacheForMemorySingleton中, 否则触发KVO序列化对象的时机就不对了.
        [GlobalDataCacheForMemorySingleton sharedInstance].logonNetRespondBean = logonNetRespondBean;
        weakSelf.logoutButton.hidden = NO;
      } else {
        PRPLog(@"公共图书馆账号登录成功!");
      }
      
      // 请求本地书籍分类
      if (weakSelf.localBookshelfCategoriesNetRespondBean == nil && _netRequestIndexForUserLocalBookshelfCategories == NETWORK_REQUEST_ID_OF_IDLE) {
        // 本地书籍分类列表, 只需要在登录成功之后请求一次即可.
        // 当本地书籍分类类表获取成功后, 会自动跳转到书城界面
        [weakSelf requestLocalBookshelfCategories];
      } else {
        
        // 直接跳转到书城界面
        [weakSelf gotoBookStoreViewController];
      }
      
      //
      weakSelf.publicLibraryButton.enabled = YES;
      weakSelf.privateLibraryButton.enabled = YES;
    } failedBlock:^(NetRequestErrorBean *error) {
      
      UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"LoginFail", @"LoginFail")
                                                          message:NSLocalizedString(@"LoginFailMessage", "LoginFailMessage")
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
      [alertView show];
      
      //
      weakSelf.publicLibraryButton.enabled = YES;
      weakSelf.privateLibraryButton.enabled = YES;
    }];
    
  } while (NO);
}

-(void)requestLocalBookshelfCategories {
  do {
    // 网络状态检测
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(NotReachable == networkStatus){
      
      UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                           message:NSLocalizedString(@"Network is not available", @"Network is not available")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK", nil];
      [alertView show];
      break;
    }
    
    // 获取书的分类
    LocalBookshelfCategoriesNetRequestBean *netRequestBean = [[LocalBookshelfCategoriesNetRequestBean alloc] init];
    __weak BookShelfViewController_ipad *weakSelf = self;
    [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:netRequestBean currentNetRequestIndexToOut:&_netRequestIndexForUserLocalBookshelfCategories successedBlock:^(id respondDomainBean) {
      
      PRPLog(@"获取书的分类 成功!");
      LocalBookshelfCategoriesNetRespondBean *netRespondBean = (LocalBookshelfCategoriesNetRespondBean *) respondDomainBean;
      PRPLog(@"%@", netRespondBean);
      
      // 局部缓存 "本地书籍分类"
      weakSelf.localBookshelfCategoriesNetRespondBean = netRespondBean;
      // 全局缓存 "本地书籍分类"
      [GlobalDataCacheForMemorySingleton sharedInstance].localBookshelfCategoriesNetRespondBean = netRespondBean;
      
      // 跳转到 "书城界面"
      [weakSelf gotoBookStoreViewController];
      
    } failedBlock:^(NetRequestErrorBean *error) {
      
    }];
    
  } while (NO);
  
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  return localBookList != nil ? [localBookList bookCategoryTotalOfInstalledByBookNameSearch:self.searchTextField.text] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [localBookList bookCategoryDictionaryOfInstalledByBookNameSearch:self.searchTextField.text];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[section];
  NSArray *bookInfoListOfSection = bookCategoryDictionaryByBookNameSearch[categoryIDOfSection];
  
  // 因为目前设计成 一排显示两本书籍, 所以这里要计算真实的行数
  NSInteger count = bookInfoListOfSection.count / 2;
  if (bookInfoListOfSection.count % 2 != 0) {
    count++;
  }
  return count;
}

// テーブルビューにcellを設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BookShelfTableCell_ipad *cell = [BookShelfTableCell_ipad cellForTableView:tableView fromNib:self.bookListTableCellNib];
  
  // 注册监听 "编辑按钮" 变化 KVO
  
  [self addObserver:cell
         forKeyPath:kBookShelfViewControllerProperty_editMode
            options:NSKeyValueObservingOptionNew
            context:(__bridge void *)cell];
  
  __weak BookShelfViewController_ipad *weakSelf = self;
  cell.bookShelfTableCellFunctionButtonClickHandleBlock
  = ^(BookShelfTableCell_ipad* tableCell, BookShelfTableCellActionEnum actionEnum, NSString *contentIDString) {
    LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
    LocalBook *book = [localBookList objectByContentID:contentIDString];
    
    switch (actionEnum) {
      case kBookShelfTableCellActionEnum_Read:{
        //
        // 如果要打开一本书, 就要先中断全部的网络请求操作.
        [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForLoginPrivateLibrary];
        [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForLoginPublicLibrary];
        [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForUserLocalBookshelfCategories];
        // 恢复按钮可用性
        weakSelf.publicLibraryButton.enabled = YES;
        weakSelf.privateLibraryButton.enabled = YES;
        
        // 打开一本书
        [weakSelf openBookWithBookSaveDirPath:book.bookSaveDirPath];
        
      }break;
        
      case kBookShelfTableCellActionEnum_Delete:{// 删除本地的书籍
        NSString *bookName = book.bookInfo.name;
        [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Confirm", @"Confirm")
                                    message:[NSString stringWithFormat:@"是否删除《%@》？", bookName]
                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                          otherButtonTitles:[NSArray arrayWithObject:NSLocalizedString(@"OK", @"OK")]
                             alertViewStyle:UIAlertViewStyleDefault
                                  onDismiss:^(UIAlertView *alertView, int buttonIndex) {
                                    [localBookList removeBook:book];
                                    [weakSelf.bookTableView reloadData];
                                    // 如果为最后一本书时，禁用编辑按钮
                                    if (localBookList.localBookList.count <= 0) {
                                      [weakSelf closeEditButton];
                                    }
                                  } onCancel:^{
                                    
                                  }];
        
      }break;
        
      default:
        break;
    }
  };
  
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [localBookList bookCategoryDictionaryOfInstalledByBookNameSearch:self.searchTextField.text];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[indexPath.section];
  // 当前分类下面 书籍列表
  NSArray *bookInfoListOfSection = bookCategoryDictionaryByBookNameSearch[categoryIDOfSection];
  
  // 因为目前设计成 一排显示两本书籍, 所以这里要进行一下计算.
  // indexOfOneRowContainsTwoBook 是数组索引, 所以从 0 开始
  NSInteger indexOfOneRowContainsTwoBook = indexPath.row * 2;
  LocalBook *firstBookDataBean = bookInfoListOfSection[indexOfOneRowContainsTwoBook];
  LocalBook *secondBookDataBean = nil;
  if (bookInfoListOfSection.count >= (indexOfOneRowContainsTwoBook + 1) * 2) {
    secondBookDataBean = bookInfoListOfSection[indexOfOneRowContainsTwoBook + 1];
  }
  
  // 给cell进行数据绑定
  [cell bindWithFirstDataBean:firstBookDataBean secondDataBean:secondBookDataBean];
  [cell hideDeleteButton:!self.editMode];
  
  return cell;
}



// テーブルビューの高さ指定
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  CGFloat height = 0;
  if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
    height = 244;
  } else {
    height = 230;
  }
  return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  LocalBookList *localBookList = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [localBookList bookCategoryDictionaryOfInstalledByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[section];
  
  // 通过 "分类ID" 获取 "分类Name"
  NSString *categoryNameString = [[GlobalDataCacheForMemorySingleton sharedInstance].localBookshelfCategoriesNetRespondBean categoryNameByCategoryID:[categoryIDOfSection integerValue]];
  
  UIImage *headerViewBackgroundImage = nil;
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    // 竖屏
    if ([categoryNameString isEqual:@"通用"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_ty_hb"];
    } else if ([categoryNameString isEqual:@"宣传"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xc_hb"];
    } else if ([categoryNameString isEqual:@"学习"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xx_hb"];
    }
    
  } else {
    // 横屏
    if ([categoryNameString isEqual:@"通用"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_ty_hb_H"];
    } else if ([categoryNameString isEqual:@"宣传"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xc_hb_H"];
    } else if ([categoryNameString isEqual:@"学习"]) {
      headerViewBackgroundImage = [UIImage imageNamed:@"fl_xx_hb_H"];
    }
  }
  
  //
  UIView *headerView = nil;
  if (CURRENT_IOS_VERSION > 6.0) {
    static NSString *headerViewIdentifier = @"headerViewIdentifier";
    headerView = [self.bookTableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentifier];
    if (headerView == nil) {
      headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerViewIdentifier];
    }
    ((UITableViewHeaderFooterView *)headerView).backgroundView = [[UIImageView alloc] initWithImage:headerViewBackgroundImage];
  } else {
    headerView = [[UIImageView alloc] initWithImage:headerViewBackgroundImage];
  }
  
  return headerView;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 31;
}

#pragma mark - NSNotification
//
-(void)registerBroadcastReceiver {
  // "下载完成并且安装成功一本书籍"
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onReceiveForBroadcast:)
                                               name:[NSNumber numberWithInteger:kUserNotificationEnum_DownloadAndInstallSucceed].stringValue
                                             object:nil];
}
-(void)onReceiveForBroadcast:(NSNotification *)notification {
  
  // "下载完成并且安装成功一本书籍"
  if ([notification.name isEqualToString:[NSNumber numberWithInteger:kUserNotificationEnum_DownloadAndInstallSucceed].stringValue]) {
    [self.bookTableView reloadData];
  }
}
@end
