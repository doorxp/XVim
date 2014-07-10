//
//  XVimEvaluatorContext.h
//  XVim
//
//  Created by Tomas Lundell on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XVimRegister;

@interface XVimEvaluatorContext : NSObject

+ (XVimEvaluatorContext*)contextWithNumericArg:(NSUInteger)numericArg;

+ (XVimEvaluatorContext*)contextWithArgument:(NSString*)argument;

- (XVimRegister*)yankRegister;

- (XVimRegister*)setYankRegister:(XVimRegister*)yankRegister;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger numericArg;

- (void)pushEmptyNumericArgHead;

- (void)setNumericArgHead:(NSUInteger)numericArg;

- (NSNumber*)numericArgHead;

- (NSString*)argumentString;

- (XVimEvaluatorContext*)setArgumentString:(NSString*)argument;

- (XVimEvaluatorContext*)appendArgument:(NSString*)argument;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) XVimEvaluatorContext *copy;

@end
