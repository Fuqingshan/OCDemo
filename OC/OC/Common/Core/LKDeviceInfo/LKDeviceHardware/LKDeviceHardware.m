//
//  LKDeviceHardware.m
//  App
//
//  Created by yier on 2018/6/19.
//  Copyright © 2018年 yier. All rights reserved.
//

#import "LKDeviceHardware.h"
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/mount.h>

@implementation LKDeviceHardware

+ (NSString *) cpuType{
    size_t size;
    cpu_type_t type;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    NSString * typeStr = nil;
    switch (type) {
            case CPU_TYPE_ARM64:
            typeStr = @"ARM64";
            break;
            case CPU_TYPE_ARM:
            typeStr = @"ARM";
            break;
            case CPU_TYPE_X86:
            typeStr = @"X86";
            break;
            case CPU_TYPE_X86_64:
            typeStr = @"X86_86";
            break;
        default:
            typeStr = @"unKnow";
            break;
    }
    return typeStr;
    
}

+ (NSString *) cpuSubType{
    size_t size;
    cpu_subtype_t subtype;
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    return [NSString stringWithFormat:@"%d",subtype];
}

#pragma mark -- 内存及硬盘情况

+ (NSString *) totalMemory{
    return [LKDeviceHardware humanReadableStringFromBytes:[LKDeviceHardware physicalMemory]];
}

+ (NSString *) freeMemory{
    return [LKDeviceHardware humanReadableStringFromBytes:[LKDeviceHardware availableMemory]];
}

//获取当前设备可用内存(单位：MB）
+ (unsigned long long)availableMemory{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return (vm_page_size * vmStats.free_count);
}

//当前设备总内存
+ (unsigned long long)physicalMemory{
    return [NSProcessInfo processInfo].physicalMemory;
}

+ (NSDictionary *)attributesOfFileSystemForPath{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    return dictionary;
}

//手机总空间
+ (NSString *) totalDiskSpaceInBytes
{
    /// 总大小
    float totalsize = 0.0;
    NSDictionary *dic = [LKDeviceHardware attributesOfFileSystemForPath];
    if (dic) {
        NSNumber *_free = [dic objectForKey:NSFileSystemSize];
        totalsize = [_free unsignedLongLongValue]*1.0;
    }
    
    return [self humanReadableStringFromBytes:totalsize];
}

//手机剩余空间
+ (NSString *) freeDiskSpaceInBytes{
    /// 剩余大小
    float freesize = 0.0;
    NSDictionary *dic = [LKDeviceHardware attributesOfFileSystemForPath];
    if (dic) {
        NSNumber *_free = [dic objectForKey:NSFileSystemFreeSize];
        freesize = [_free unsignedLongLongValue]*1.0;
    }
    
    return [self humanReadableStringFromBytes:freesize];
    
}

//计算文件大小
+ (NSString *)humanReadableStringFromBytes:(unsigned long long)byteCount
{
    float numberOfBytes = byteCount;
    int multiplyFactor = 0;

    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB",nil];

    while (numberOfBytes > 1024) {
        numberOfBytes /= 1024;
        multiplyFactor++;
    }

    return [NSString stringWithFormat:@"%4.2f %@",numberOfBytes, [tokens objectAtIndex:multiplyFactor]];
}

+ (void)printLKDeviceNetInfo{
    NSLog(@"\n---------------LKDeviceHardware-----------------\n[LKDeviceHardware totalMemory]:%@\n[LKDeviceHardware freeMemory]:%@\n[LKDeviceHardware cpuType]:%@\n[LKDeviceHardware cpuSubType]:%@\n[LKDeviceHardware freeDiskSpaceInBytes]:%@\n[LKDeviceHardware totalDiskSpaceInBytes]:%@\n--------------------------------------"
          ,[LKDeviceHardware totalMemory]
          ,[LKDeviceHardware freeMemory]
          ,[LKDeviceHardware cpuType]
          ,[LKDeviceHardware cpuSubType]
          ,[LKDeviceHardware freeDiskSpaceInBytes]
          ,[LKDeviceHardware totalDiskSpaceInBytes]
          );
}

//+ (void)load{
//    [LKDeviceHardware printLKDeviceNetInfo];
//}

@end
