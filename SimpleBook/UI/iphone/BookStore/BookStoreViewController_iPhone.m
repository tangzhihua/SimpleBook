//
//  BookStoreViewController_iPhone.m
//  MBEnterprise
//
//  Created by Yingjie Huo on 13-10-9.
//
//

#import "BookStoreViewController_iPhone.h"

//
#import "MKNetworkKit.h"

#import "GlobalDataCacheForMemorySingleton.h"
#import "LocalBookshelfCategoriesNetRespondBean.h"
#import "GetBookDownloadUrlNetRequestBean.h"
#import "GetBookDownloadUrlNetRespondBean.h"

#import "BookInfo.h"
#import "LocalBook.h"
#import "LocalBookList.h"

#import "BookListInBookstoresNetRequestBean.h"
#import "BookListInBookstoresNetRespondBean.h"

#import "LogonNetRespondBean.h"

#import "BookStoreTableCell_iPhone.h"

@interface BookStoreViewController_iPhone () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *bookTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewFooter;

@property (weak, nonatomic) IBOutlet UIButton *refurbishButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
// 书城图书列表(完成本地图书列表和从服务器新获取的图书列表进行了数据同步)
@property (nonatomic, strong) LocalBookList *bookList;

// 最后的搜索条件
@property (nonatomic, copy) NSString *latestSearchCriteria;

// 书籍列表 - cell 对应的 nib
@property (nonatomic, strong) UINib *bookListTableCellNib;

// 标识当前界面是 "公共账户" 还是企业账户, 根据不同的账号, UI会有所变化
@property (nonatomic, assign) BOOL isPublicAccount;
@end


@implementation BookStoreViewController_iPhone {
  // 获取书城中的图书列表 网络请求
  NSInteger _netRequestIndexForGetBookListInBookstores;
  // 获取要下载的书籍的URL 网络请求
  NSInteger _netRequestIndexForGetBookDownloadUrl;
  
  CGRect _footerViewOriginalFrame;
}

-(UINib *)bookListTableCellNib {
  if (_bookListTableCellNib == nil) {
    _bookListTableCellNib = [BookStoreTableCell_iPhone nib];
  }
  return _bookListTableCellNib;
}

-(LocalBookList *)bookList {
  if (_bookList == nil) {
    _bookList = [[LocalBookList alloc] init];
  }
  
  return _bookList;
}
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
    
    //
    _netRequestIndexForGetBookListInBookstores = NETWORK_REQUEST_ID_OF_IDLE;
    _netRequestIndexForGetBookDownloadUrl = NETWORK_REQUEST_ID_OF_IDLE;
    
    // 先同步下 "搜索输入框控件" 和 "最后的搜索条件", 都设为 @""
    [self clearSearchCriteria];
  }
  return self;
}

-(void)dealloc {
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 判断当前界面是否是 "公共账号"
  self.isPublicAccount = [[GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon isEqualToString:PUBLIC_USERNAME] ;
  // 对iOS7以下版本来标题更换图片，重新布局
  if (!IS_IOS7) {
    CGRect frame = self.headerView.frame;
    frame.size.height -= 20.0f;
    self.headerView.frame = frame;
    
    frame = self.bookTableView.frame;
    frame.size.height += 20.0f;
    frame.origin.y -= 20.0f;
    self.bookTableView.frame = frame;
    
    self.imgviewHeader.image = [UIImage imageNamed:(self.isPublicAccount ? @"d_jrsy_6iphone" : @"d_qysy_6iphone.png")] ;
  } else {
    
    self.imgviewHeader.image = [UIImage imageNamed:(self.isPublicAccount ? @"d_jrsy_iphone.png" : @"d_qysy_iphone.png")] ;
  }
  
  // 请求书城书籍列表
  [self requestBookListInBookstores];
  
  //添加键盘显示和隐藏监听
  [self addKeypadObserver];
  
  
}

- (void)viewWillAppear:(BOOL)animated {
  // 记录footerView的原始位置，不能放在viewDidLoad中，因为需要根据设备的分辩率来进行获取
  _footerViewOriginalFrame = self.footerView.frame;
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  // 注销 消息监听
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForGetBookDownloadUrl];
  [[DomainBeanNetworkEngineSingleton sharedInstance] cancelNetRequestByRequestIndex:_netRequestIndexForGetBookListInBookstores];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return interfaceOrientation == UIInterfaceOrientationPortrait;
}

