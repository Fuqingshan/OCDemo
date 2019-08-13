#import "NSString+AES.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSObject+Hex.h"

#define gIv          @"0102030405060708" //可以自行修改

@implementation NSString (Encryption)

//(key和iv向量这里是16位的) 这里是CBC加密模式，安全性更高
+ (NSData *)AES128EncryptWithData:(NSData *)data key:(NSString *)key {//加密
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


+ (NSData *)AES128DecryptWithData:(NSData *)data key:(NSString *)key {//解密
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

NSString *base64_encode_data(NSData *data){
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

NSData *base64_decode(NSString *str){
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

#pragma mark - AES加密
//将string转成带密码的data
+ (NSString*)AES_EncryptString:(NSString*)string appKey:(NSString*)key
{
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [NSString AES128EncryptWithData:data key:key];
    NSString *enc = base64_encode_data(encryptedData);
    
    return enc;
}

#pragma mark - AES解密
//将带密码的data转成string
+ (NSString*)AES_DecryptString:(NSString *)string appKey:(NSString*)key
{
    NSData *data = base64_decode(string);
    //使用密码对data进行解密
    NSData *decryData = [NSString AES128DecryptWithData:data key:key];
    //将解了密码的nsdata转化为nsstring
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return str;
}

#pragma mark - 16进制AES加密
+ (NSString *)AES_EncryptUnEncryptedContent:(NSString*)unencryptedContent appKey:(NSString*)key{
    //将nsstring转化为nsdata
    NSData *data = [unencryptedContent dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [NSString AES128EncryptWithData:data key:key];
    //将加密后的Data转为16进制字符串
    NSString * dataClassHexString = [NSObject Hex_DataToHexStringByData:encryptedData];
    
    return dataClassHexString ;
}

#pragma mark - 16进制AES解密
+(NSString *)AES_DecryptHexString:(NSString *)dataClassHexString  appKey:(NSString*)key{
    //把加密的16进制字符串转为2进制NSData类型
    NSData * data = [NSObject Hex_StringToHexDataByString:dataClassHexString];
    //使用密码对data进行解密
    NSData *decryData = [NSString AES128DecryptWithData:data key:key];
    //将解了密的NSData转化为nsstring
    NSString * unencryptedContent = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return unencryptedContent;
}


@end
