//
//  BaseTextStorage.h
//  CanvasText
//
//  Created by Sam Soffes on 6/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE
	@import UIKit;
#else
	@import AppKit;
#endif

/// Concrete text storage intended to be subclassed.
@interface BaseTextStorage : NSTextStorage
@end
