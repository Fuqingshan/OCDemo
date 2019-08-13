//
//  WKWebViewController.m
//  App
//
//  Created by yier on 2018/5/2.
//  Copyright © 2018年 yier. All rights reserved.
//

/*
 异常处理：https://www.cnblogs.com/NSong/p/6489802.html
 WKWebView 上调用 -[WKWebView goBack], 回退到上一个页面后不会触发window.onload()函数、不会执行JS
 */

#import "WKWebViewController.h"
#import <Masonry/Masonry.h>
#import "NetworkErrorView.h"

@implementation NSHTTPCookie (Utils)

- (NSString *)javascriptString {
    
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@", self.name, self.value, self.domain, self.path ?: @"/"];
    if (self.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    return string;
}
@end

//截屏
@implementation UIView (ImageSnapshot)
- (UIImage*)imageSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,YES,self.contentScaleFactor);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

NSString *const kMessageHandler = @"OCMessageHandler";

@interface WKWebViewController ()<WKUIDelegate, WKScriptMessageHandler,UIScrollViewDelegate>
@property (nonatomic, strong) WKWebViewConfiguration *webConfig;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,strong) NetworkErrorView *errorView;

@property (nonatomic, strong) WKProcessPool *processPool;
@property (nonatomic, copy) NSArray<NSString *> *jsMethods;///<预留js调用原生方法接口

@property (nonatomic, assign) BOOL viewhadLoad;///<页面加载出来了

@property (nonatomic, copy) NSString *networkErrorHtml;
@end

@implementation WKWebViewController

-(void)dealloc{
    self.webView.UIDelegate = nil;
    self.webView.navigationDelegate = nil;
    self.webView.scrollView.delegate = nil;
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self clearCache];
}

#pragma mark - setter
- (void)setUrlStr:(NSString *)urlStr{
    if ([NSString isContainsChineseCharacter:urlStr]) {
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    _urlStr = urlStr;
}

/*
 在willAppear添加js方法，在viewWillDisappear移除，防止循环引用
 webview被self持有，webview持有userContentController，userContentController持有self
*/
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
     线上出现部分用户willAppear时对应的kMessageHandler还存在的情况，猜测是快速viewWillDisappear到viewWillAppear切换q引起的，这儿加锁保护
     */
    @synchronized (self.jsMethods) {
        [self.jsMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.webConfig.userContentController addScriptMessageHandler:self name:obj];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    @synchronized (self.jsMethods) {
        [self.jsMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.webConfig.userContentController removeScriptMessageHandlerForName:obj];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.viewhadLoad = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self loadWebView];
}

- (void)loadWebView{
    if (!self.webView) {
        return;
    }
    if (![self.urlStr isValide]) {
        return;
    }
    if ([self.urlStr hasPrefix:@"http"]) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
        // 解决首次请求带不上cookie
        NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        NSDictionary *headerFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        request.allHTTPHeaderFields = headerFields;
        request.timeoutInterval = 10.0f;
        [self.webView loadRequest:request];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    }
}

- (void)setupView{
    [self setupProgressView];
    [self setupWKWebView];
    [self createObserve];
}

- (void)setupProgressView{
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    self.progressView.tintColor = LKHexColor(0xFFAE22);
    self.progressView.trackTintColor = LKHexColor(0xEEEEEE);
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.mas_topLayoutGuideTop);
        }
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(2.0f);
    }];
}

- (void)setupWKWebView{
    self.webConfig = [[WKWebViewConfiguration alloc] init];
    if (@available(iOS 10.0, *)) {
        self.webConfig.mediaTypesRequiringUserActionForPlayback = self.allMediaAutoPlay?WKAudiovisualMediaTypeNone:WKAudiovisualMediaTypeAll;
    }else{
        self.webConfig.requiresUserActionForMediaPlayback = !self.allMediaAutoPlay;
    }
    self.webConfig.userContentController = [[WKUserContentController alloc] init];
    
    WKPreferences *preference = [[WKPreferences alloc] init];
    //允许js交互
    preference.javaScriptEnabled = YES;
    //在没有用户交互的情况下，是否JavaScript可以打开windows
    //    preference.javaScriptCanOpenWindowsAutomatically = YES;
    self.webConfig.preferences = preference;
    
    // 解决后续ajax带不上cookie
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[self cookieJSString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.webConfig.userContentController addUserScript:cookieScript];
    
    if (!self.ignoreScalesPageToFit) {
        //解决WKWebView不支持scalePageToFit的问题
        WKUserScript *scalesPageToFitScript = [[WKUserScript alloc] initWithSource:[self scalesPageToFitString] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [self.webConfig.userContentController addUserScript:scalesPageToFitScript];
    }
    
    if (self.invalidZoomEnabled) {
        //解决WKWebView默认支持缩放的问题
        WKUserScript *zoomScript = [[WKUserScript alloc] initWithSource:[self zoomString] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [self.webConfig.userContentController addUserScript:zoomScript];
    }
    
    self.processPool = [WKProcessPool new];
    self.webConfig.processPool = self.processPool;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webConfig];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(kHomeIndicatorHeight);
    }];
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, kHomeIndicatorHeight, 0);
    
    [self changeUserAgent];
}