// New Autorotation support.
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0) {
  NSLog(@"shouldAutorotate");
  
  //画面回転を許可する
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0) {
  return UIInterfaceOrientationMaskPortrait;
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
  [textField resignFirstResponder];
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
  
  
  
  [self requestBookListInBookstores];
  if (_netRequestIndexForGetBookListInBookstores != NETWORK_REQUEST_ID_OF_IDLE) {
    // 发起网络请求成功
    
    //
    [self clearSearchCriteria];
    
    // 为了防止用户快速点击 "刷新按钮", 暂时禁用, 当本次网络请求返回时, 在解禁.
    self.refurbishButton.enabled = NO;
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
  
  // 重刷界面
  [self.bookTableView reloadData];
}



#pragma mark -
#pragma mark - 网络相关方法群

// ダウンロードのリスト一覧を取得する
-(void)requestBookListInBookstores {
  
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
  
  BookListInBookstoresNetRequestBean *netRequestBean = [[BookListInBookstoresNetRequestBean alloc] init];
  
  __weak BookStoreViewController_iPhone *weakSelf = self;
  [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:netRequestBean currentNetRequestIndexToOut:&_netRequestIndexForGetBookListInBookstores successedBlock:^(id respondDomainBean) {
    
    PRPLog(@"获取 书城图书列表 成功!");
    
    // 缓存书城图书列表
    BookListInBookstoresNetRespondBean *bookListInBookstoresNetRespondBean = (BookListInBookstoresNetRespondBean *) respondDomainBean;
    LocalBookList *localBookFromBookshelf = [GlobalDataCacheForMemorySingleton sharedInstance].localBookList;
    
    for (BookInfo *bookInfo in bookListInBookstoresNetRespondBean.bookInfoList) {
      LocalBook *newBook = [localBookFromBookshelf objectByContentID:bookInfo.content_id];
      if (newBook == nil) {
        newBook = [[LocalBook alloc] initWithBookInfo:bookInfo];
      } else {
        // 更新当前书籍最新的bookInfo, 一定要及时更新, 因为服务器可能修改某本书的 bookInfo
        newBook.bookInfo = bookInfo;
      }
      
      [weakSelf.bookList addBook:newBook];
    }
    
    // 刷新界面
    [self.bookTableView reloadData];
    
    // 解禁 "刷新按钮".
    self.refurbishButton.enabled = YES;
    
  } failedBlock:^(NetRequestErrorBean *error) {
    
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error")
                                                         message:error.message
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [alertView show];
    
    // 解禁 "刷新按钮".
    self.refurbishButton.enabled = YES;
  }];
}

-(void)requestBookDownlaodUrlWithContentID:(NSString *)contentID bindAccount:(LogonNetRespondBean *)bindAccount {
  [self requestBookDownlaodUrlWithContentID:contentID receipt:nil bindAccount:bindAccount];
}

-(void)requestBookDownlaodUrlWithContentID:(NSString *)contentID receipt:(NSData *)receipt bindAccount:(LogonNetRespondBean *)bindAccount {
  GetBookDownloadUrlNetRequestBean *netRequestBean = [[GetBookDownloadUrlNetRequestBean alloc] initWithContentId:contentID bindAccount:bindAccount];
  if (receipt != nil) {
    netRequestBean.receipt = receipt;
  } else {
    
  }
  __weak BookStoreViewController_iPhone *weakSelf = self;
  [[DomainBeanNetworkEngineSingleton sharedInstance] requestDomainProtocolWithRequestDomainBean:netRequestBean currentNetRequestIndexToOut:&_netRequestIndexForGetBookDownloadUrl successedBlock:^(id respondDomainBean) {
    
    PRPLog(@"获取要下载的书籍URL 成功!");
    GetBookDownloadUrlNetRespondBean *logonNetRespondBean = (GetBookDownloadUrlNetRespondBean *) respondDomainBean;
    
    LocalBook *book = [weakSelf.bookList objectByContentID:contentID];
    [book startDownloadBookWithURLString:logonNetRespondBean.bookDownloadUrl];
    
  } failedBlock:^(NetRequestErrorBean *error) {
    
    // コンンテンツのリスト情報に変化があったのでその旨通知する必要がある
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"PleaseRefresh", @"PleaseRefresh")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
  }];
  
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.bookList != nil ? [self.bookList bookCategoryTotalByBookNameSearch:self.latestSearchCriteria] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self.bookList bookCategoryDictionaryByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[section];
  NSArray *bookInfoListOfSection = bookCategoryDictionaryByBookNameSearch[categoryIDOfSection];
  return bookInfoListOfSection.count;
}

