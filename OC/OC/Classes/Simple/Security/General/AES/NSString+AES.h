#import <Foundation/Foundation.h>

@interface NSString (Encryption)

/**
 将未加密内容转成带密码的16进制字符串
 */
+ (NSString *)AES_EncryptUnEncryptedContent:(NSString*)unencryptedContent appKey:(NSString*)key;


/**
 将带密码的16进制字符串还原成未加密的内容
 */
+(NSString *)AES_DecryptHexString:(NSString *)dataClassHexString  appKey:(NSString*)key;

/**
 AES加密
 */
+ (NSString*)AES_EncryptString:(NSString*)string appKey:(NSString*)key;

/**
 AES解密
 */
+ (NSString*)AES_DecryptString:(NSString*)string appKey:(NSString*)key;

@end
