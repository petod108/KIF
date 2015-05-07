//
//  UIAutomationHelper.m
//  KIF
//
//  Created by Joe Masilotti on 12/1/14.
//
//

#import "UIAutomationHelper.h"
#include <dlfcn.h>

@interface UIAElementArray : NSArray
- (id)firstWithName:(id)arg1;
@end


@interface UIAElement : NSObject <NSCopying>
{
    UIAElementArray *_elements;
}
- (NSString *)name;
- (NSString *)value;
- (NSArray *)scrollViews;
- (NSArray *)tableViews;
- (NSArray *)textFields;
- (NSArray *)secureTextFields;
- (NSArray *)buttons;
- (void)tap;
@end

@interface UIAButton : UIAElement

@end

@interface UIAKeyboard : UIAElement
- (void)typeString:(id)arg1;
@end

@interface UIAScrollView : UIAElement

@end

@interface UIATableCell : UIAElement
- (id)name;
- (id)value;
@end

@interface UIATextField : UIAElement
@end

@interface UIASecureTextField : UIATextField
@end

@interface UIATableView : UIAScrollView

- (id)cellCount;
- (id)cells;
- (id)firstVisibleCellIndex;
- (id)groups;
- (id)lastVisibleCellIndex;
- (id)value;
- (id)visibleCells;
- (id)visibleGroups;
@end

@interface UIAAlert : UIAElement
- (NSArray *)buttons;
- (id)cancelButton;
- (id)defaultButton;
- (id)name;
@end


@interface UIAWindow : UIAElement
- (UIAElementArray*)elements;
@end

@interface UIAApplication : UIAElement
- (UIAAlert *)alert;
- (NSArray *)windows;
- (UIAKeyboard *)keyboard;
@end

@interface UIATarget : UIAElement
+ (UIATarget *)localTarget;
- (UIAApplication *)frontMostApp;
@end

@interface UIAElementNil : UIAElement

@end

@implementation UIAutomationHelper

+ (UIAutomationHelper *)sharedHelper
{
    static dispatch_once_t once;
    static UIAutomationHelper *sharedHelper = nil;
    dispatch_once(&once, ^{
        sharedHelper = [[self alloc] init];
        [sharedHelper linkAutomationFramework];
    });
    return sharedHelper;
}

+ (void)acknowledgeiTunesWindowAndNewAlert:(BOOL) createOtherAlert windowCount:(NSInteger)count
{
    [[self sharedHelper] acknowledgeiTunesWindowAndNewAlert:createOtherAlert windowCount:count];
}

+ (void)acknowledgeiTunesWindowAndNewAlert:(BOOL)createOtherAlert username:(NSString*)username password:(NSString*)password windowCount:(NSInteger)count{
    [[self sharedHelper] acknowledgeiTunesWindowAndNewAlert:createOtherAlert username:username password:password windowCount:count];
}

- (void)acknowledgeiTunesWindowAndNewAlert:(BOOL) createOtherAlert windowCount:(NSInteger)count{
    UIAApplication *application = [[self target] frontMostApp];
    UIAAlert *alert = application.alert;
    
    UIAScrollView *scroll = nil;
    if (![alert isKindOfClass:[self nilElementClass]]) {
        scroll = [[alert scrollViews] firstObject];
    }
    else if([application.windows count] > count){
        UIAWindow *window = [application.windows lastObject];
        scroll = [[window scrollViews] firstObject];
    }

    if (scroll != nil) {
        NSUInteger position = [alert.buttons indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            UIAButton *button = obj;
            if([[button name] isEqualToString:@"Use Existing Apple ID"]){
                *stop = YES; return  YES;
            }
            return NO;
        }];
        if(position != NSNotFound){
            UIAButton *button = [alert.buttons objectAtIndex:position];
            [button tap];
        }
    }
    if(!createOtherAlert){
        while (![application.alert isKindOfClass:[self nilElementClass]]) { }
    }
}