// テーブルビューにセルを追加する
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BookStoreTableCell_iPhone *cell = [BookStoreTableCell_iPhone cellForTableView:tableView fromNib:self.bookListTableCellNib];
  if (![NSString isEmpty:cell.contentID]) {
    // 注销监听下载KVO
    LocalBook *book = [self.bookList objectByContentID:cell.contentID];
    [book removeObserver:cell forKeyPath:kLocalBookProperty_bookStateEnum context:(__bridge void *)cell];
    [book removeObserver:cell forKeyPath:kLocalBookProperty_downloadProgress context:(__bridge void *)cell];
  }
  
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self.bookList bookCategoryDictionaryByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[indexPath.section];
  NSArray *bookInfoListOfSection = bookCategoryDictionaryByBookNameSearch[categoryIDOfSection];
  
  LocalBook *book = bookInfoListOfSection[indexPath.row];
  // 注册KVO
  [book addObserver:cell
         forKeyPath:kLocalBookProperty_bookStateEnum
            options:NSKeyValueObservingOptionNew
            context:(__bridge void *)cell];
  [book addObserver:cell
         forKeyPath:kLocalBookProperty_downloadProgress
            options:NSKeyValueObservingOptionNew
            context:(__bridge void *)cell];
  
  __weak BookStoreViewController_iPhone *weakSelf = self;
  cell.bookStoreTableCellFunctionButtonClickHandleBlock
  = ^(BookStoreTableCell_iPhone* tableCell, NSString *contentIDString) {
    LocalBook *book = [weakSelf.bookList objectByContentID:contentIDString];
    switch (book.bookStateEnum) {
        
      case kBookStateEnum_Unpaid:{
        
      }break;
        
      case kBookStateEnum_Paid:{
        if (NETWORK_REQUEST_ID_OF_IDLE == _netRequestIndexForGetBookDownloadUrl) {
          
          // 给将要保存到本地的书籍, 绑定当前处于登录状态的账号(企业账号/公共账号 都需要绑定).
          LogonNetRespondBean *account = [[LogonNetRespondBean alloc] init];
          account.username = [GlobalDataCacheForMemorySingleton sharedInstance].usernameForLastSuccessfulLogon;
          account.password = [GlobalDataCacheForMemorySingleton sharedInstance].passwordForLastSuccessfulLogon;
          book.bindAccount = account;
          
          // 向本地书籍列表中, 插入一本书(localBookList 中已经做了放置重复插入的处理, 外部不用担心).
          [[GlobalDataCacheForMemorySingleton sharedInstance].localBookList addBook:book];
          
          [weakSelf requestBookDownlaodUrlWithContentID:book.bookInfo.content_id bindAccount:book.bindAccount];
        }
      }break;
        
      case kBookStateEnum_Downloading:{
        [book stopDownloadBook];
      }break;
        
      case kBookStateEnum_Pause:{
        if (NETWORK_REQUEST_ID_OF_IDLE == _netRequestIndexForGetBookDownloadUrl) {
          [weakSelf requestBookDownlaodUrlWithContentID:book.bookInfo.content_id bindAccount:book.bindAccount];
        }
      }break;
        
      case kBookStateEnum_NotInstalled:{
        
      }break;
        
      case kBookStateEnum_Unziping:{
        
      }break;
        
      case kBookStateEnum_Installed:{
        
        [weakSelf openBookWithBookSaveDirPath:book.bookSaveDirPath];
      }break;
      case kBookStateEnum_Update:{
        
      }break;
      default:
        break;
    }
  };
  
  [cell bind:book];
  return cell;
}

// cellの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 111;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSDictionary *bookCategoryDictionaryByBookNameSearch = [self.bookList bookCategoryDictionaryByBookNameSearch:self.latestSearchCriteria];
  NSArray *bookCategoryIDListOfSorted = [bookCategoryDictionaryByBookNameSearch.allKeys sortedArrayUsingSelector:@selector(compare:)];
  NSString *categoryIDOfSection = bookCategoryIDListOfSorted[section];
  
  // 通过 "分类ID" 获取 "分类Name"
  NSString *categoryNameString = [[GlobalDataCacheForMemorySingleton sharedInstance].localBookshelfCategoriesNetRespondBean categoryNameByCategoryID:[categoryIDOfSection integerValue]];
  
  UIImage *headerViewBackgroundImage = nil;
  // 竖屏
  if ([categoryNameString isEqual:@"通用"]) {
    headerViewBackgroundImage = [UIImage imageNamed:@"fl_ty_iphone"];
  } else if ([categoryNameString isEqual:@"宣传"]) {
    headerViewBackgroundImage = [UIImage imageNamed:@"fl_xc_iphone"];
  } else if ([categoryNameString isEqual:@"学习"]) {
    headerViewBackgroundImage = [UIImage imageNamed:@"fl_xx_iphone"];
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
  return 25;
}


#pragma mark - Keybord Observer

- (void)addKeypadObserver {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillAnimate:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillAnimate:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)keyboardWillAnimate:(NSNotification *)notification {
  // 除点击搜索框
  if (![self.searchTextField isFirstResponder]) {
    return;
  }
  
  CGRect keyboardBounds;
  [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
  NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
  
  keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:[duration doubleValue]];
  [UIView setAnimationCurve:[curve intValue]];
  
  CGRect rect = _footerViewOriginalFrame;
  if([notification name] == UIKeyboardWillShowNotification)
  {
    self.footerView.frame = CGRectMake(0, rect.origin.y - keyboardBounds.size.height, rect.size.width, rect.size.height);
  }
  else if([notification name] == UIKeyboardWillHideNotification)
  {
    self.footerView.frame = rect;
  }
  
  [UIView commitAnimations];
  
}

@end