- (void)changeUserAgent{
    @weakify(self);
    [self evaluateJS:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        @strongify(self);
        if (@available(iOS 9.0, *)) {
            [self.webView setCustomUserAgent:[self defaultUserAgent]];
        }else{
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self defaultUserAgent], @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)createObserve{
    @weakify(self);
    [[[RACObserve(self, progressView.hidden) takeUntil:self.rac_willDeallocSignal]
      distinctUntilChanged]
            subscribeNext:^(NSNumber *hiddenNumber) {
                @strongify(self);
                CGFloat height = hiddenNumber.boolValue?0:2;
                [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(height);
                }];
    }];
    
    //配置进度条、title、loading
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loading"]) {
//        self.webView.isLoading -> YES or NO
    }
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.webView.estimatedProgress == 1?
        self.progressView.progress = 0:
        [self.progressView setProgress:(float)self.webView.estimatedProgress animated:YES];
    }
    
    if ([keyPath isEqualToString:@"title"] && !self.ignoreWebTitle && [self.webView.title isValide]) {
        self.title = self.webView.title;
    }
}

///WKWebView 需要通过scrollView delegate调整滚动速率
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

-(void)clearCache{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
        NSSet * types = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,WKWebsiteDataTypeMemoryCache]];
        NSDate * date = [NSDate date];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:types modifiedSince:date completionHandler:^{
        }];
    }
    else{
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES).firstObject;
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        [[NSFileManager defaultManager]removeItemAtPath:cookiesFolderPath error:nil];
    }
}

#pragma mark - goBack
- (void)goBack{
    
    self.viewhadLoad = NO;
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
//    //当host不同时会打开新的页面，因此返回直接pop就好了
//        if ([self.webView canGoBack]) {
//            [self.webView goBack];
//        } else {
//            self.viewhadLoad = NO;
//            if (self.presentedViewController) {
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }else{
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }
}

#pragma mark - WKScriptMessageHandler
/**
 *  在JavaScript 将信息发给Objective-C:
 // window.webkit.messageHandlers.<name>.postMessage();
 //这儿的name就是注册时的name
 //type为本地方法名
 
 function postMyMessage() {
 var message = { 'type' : 'reloadWebView', 'params' : "path和query组成的后半部分url" };
 window.webkit.messageHandlers.OCMessageHandler.postMessage(message);
 }
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.name isEqualToString:kMessageHandler]) {
        return;
    }
    LKLogm(@"WKWebView --- messageBody:%@",message.body);
    id json = message.body;
    if (![json isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDictionary *dic = json;
    NSString *type = stringInDictionaryForKey(dic, @"type");
    //如果返回的方法不存在
    if (![type isValide]) {
        return;
    }
    SEL sel = NSSelectorFromString(type);
    //如果不加参数能直接找到这个方法，则直接调用,如果找不到，尝试增加参数查找
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:nil afterDelay:0];
    }else{
        type = [type stringByAppendingString:@":"];
        sel = NSSelectorFromString(type);
        id params = objectInDictionaryForKey(dic, @"params");
        NSString *param = @"";
        if ([params isKindOfClass:[NSString class]]) {
            param = params;
        }else if ([params isKindOfClass:[NSArray class]]) {
            
        }
        
        //如果增加了参数能找到，则执行
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel withObject:param afterDelay:0];
        }
    }
}

- (void)evaluateJS:(NSString *)jsString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler{
    [self.webView evaluateJavaScript:jsString completionHandler:completionHandler];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    LKLogm(@"WKWebView --- start load web %@", webView.URL.absoluteString);
    [self.progressView setProgress:0.0];
    self.progressView.hidden = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    LKLogm(@"WKWebView --- finish load web %@", webView.URL.absoluteString);
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    LKLogm(@"WKWebView --- 加载数据时发生错误:%@",error);
    self.progressView.hidden = YES;
    [self showErrorView];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    /*
     在 UIWebView 上当内存占用太大的时候，App Process 会 crash；而在 WKWebView 上当总体的内存占用比较大的时候，WebContent Process 会 crash，从而出现白屏现象。在 WKWebView 中加载下面的测试链接可以稳定重现白屏现象:
     http://people.mozilla.org/~rnewman/fennec/mem.html
     解决白屏：
     1.当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用webViewWebContentProcessDidTerminate,手动刷新解决白屏
     2.检测 webView.title 是否为空，为空时reload，但是这个方式需要h5配合
     */
    [webView reload];
}

