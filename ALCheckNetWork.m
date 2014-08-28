//
//  ALCheckNetWork.m
//  Pandora
//
//  Created by Albert on 13-6-26.
//  Copyright (c) 2014年 Pandora. All rights reserved.
//

#import "ALCheckNetWork.h"
#import "Reachability/Reachability.h"
@implementation ALCheckNetWork

+ (BOOL)isUsingWifi{
  BOOL isUsingWifi = NO;
  Reachability *rea = [Reachability reachabilityForInternetConnection];
  if (rea.isReachable){
    if (rea.isReachableViaWiFi) {
      isUsingWifi = YES;
    }
  }
  return isUsingWifi;
}

+ (BOOL)isReachable:(NSString *)serverName{
  Reachability *rea = [Reachability reachabilityWithHostname:serverName];
  if (rea.isReachable){
    return YES;
  }
  return NO;
}

+ (NSString*)currentNetWork:(NSString *)serverName{
  Reachability *rea = [Reachability reachabilityWithHostname:serverName];
  if (rea.isReachable){
    if (rea.isReachableViaWiFi) {
      return @"WLAN";
    }
    else{
      return @"3G/2G";
    }
  }
  return @"None";
}
@end
