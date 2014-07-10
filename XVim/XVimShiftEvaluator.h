//
//  XVimShiftEvaluator.h
//  XVim
//
//  Created by Shuichiro Suzuki on 2/25/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "XVimOperatorEvaluator.h"
#import "XVimOperatorAction.h"



@interface XVimShiftEvaluator : XVimOperatorEvaluator
- (instancetype)initWithContext:(XVimEvaluatorContext*)context
	   operatorAction:(XVimOperatorAction*)action 
				  withParent:(XVimEvaluator*)parent
					 unshift:(BOOL)unshift NS_DESIGNATED_INITIALIZER;
@end

@interface XVimShiftAction : XVimOperatorAction
- (instancetype)initWithUnshift:(BOOL)unshift NS_DESIGNATED_INITIALIZER;
@end
