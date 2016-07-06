//
//  Globals.swift
//  CanvasCore
//
//  Created by Sam Soffes on 12/17/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum LocalizedString {
	
	// Login
	case LoginPlaceholder
	case PasswordPlaceholder
	case LogInButton

	// Organizations
	case OrganizationsTitle
	case PersonalNotes
	case AccountButton
	case LogOutButton

	// Canvases
	case SearchIn(organizationName: String)
	case SearchCommand
	case InPersonalNotes
	case NewCanvasCommand
	case ArchiveSelectedCanvasCommand
	case DeleteSelectedCanvasCommand
	case ArchiveButton
	case UnarchiveButton
	case DeleteButton
	case CancelButton
	case DeleteConfirmationMessage(canvasTitle: String)
	case ArchiveConfirmationMessage(canvasTitle: String)
	case UnsupportedTitle
	case UnsupportedMessage
	case CheckForUpdatesButton
	case OpenInSafariButton
	case TodayTitle
	case RecentTitle
	case ThisWeekTitle
	case ThisMonthTitle
	case OlderTitle

	// Editor
	case CanvasTitlePlaceholder
	case CloseCommand
	case DismissKeyboardCommand
	case MarkAsCheckedCommand
	case MarkAsUncheckedCommand
	case IndentCommand
	case OutdentCommand
	case BoldCommand
	case ItalicCommand
	case InlineCodeCommand
	case InsertLineAfterCommand
	case InsertLineBeforeCommand
	case DeleteLineCommand
	case SwapLineUpCommand
	case SwapLineDownCommand
	case Connecting
	case Disconnected
	case EditorError
	case EditorConnectionLost
	case CloseCanvas
	case ShareButton
	case ArchiveCanvasTitle
	case ArchiveCanvasMessage
	case DisablePublicEditsButton
	case EnablePublicEditsButton
	case NotFoundTitle
	case NotFoundHeading
	case NotFoundMessage

	// Shared
	case Okay
	case Cancel
	case Retry
	case Untitled
	case Error


	// MARK: - Properties

	public var string: String {
		switch self {
		case .LoginPlaceholder: return string("LOGIN_PLACEHOLDER")
		case .PasswordPlaceholder: return string("PASSWORD_PLACEHOLDER")
		case .LogInButton: return string("LOGIN_BUTTON")

		case .OrganizationsTitle: return string("ORGANIZATIONS_TITLE")
		case .PersonalNotes: return string("PERSONAL_NOTES")
		case .AccountButton: return string("ACCOUNT_BUTTON")
		case .LogOutButton: return string("LOG_OUT_BUTTON")

		case .SearchIn(let organizationName): return String(format: string("SEARCH_IN_ORGANIZATION"), arguments: [organizationName])
		case .SearchCommand: return string("SEARCH_COMMAND")
		case .InPersonalNotes: return string("IN_PERSONAL_NOTES")
		case .NewCanvasCommand: return string("NEW_CANVAS_COMMAND")
		case .ArchiveSelectedCanvasCommand: return string("ARCHIVE_SELECTED_CANVAS_COMMAND")
		case .DeleteSelectedCanvasCommand: return string("DELETE_SELECTED_CANVAS_COMMAND")
		case .ArchiveButton: return string("ARCHIVE_BUTTON")
		case .UnarchiveButton: return string("UNARCHIVE_BUTTON")
		case .DeleteButton: return string("DELETE_BUTTON")
		case .CancelButton: return string("CANCEL_BUTTON")
		case .DeleteConfirmationMessage(let canvasTitle): return String(format: string("DELETE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .ArchiveConfirmationMessage(let canvasTitle): return String(format: string("ARCHIVE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .UnsupportedTitle: return string("UNSUPPORTED_TITLE")
		case .UnsupportedMessage: return string("UNSUPPORTED_MESSAGE")
		case .CheckForUpdatesButton: return string("CHECK_FOR_UPDATES_BUTTON")
		case .OpenInSafariButton: return string("OPEN_IN_SAFARI_BUTTON")
		case .TodayTitle: return string("TODAY_TITLE")
		case .RecentTitle: return string("RECENT_TITLE")
		case .ThisWeekTitle: return string("THIS_WEEK_TITLE")
		case .ThisMonthTitle: return string("THIS_MONTH_TITLE")
		case .OlderTitle: return string("OLDER_TITLE")

		case .CanvasTitlePlaceholder: return string("CANVAS_TITLE_PLACEHOLDER")
		case .CloseCommand: return string("CLOSE_COMMAND")
		case .DismissKeyboardCommand: return string("DISMISS_KEYBOARD_COMMAND")
		case .MarkAsCheckedCommand: return string("MARK_AS_CHECKED_COMMAND")
		case .MarkAsUncheckedCommand: return string("MARK_AS_UNCHECKED_COMMAND")
		case .IndentCommand: return string("INDENT_COMMAND")
		case .OutdentCommand: return string("OUTDENT_COMMAND")
		case .BoldCommand: return string("BOLD_COMMAND")
		case .ItalicCommand: return string("ITALIC_COMMAND")
		case .InlineCodeCommand: return string("INLINE_CODE_COMMAND")
		case .InsertLineAfterCommand: return string("INSERT_LINE_AFTER_COMMAND")
		case .InsertLineBeforeCommand: return string("INSERT_LINE_BEFORE_COMMAND")
		case .DeleteLineCommand: return string("DELETE_LINE_COMMAND")
		case .SwapLineUpCommand: return string("SWAP_LINE_UP_COMMAND")
		case .SwapLineDownCommand: return string("SWAP_LINE_DOWN_COMMAND")
		case .Connecting: return string("CONNECTING")
		case .Disconnected: return string("DISCONNECTED")
		case .EditorError: return string("EDITOR_ERROR")
		case .EditorConnectionLost: return string("EDITOR_CONNECTION_LOST")
		case .CloseCanvas: return string("CLOSE_CANVAS")
		case .ShareButton: return string("SHARE_BUTTON")
		case .ArchiveCanvasTitle: return string("ARCHIVE_CANVAS_TITLE")
		case .ArchiveCanvasMessage: return string("ARCHIVE_CANVAS_MESSAGE")
		case .DisablePublicEditsButton: return string("DISABLE_PUBLIC_EDITS_BUTTON")
		case .EnablePublicEditsButton: return string("ENABLE_PUBLIC_EDITS_BUTTON")
		case .NotFoundTitle: return string("NOT_FOUND")
		case .NotFoundHeading: return string("NOT_FOUND_HEADING")
		case .NotFoundMessage: return string("NOT_FOUND_MESSAGE")

		case .Okay: return string("OK")
		case .Cancel: return string("CANCEL")
		case .Retry: return string("RETRY")
		case .Untitled: return string("UNTITLED")
		case .Error: return string("ERROR")
		}
	}


	// MARK: - Private

	private func string(key: String) -> String {
		return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
	}
}
