//
//  SystemAlertTests.m
//  KIF
//
//  Created by Joe Masilotti on 12/1/14.
//
//

#import <KIF/KIF.h>
#import <KIF/UIAutomationHelper.h>

@interface AiTunesAlertTests : KIFTestCase

@end

@implementation AiTunesAlertTests

- (void)beforeEach
{

}

- (void)afterEach
{

}

- (void)testAuthorizingiTunesServices {
    [UIAutomationHelper acknowledgeSystemAlert];
    NSInteger count = [UIAutomationHelper getWindowsCount];
    [tester tapViewWithAccessibilityLabel:@"iTunes"];
    [tester waitForTimeInterval:5];
    [UIAutomationHelper waitForSystemAlertWindowCount:count];
    [UIAutomationHelper acknowledgeiTunesWindowAndNewAlert:YES windowCount:count];
    [UIAutomationHelper acknowledgeiTunesWindowAndNewAlert:YES username:@"pdurisintest@zinio.com" password:@"Zinio123" windowCount:count];
    [UIAutomationHelper acknowledgeSystemAlert];
}

@end