- (void)acknowledgeiTunesWindowAndNewAlert:(BOOL)createOtherAlert username:(NSString*)username password:(NSString*)password windowCount:(NSInteger)count{
    UIAApplication *application = [[self target] frontMostApp];
    UIAAlert *alert = application.alert;

    UIAScrollView *scroll = nil;
    if (![alert isKindOfClass:[self nilElementClass]]) {
        scroll = [[alert scrollViews] firstObject];
    }
    else if([application.windows count] > count){
        UIAWindow *window = [application.windows lastObject];
        scroll = [[window scrollViews] firstObject];
    }

    if (scroll != nil) {
        UIAScrollView *scroll = [[alert scrollViews] firstObject];
        UIATableView *table = [[scroll tableViews] firstObject];
        NSArray * cells = [table cells];
        NSUInteger positionUsername = [cells indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            UIAElement * cell = obj;
            if([cell.textFields count] > 0){
                UIATextField * textField = [cell.textFields firstObject];
                if([[textField value] isEqualToString:@"username"]){
                    *stop = YES; return  YES;
                }
            }
            return NO;
        }];
        NSUInteger positionPassword = [cells indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            UIAElement * cell = obj;
            if([cell.secureTextFields count] > 0){
                UIASecureTextField * secureTextField = [cell.secureTextFields firstObject];
                if([[secureTextField value] isEqualToString:@"password"]){
                    *stop = YES; return  YES;
                }
            }
            return NO;
        }];
        
        UIAElement * cellUsername = nil;
        if(positionUsername != NSNotFound){
            cellUsername = [cells objectAtIndex:positionUsername];

            UIATextField * textField = [[cellUsername textFields] firstObject];
            [textField tap];
            [[application keyboard] typeString:username];
        }
        UIAElement * cellPassword = nil;
        if(positionPassword != NSNotFound){
            cellPassword = [cells objectAtIndex:positionPassword];

            UIASecureTextField * secureTextField = [cellPassword.secureTextFields firstObject];
            [secureTextField tap];
            [[application keyboard] typeString:password];
            UIAButton *button = [alert defaultButton];
            [button tap];
        }
        if(!createOtherAlert){
            while (![application.alert isKindOfClass:[self nilElementClass]]) { }
        }
    }
}

+ (void)waitForSystemAlertWindowCount:(NSInteger)count {
    [[self sharedHelper] waitForSystemAlertWindowCount:count];
}

- (void)waitForSystemAlertWindowCount:(NSInteger)count {
    UIAApplication *application = [[self target] frontMostApp];

    while ([application.alert isKindOfClass:[self nilElementClass]] && [application.windows count]==count) { }
}

+ (NSInteger)getWindowsCount {
    return [[self sharedHelper] getWindowsCount];
}

- (NSInteger)getWindowsCount {
    UIAApplication *application = [[self target] frontMostApp];
    
    return [application.windows count];
}



+ (void)acknowledgeSystemAlertAndNewAlert:(BOOL)createOtherAlert {
    [[self sharedHelper] acknowledgeSystemAlertAndNewAlert:createOtherAlert];
}

- (void)acknowledgeSystemAlertAndNewAlert:(BOOL)createOtherAlert {
    UIAApplication *application = [[self target] frontMostApp];
    UIAAlert *alert = application.alert;
    
    if (![alert isKindOfClass:[self nilElementClass]]) {
        [[alert.buttons lastObject] tap];
        if(!createOtherAlert){
            while (![application.alert isKindOfClass:[self nilElementClass]]) { }
        }
    }
}


+ (void)acknowledgeSystemAlert {
    [[self sharedHelper] acknowledgeSystemAlert];
}

- (void)acknowledgeSystemAlert {
    UIAApplication *application = [[self target] frontMostApp];
    UIAAlert *alert = application.alert;

    if (![alert isKindOfClass:[self nilElementClass]]) {
        [[alert.buttons lastObject] tap];
        while (![application.alert isKindOfClass:[self nilElementClass]]) { }
    }
}

#pragma mark - Private

- (void)linkAutomationFramework {
    dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);

    // Keep trying until the accessibility server starts up (it takes a little while on iOS 7)
    UIATarget *target = nil;
    while (!target) {
        @try {
            target = [self target];
        }
        @catch (NSException *exception) { }
        @finally { }
    }
}

- (UIATarget *)target {
    return [NSClassFromString(@"UIATarget") localTarget];
}

- (Class)nilElementClass {
    return NSClassFromString(@"UIAElementNil");
}

@end
