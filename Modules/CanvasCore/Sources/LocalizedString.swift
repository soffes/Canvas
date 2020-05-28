import Foundation

public enum LocalizedString {

	// Login
	case loginPlaceholder
	case passwordPlaceholder
	case logInButton

	// Organizations
	case organizationsTitle
	case personalNotes
	case accountButton
	case logOutButton

	// Canvases
	case searchIn(organizationName: String)
	case searchCommand
	case inPersonalNotes
	case newCanvasCommand
	case archiveSelectedCanvasCommand
	case deleteSelectedCanvasCommand
	case archiveButton
	case unarchiveButton
	case deleteButton
	case cancelButton
	case deleteConfirmationMessage(canvasTitle: String)
	case archiveConfirmationMessage(canvasTitle: String)
	case unsupportedTitle
	case unsupportedMessage
	case checkForUpdatesButton
	case openInSafariButton
	case todayTitle
	case recentTitle
	case thisWeekTitle
	case thisMonthTitle
	case olderTitle

	// Editor
	case canvasTitlePlaceholder
	case closeCommand
	case dismissKeyboardCommand
	case markAsCheckedCommand
	case markAsUncheckedCommand
	case indentCommand
	case outdentCommand
	case boldCommand
	case italicCommand
	case inlineCodeCommand
	case insertLineAfterCommand
	case insertLineBeforeCommand
	case deleteLineCommand
	case swapLineUpCommand
	case swapLineDownCommand
	case connecting
	case disconnected
	case editorError
	case editorConnectionLost
	case closeCanvas
	case shareButton
	case archiveCanvasTitle
	case archiveCanvasMessage
	case disablePublicEditsButton
	case enablePublicEditsButton
	case notFoundTitle
	case notFoundHeading
	case notFoundMessage

	// Shared
	case okay
	case cancel
	case retry
	case untitled
	case error

    // MARK: - Properties

	public var string: String {
		switch self {
		case .loginPlaceholder:
			return string("LOGIN_PLACEHOLDER")
		case .passwordPlaceholder:
			return string("PASSWORD_PLACEHOLDER")
		case .logInButton:
			return string("LOGIN_BUTTON")

		case .organizationsTitle:
			return string("ORGANIZATIONS_TITLE")
		case .personalNotes:
			return string("PERSONAL_NOTES")
		case .accountButton:
			return string("ACCOUNT_BUTTON")
		case .logOutButton:
			return string("LOG_OUT_BUTTON")

		case .searchIn(let organizationName):
			return String(format: string("SEARCH_IN_ORGANIZATION"), arguments: [organizationName])
		case .searchCommand:
			return string("SEARCH_COMMAND")
		case .inPersonalNotes:
			return string("IN_PERSONAL_NOTES")
		case .newCanvasCommand:
			return string("NEW_CANVAS_COMMAND")
		case .archiveSelectedCanvasCommand:
			return string("ARCHIVE_SELECTED_CANVAS_COMMAND")
		case .deleteSelectedCanvasCommand:
			return string("DELETE_SELECTED_CANVAS_COMMAND")
		case .archiveButton:
			return string("ARCHIVE_BUTTON")
		case .unarchiveButton:
			return string("UNARCHIVE_BUTTON")
		case .deleteButton:
			return string("DELETE_BUTTON")
		case .cancelButton:
			return string("CANCEL_BUTTON")
		case .deleteConfirmationMessage(let canvasTitle):
			return String(format: string("DELETE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .archiveConfirmationMessage(let canvasTitle):
			return String(format: string("ARCHIVE_CONFIRMATION_MESSAGE"), arguments: [canvasTitle])
		case .unsupportedTitle:
			return string("UNSUPPORTED_TITLE")
		case .unsupportedMessage:
			return string("UNSUPPORTED_MESSAGE")
		case .checkForUpdatesButton:
			return string("CHECK_FOR_UPDATES_BUTTON")
		case .openInSafariButton:
			return string("OPEN_IN_SAFARI_BUTTON")
		case .todayTitle:
			return string("TODAY_TITLE")
		case .recentTitle:
			return string("RECENT_TITLE")
		case .thisWeekTitle:
			return string("THIS_WEEK_TITLE")
		case .thisMonthTitle:
			return string("THIS_MONTH_TITLE")
		case .olderTitle:
			return string("OLDER_TITLE")

		case .canvasTitlePlaceholder:
			return string("CANVAS_TITLE_PLACEHOLDER")
		case .closeCommand:
			return string("CLOSE_COMMAND")
		case .dismissKeyboardCommand:
			return string("DISMISS_KEYBOARD_COMMAND")
		case .markAsCheckedCommand:
			return string("MARK_AS_CHECKED_COMMAND")
		case .markAsUncheckedCommand:
			return string("MARK_AS_UNCHECKED_COMMAND")
		case .indentCommand:
			return string("INDENT_COMMAND")
		case .outdentCommand:
			return string("OUTDENT_COMMAND")
		case .boldCommand:
			return string("BOLD_COMMAND")
		case .italicCommand:
			return string("ITALIC_COMMAND")
		case .inlineCodeCommand:
			return string("INLINE_CODE_COMMAND")
		case .insertLineAfterCommand:
			return string("INSERT_LINE_AFTER_COMMAND")
		case .insertLineBeforeCommand:
			return string("INSERT_LINE_BEFORE_COMMAND")
		case .deleteLineCommand:
			return string("DELETE_LINE_COMMAND")
		case .swapLineUpCommand:
			return string("SWAP_LINE_UP_COMMAND")
		case .swapLineDownCommand:
			return string("SWAP_LINE_DOWN_COMMAND")
		case .connecting:
			return string("CONNECTING")
		case .disconnected:
			return string("DISCONNECTED")
		case .editorError:
			return string("EDITOR_ERROR")
		case .editorConnectionLost:
			return string("EDITOR_CONNECTION_LOST")
		case .closeCanvas:
			return string("CLOSE_CANVAS")
		case .shareButton:
			return string("SHARE_BUTTON")
		case .archiveCanvasTitle:
			return string("ARCHIVE_CANVAS_TITLE")
		case .archiveCanvasMessage:
			return string("ARCHIVE_CANVAS_MESSAGE")
		case .disablePublicEditsButton:
			return string("DISABLE_PUBLIC_EDITS_BUTTON")
		case .enablePublicEditsButton:
			return string("ENABLE_PUBLIC_EDITS_BUTTON")
		case .notFoundTitle:
			return string("NOT_FOUND")
		case .notFoundHeading:
			return string("NOT_FOUND_HEADING")
		case .notFoundMessage:
			return string("NOT_FOUND_MESSAGE")

		case .okay:
			return string("OK")
		case .cancel:
			return string("CANCEL")
		case .retry:
			return string("RETRY")
		case .untitled:
			return string("UNTITLED")
		case .error:
			return string("ERROR")
		}
	}

    // MARK: - Private

	private func string(_ key: String) -> String {
		return NSLocalizedString(key, tableName: nil, bundle: resourceBundle, value: "", comment: "")
	}
}
