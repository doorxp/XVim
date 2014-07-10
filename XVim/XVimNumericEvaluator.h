//
//  XVimNumericEvaluator.h
//  XVim
//
//  Created by Tomas Lundell on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XVimEvaluator.h"

// This evaluator is waiting for number input.
@interface XVimNumericEvaluator : XVimEvaluator
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL numericMode;
@end
