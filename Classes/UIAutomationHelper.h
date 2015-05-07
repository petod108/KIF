//
//  UIAutomationHelper.h
//  KIF
//
//  Created by Joe Masilotti on 12/1/14.
//
//

#import <Foundation/Foundation.h>

@class KIFTestActor;

@interface UIAutomationHelper : NSObject

+ (NSInteger)getWindowsCount;
+ (void)waitForSystemAlertWindowCount:(NSInteger)count;
+ (void)acknowledgeSystemAlert;
+ (void)acknowledgeSystemAlertAndNewAlert:(BOOL)createOtherAlert;
+ (void)acknowledgeiTunesWindowAndNewAlert:(BOOL)createOtherAlert windowCount:(NSInteger)count;
+ (void)acknowledgeiTunesWindowAndNewAlert:(BOOL)createOtherAlert username:(NSString*)username password:(NSString*)password windowCount:(NSInteger)count;

@end
