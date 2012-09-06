//
//  unitTests.m
//  unitTests
//
//  Created by Patrick M on 5/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "unitTests.h"
#import "XVimMotionEvaluator.h"
#import "XVimSourceView+Vim.h"
#import "XVimSourceView.h"
#import "XVimWindow.h"
#import "XVimKeyStroke.h"
#import "XVim.h"

#define MAX_TESTCASES 100
#define CHECK_FILE_ERROR(error, filename) if(0 != [error code]){NSLog(@"Error opening file: %@", filename); break;}

#pragma mark Start Tests
XVimSourceView *testsourceview;
XVimWindow *testwindow;
NSTextView *txtview;

@implementation unitTests

- (void)setUp{
    [super setUp];
    [XVim initForTesting];
    testwindow = [[XVimWindow alloc] init];
    txtview = [[NSTextView alloc] init];
    testsourceview = [[XVimSourceView alloc] initWithView:txtview];
    ((NSTextView *)[testsourceview view]).string =  @"this is    a test\n    \n\n \n\n\n\n\n";
    [testwindow setSourceView:testsourceview]; 
}

- (void)tearDown{
    [testsourceview release];
    [txtview release];
    [testwindow release];
    [super tearDown];
}

- (void)test_wordsForward_count_option_info{
    XVimWordInfo info;
    info.findEndOfWord = TRUE;
    NSUInteger to = 0; 
    NSError* err = [[NSError alloc] init];
    for (int i = 0; i < MAX_TESTCASES; i++) {
        NSString* baseTestcaseName = [NSString stringWithFormat:@"wordsforward%d", i];
        
        NSString* testcase = [NSString stringWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"weaksauce.unitTests"] pathForResource:baseTestcaseName ofType:@"test"] encoding:NSUTF8StringEncoding error:&err];
        CHECK_FILE_ERROR(err, baseTestcaseName);
        
        if(testcase){
            ((NSTextView *)[testsourceview view]).string = testcase;
        }else {
            break;
        }
        
        NSString* testResults = [NSString stringWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"weaksauce.unitTests"] pathForResource:baseTestcaseName ofType:@"testResults"] encoding:NSUTF8StringEncoding error:&err];
        CHECK_FILE_ERROR(err, baseTestcaseName);
        
        
        NSArray* results = [testResults componentsSeparatedByString:@"\n"];
        
        for(NSUInteger j = 1; j < [results count]; j++){
            if([results count] >= j){break;};
            NSArray* items = [[results objectAtIndex:j] componentsSeparatedByString:@" "];
            if([items count] == 0) break;
            NSInteger from = [(NSString*)[items objectAtIndex:0] integerValue];
            NSInteger count = [[items objectAtIndex:1] integerValue];
            NSInteger expectedResult = [[items objectAtIndex:2] integerValue];
            
            to = [testsourceview wordsForward:(NSUInteger)from count:(NSUInteger)count option:MOTION_OPTION_NONE info:&info];
            STAssertEquals(expectedResult, to, @"words Forward failed from: %d, count: %d, expected:%d, actual: %lu", from, count, expectedResult, to); 
        }
        
        
    }

    [testsourceview release];
    testsourceview = nil;
    STAssertNil(testsourceview, @"testsourceview not nil");
}

@end
