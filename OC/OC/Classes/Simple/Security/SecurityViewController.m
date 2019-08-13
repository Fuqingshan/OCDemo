//
//  SecurityViewController.m
//  OC
//
//  Created by yier on 2019/3/11.
//  Copyright © 2019 yier. All rights reserved.
//

#import "SecurityViewController.h"
#import "General.h"
#import <objc/message.h>

@interface SecurityViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation SecurityViewController

- (void)dealloc{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initData];
}

- (void)setupUI{
    self.navigationItem.title = LocalizedString(@"安全");
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)initData{
    [self getDataSource];
}

- (void)changeLanguageEvent{
    self.navigationItem.title = LocalizedString(@"安全");
    [self getDataSource];
}

- (void)getDataSource{
    self.dataSource = @[
                        @{
                            @"content":@"3DES"
                            ,@"sel":@"threeDESSelector"
                            }
                        ,@{
                            @"content":@"RSA"
                            ,@"sel":@"RSASelector"
                            }
                        ,@{
                            @"content":@"MD5"
                            ,@"sel":@"MD5Selector"
                            }
                        ,@{
                            @"content":@"AES"
                            ,@"sel":@"AESSelector"
                            }
                        ];
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *content = stringInDictionaryForKey(dic, @"content");
    cell.textLabel.text = [NSString stringWithFormat:@"%@",content];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dictionaryInArrayAtIndex(self.dataSource, indexPath.row);
    NSString *selStr = stringInDictionaryForKey(dic, @"sel");
    NSString *url = stringInDictionaryForKey(dic, @"url");
    if ([url isValide]) {
        [OCRouter openURL:[NSURL URLWithString:url]];
        return;
    }
    SEL sel = NSSelectorFromString(selStr);
    @try {
        ((void(*)(id,SEL))objc_msgSend)(self,sel);
        //有返回值
        //    ((NSString *(*)(id,SEL))objc_msgSend)(self,sel);
    } @catch (NSException *exception) {
        NSLog(@"%@",exception.reason);
    } @finally {
        
    }
}

- (void)threeDESSelector{
    NSString *content = @"在ARC机制的项目下使用MRC机制的文件,需要设置对应文件的Compiler Flags为-fno-objc-arc。";
    NSString *enc = [NSString DES_Encrypt:content withKey:threeDESKey];
    NSString *dec = [NSString DES_Decrypt:enc withKey:threeDESKey];
    NSLog(@"enc:%@  dec:%@",enc,dec);
}

/**
 公钥加密，私钥解密，私钥加密，公钥解密
 -----BEGIN PUBLIC KEY-----和-----END PRIVATE KEY-----不是必须的，直接去掉
 生成秘钥：
 1、桌面新建Key文件夹
 2、进入文件夹，终端输入：openssl
 3、生成私钥：genrsa -out rsa_private_key.pem 1024
 4、私钥转成PKCS8的格式：pkcs8 -topk8 -inform PEM -in rsa_private_key.pem -outform PEM -nocrypt
 5、拷贝除begin和end部分
 6、生成公钥部分：rsa -in rsa_private_key.pem -pubout -out rsa_public_key.pem
 7、打开key文件夹，找到rsa_public_key，记事本打开rsa_public_key.pem
 */
- (void)RSASelector{
    NSString *content = @"为美好的世界献上祝福";
    NSString *enc = [RSA encryptString:content publicKey:RSAPublickKey];
    NSString *dec = [RSA decryptString:enc privateKey:RSAPrivateKey];
    NSLog(@"enc:%@  dec:%@",enc,dec);
    
    NSString *encPubWeb = @"hpF9Ewhfo+cFISSOsBBvPWSPpu0KBkEsV9wmPodibsgFXkakTNBK9cPbfCZgU4hG/7G1l9OOoHfLzMReWa4/amiKBFwImBjtd+ig0wqKuJctFDRYqp6fVHhmJGZjcmnSiOSLXZryR2k2WcAtaOOAkbD10EUXnr11URGmYZOuWSI=";
    NSString *decApp1 = [RSA decryptString:encPubWeb privateKey:RSAPrivateKey];
    
    NSString *encPriWeb = @"rQXrLCS0mAd0ayReBhcpQb64Tppt1GwijpB1KrDD0kCbdpsDkD2qaEBSMjY80yty5qy3bmtEzpPs9O9BOQaaquN3BKobzojYKN5Jdhqkk53ULRIPdzJWXwKUG9oiYUIBCJGJvO4lUi+3oGl0V0rNNZKSS3WkNYRUoBg5Y3lHpDM=";
    NSString *decApp2 = [RSA decryptString:encPriWeb publicKey:RSAPublickKey];

    NSLog(@"decApp:%@ decApp2:%@",decApp1,decApp2);
}

- (void)MD5Selector{
    NSString *content = @"为美好的世界献上祝福";
    content = [NSString MD5_32BitLower:content];
    NSLog(@"content：%@",content);
}

- (void)AESSelector{
    NSString *content = @"为美好的世界献上祝福";
    NSString *enc = [NSString AES_EncryptString:content appKey:AESKey];
    NSString *dec = [NSString AES_DecryptString:enc appKey:AESKey];
    NSLog(@"enc:%@  dec:%@",enc,dec);
    
    NSString *hexEnc = [NSString AES_EncryptUnEncryptedContent:content appKey:AESKey];
    NSString *hexDec = [NSString AES_DecryptHexString:hexEnc appKey:AESKey];
    NSLog(@"hexEnc:%@ hexDec:%@",hexEnc,hexDec);
}

@end
