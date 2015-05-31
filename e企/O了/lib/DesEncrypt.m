//
//  DesEncrypt.m
//  EIMClient
//
//  Created by 许学 on 14/11/18.
//  Copyright (c) 2014年 xuxue. All rights reserved.
//

#import "DesEncrypt.h"

#import<CommonCrypto/CommonCryptor.h>

@implementation DesEncrypt

static Byte iv[] = {1,2,3,4,5,6,7,8};

+ (NSString *)encryptWithText:(NSString *)sText
{
    //kCCEncrypt 加密
    //return [self encrypt:sText encryptOrDecrypt:kCCEncrypt key:[DesEncrypt getKey]];
    
    return [self encryptUseDES:sText key:[DesEncrypt getKey]];
}

+ (NSString *)decryptWithText:(NSString *)sText
{
    //kCCDecrypt 解密
    return [self encrypt:sText encryptOrDecrypt:kCCDecrypt key:[DesEncrypt getKey]];
}

+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSData *)key
{
    const void *dataIn;
    size_t dataInLength;
    
    if (encryptOperation == kCCDecrypt)//传递过来的是decrypt 解码
    {
        //解码 base64
        //NSData *decryptData = [GTMBase64 decodeData:[sText dataUsingEncoding:NSUTF8StringEncoding]];//转成utf-8并decode
        
        NSData* decryptData = [DesEncrypt hexToBytes:sText];
        dataInLength = [decryptData length];
        dataIn = [decryptData bytes];
    }
    else  //encrypt
    {
        NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
        dataInLength = [encryptData length];
        dataIn = (const void *)[encryptData bytes];
    }
    
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码，比如：一个人用int，一个人用long。最好用typedef来定义）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    
    //Byte iv[] = {1,2,3,4,5,6,7,8};

    const void *vkey = (const void *) [key bytes];
    //const void *iv = (const void *) [initIv UTF8String];
    
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(encryptOperation,//  加密/解密
                       kCCAlgorithmDES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       vkey,  //密钥    加密和解密的密钥必须一致
                       kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       nil, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt)//encryptOperation==1  解码
    {
        //得到解密出来的data数据，改变为utf-8的字符串
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
    }
    else //encryptOperation==0  （加密过程中，把加好密的数据转成base64的）
    {

        //编码 base64
        NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
        NSLog(@"%@",data);
        
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //result = [GTMBase64 stringByEncodingData:data];
        return [DesEncrypt bytesToHex:data];
        NSLog(@"%@",str);
        //return str;
    }
    
    return result;
}

+(NSString *) encryptUseDES:(NSString *)plainText key:(NSData *)key

{

    NSString *ciphertext = nil;

    const char *textBytes = [plainText UTF8String];

    NSUInteger dataLength = [plainText length];
    
    const void *vkey = (const void *) [key bytes];

    unsigned char buffer[1024];

    memset(buffer, 0, sizeof(char));

    size_t numBytesEncrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                       kCCOptionPKCS7Padding,
                                       vkey,
                                       kCCKeySizeDES,
                                       iv,
                                       textBytes, dataLength,
                                       buffer, 1024,
                                       &numBytesEncrypted);

    if (cryptStatus == kCCSuccess) {

        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        NSLog(@"%@",data);

        ciphertext = [self bytesToHex:data];

    }

    return ciphertext;
    
}


+ (NSData *)getKey
{
    Byte oddRandom[16] = {0};
    for (int i = 0; i < 16; ++ i) {
        oddRandom[i] = (Byte)(8 + 2 * i);
    }

    return [NSMutableData dataWithBytes:oddRandom length:8];

}

+ (NSString*)bytesToHex:(NSData*)bytesData
{
    NSMutableString *hex = [NSMutableString string];
    unsigned char *bytes = (unsigned char *)[bytesData bytes];
    char temp[3];
    int i = 0;
    
    for (i = 0; i < [bytesData length]; i++) {
        temp[0] = temp[1] = temp[2] = 0;
        (void)sprintf(temp, "%02x", bytes[i]);
        [hex appendString:[NSString stringWithUTF8String:temp]];
    }
    
    return [hex uppercaseString];
}

+ (NSData*)hexToBytes:(NSString*)strHex
{
    NSMutableData* data = [[NSMutableData alloc] init];
    int idx;
    for (idx = 0; idx+2 <= strHex.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [strHex substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}



@end
