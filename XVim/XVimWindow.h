//
//  XVimBuffer.h
//  XVim
//
//  Created by Tomas Lundell on 9/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XVimMode.h"
#import "XVimCommandLine.h"
#import "XVimPlaybackHandler.h"

@class XVimSourceView;
@class XVimEvaluator;
@class XVimRegister;

@interface XVimWindow : NSObject <NSTextFieldDelegate, XVimCommandFieldDelegate, XVimPlaybackHandler>

@property(strong) XVimSourceView* sourceView;
@property(unsafe_unretained, readonly) XVimEvaluator *currentEvaluator;
@property(unsafe_unretained) XVimCommandLine *commandLine;


@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger insertionPoint;

- (BOOL)handleKeyEvent:(NSEvent*)event;
- (void)beginMouseEvent:(NSEvent*)event;
- (void)endMouseEvent:(NSEvent*)event;
- (NSRange)restrictSelectedRange:(NSRange)range;
@property (NS_NONATOMIC_IOSONLY, getter=getLocalMarks, readonly, copy) NSMutableDictionary *localMarks;

- (void)drawRect:(NSRect)rect;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL shouldDrawInsertionPoint;
- (void)drawInsertionPointInRect:(NSRect)rect color:(NSColor*)color;

- (void)setEvaluator:(XVimEvaluator*)evaluator;

// XVimCommandFieldDelegate
- (void)commandFieldLostFocus:(XVimCommandField*)commandField;

// XVimPlaybackHandler
- (void)handleKeyStroke:(XVimKeyStroke*)keyStroke;
- (void)handleTextInsertion:(NSString*)text;
- (void)handleVisualMode:(VISUAL_MODE)mode withRange:(NSRange)range;

- (void)recordIntoRegister:(XVimRegister*)xregister;
- (void)stopRecordingRegister:(XVimRegister*)xregister;

- (void)errorMessage:(NSString *)message ringBell:(BOOL)ringBell;
- (void)statusMessage:(NSString*)message;
- (void)clearErrorMessage;

- (void)associateWith:(id)object;
+ (XVimWindow*)associateOf:(id)object;


- (void)setForcusBackToSourceView;

@end