/**
 *  当视图到达webview时，这时可以注入js代码来显示
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    LKLogm(@"WKWebView --- %@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    LKLogm(@"WKWebView --- 导航跳转失败：%@",error);
}

- (void)webViewDidClose:(WKWebView *)webView
{
    LKLogm(@"WKWebView --- webview关闭");
}

#pragma mark - handle navigation
/**
 * 这个代理方法是用于处理是否允许跳转导航。对于跨域只有Safari浏览器才允许，其他浏览器是不允许的，因此我们需要额外处理跨域的链接。
 * 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨域
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *navigationActionURL = navigationAction.request.URL;
    LKLogm(@"WKWebView --- hostName:%@ navigationType:%zd",navigationActionURL.absoluteString,navigationAction.navigationType );
    LKLogm(@"WKWebView --- wk nav action http header: %@", navigationAction.request.allHTTPHeaderFields);
    //微信等点击时type可能是WKNavigationTypeOther
    BOOL isTap = navigationAction.navigationType == WKNavigationTypeLinkActivated || navigationAction.navigationType == WKNavigationTypeOther;
    BOOL isLoadingDisableScheme = [self isLoadingWKWebViewDisableScheme:navigationActionURL] && isTap;
    //是否是一些特定的scheme
    if (isLoadingDisableScheme) {
        SEL sel = NSSelectorFromString(@"mallExternURL:");
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel withObject:navigationActionURL.absoluteString afterDelay:0];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //http || https 点击触发（严格校验是点击触发的href），且与初始的host不同，重新打开一个页面
    BOOL isCrossDomain = navigationAction.navigationType == WKNavigationTypeLinkActivated && [navigationActionURL.scheme hasPrefix:@"http"] && ![navigationActionURL.host isEqualToString:[NSURL URLWithString:self.urlStr].host];
    if (isCrossDomain) {
        SEL sel = NSSelectorFromString(@"openCrossDomainURL:");
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel withObject:navigationActionURL.absoluteString afterDelay:0];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

/**
 *  决定是否允许导航响应，如果不允许就不会跳转到该链接的页面
 *
 *  @param webView            当前的webview
 *  @param navigationResponse 导航的response
 *  @param decisionHandler    是否允许
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    LKLogm(@"WKWebView ---  nav response url: %@", response.URL);
    LKLogm(@"WKWebView --- response header: %@", response.allHeaderFields);
    LKLogm(@"WKWebView --- response status code %zd", response.statusCode);
    if (response.statusCode == 502 || response.statusCode == 404) {
        self.progressView.hidden = YES;
        [self showErrorView];
        decisionHandler(WKNavigationResponsePolicyCancel);
    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

/**
 *  如果我们的请求要求授权、证书等，我们需要处理下面的代理方法，以提供相应的授权处理等：
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    LKLogm(@"WKWebView ---  %@",NSStringFromSelector(_cmd));
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
}

/**
 *  服务器重定向时,收到服务器跳转请求后调用
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    LKLogm(@"WKWebView --- 服务器重定向");
}

#pragma mark - alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    /*
     1.push 或者 present动画未完成时弹出alert会crash
     2.webView退出时执行弹出alert
     
     这两种都会导致completionHandler()不执行，引起crash
     */
    if (!self.viewhadLoad) {
        completionHandler();
        return;
    }

    if (self.viewhadLoad){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:nilToEmptyString(message) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        completionHandler();
    }
}

#pragma mark - errorView
- (void)showErrorView{
    [self.webView loadHTMLString:self.networkErrorHtml baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

#pragma mark - lazy load
- (NSString *)networkErrorHtml{
    if(!_networkErrorHtml){
        NSString *netWorkErrorPath = [[NSBundle mainBundle] pathForResource:@"networkError" ofType:@"html"];
        _networkErrorHtml = [NSString stringWithContentsOfFile:netWorkErrorPath encoding:NSUTF8StringEncoding error:nil];
    }
    return _networkErrorHtml;
}

- (NSArray<NSString *> *)jsMethods{
    if(!_jsMethods){
        _jsMethods = @[
                       kMessageHandler
                       ];
    }
    return _jsMethods;
}

- (NSString *)cookieJSString {
        NSMutableString *script = [NSMutableString string];
    [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        [script appendFormat:@"if (cookieNames.indexOf('%@') == -1) { document.cookie='%@'; };\n", cookie.name, cookie.javascriptString];
    }
    return script;
}

- (NSString *)scalesPageToFitString{
     NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    return jScript;
}

- (NSString *)zoomString{
    NSString *jScript = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=yes\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    return jScript;
}

- (NSString *)defaultUserAgent{
    NSString * userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", @"OC", (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)];
    
    return userAgent;
}

/**
 判断当前加载的url是否是WKWebView不能打开的协议类型
 */
- (BOOL)isLoadingWKWebViewDisableScheme:(NSURL*)url
{
    BOOL retValue = NO;
    //判断是否正在加载WKWebview不能识别的协议类型：phone numbers, email address, maps, etc.
    if ([url.scheme isEqualToString:@"tel"]) {
        UIApplication* app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            retValue = YES;
        }
    }
    
    return retValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

