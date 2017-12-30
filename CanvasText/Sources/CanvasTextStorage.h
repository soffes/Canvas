//
//  CanvasTextStorage.h
//  CanvasText
//
//  Created by Sam Soffes on 6/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#import "BaseTextStorage.h"

@protocol CanvasTextStorageDelegate;

@interface CanvasTextStorage : BaseTextStorage

@property (nonatomic, weak) _Nullable id<CanvasTextStorageDelegate> canvasDelegate;
@property (nonatomic) BOOL isEditing;

- (void)actuallyReplaceCharactersInRange:(NSRange)range withString:(nonnull NSString *)aString;

@end


@protocol CanvasTextStorageDelegate <NSObject>

- (void)canvasTextStorage:(nonnull CanvasTextStorage *)textStorage willReplaceCharactersInRange:(NSRange)range withString:(nonnull NSString *) string;

@end
