local config = require "arasaka.config"
local M = {}

local palette = {
  red = '#ff2250',
  cyan = '#00eaff',
  green = '#00ffaa',
  yellow = '#ffdd00',
	orange = '#ff8829',
  purple = '#a84afe',
  pink = '#ff00ff',
	brown = '#504945',
  black = '#000000',
  base1 = '#101010',
  base2 = '#202020',
  base3 = '#303030',
  base4 = '#404040',
  base5 = '#505050',
  base6 = '#606060',
  base7 = '#707070',
  base8 = '#808080',
  base9 = '#909090',
  baseA = '#AAAAAA',
  baseB = '#BBBBBB',
  baseC = '#CCCCCC',
  baseD = '#DDDDDD',
  baseE = '#EEEEEE',
  white = '#F0F0F0',
	diff_add = '#004422',
  diff_delete = '#4a0f23',
  diff_change = '#151515',
  diff_text = '#23324d',
  outline = '#353535',
}

M.base = {

	-----------------------------------------
	--  Editor settings
	-----------------------------------------

	--  PMENU
	Pmenu 			= { fg = palette.white, bg = palette.black }, -- completion window border color and background color
	PmenuSel 		= { fg = palette.black, bg = palette.red },
	PmenuSelBold = { fg = palette.black, bg = palette.red, },
	PmenuSbar 	= { bg = palette.base4 },
	PmenuThumb	= { fg = palette.red, bg = palette.black },

	-- CURSOR
	Cursor 				= { fg = palette.black, bg = palette.red },
	CursorLine 		= { bg = palette.black },
	CursorLineNr 	= { fg = palette.red, bg = palette.black, style = "bold" },
	CursorColumn 	= { fg = "NONE",  bg = "NONE" },
	lCursor				= { fg = palette.black, bg = palette.red },
	TermCursor		= { fg = palette.black, bg = palette.red },
	TermCursorNC	= { fg = palette.black, bg = palette.red },
	CursorIM      = { fg = palette.black, bg = palette.red },

	-- FLOAT WINDOW
	NormalFloat	= { fg = palette.white, bg = palette.black }, -- floating window
	FloatBorder	= { fg = palette.outline, bg = "NONE" },

	-- STATUS LINE
	StatusLine         = { fg = palette.black, bg = palette.red },
	StatusLineNC       = { fg = palette.black, bg = palette.red },
	StatusLineTerm     = { fg = palette.black, bg = palette.red },
	StatusLineTermNC   = { fg = palette.black, bg = palette.red },
	StatusLineSeparator= { fg = palette.black },

	-- MODES
	Normal             = { fg = palette.white, bg = palette.black, },
	NormalNC           = { fg = palette.white, bg = palette.black, },
	Visual             = { bg = palette.base2 },
	VisualNOS          = { bg = palette.base2 },

	-- DIFF
	DiffAdd            = { bg = palette.diff_add },
	DiffChange         = { bg = palette.diff_change },
	DiffDelete         = { fg = palette.base2, bg = palette.black },
	DiffAdded          = { fg = palette.green },
	DiffRemoved        = { fg = palette.red },
	DiffText           = { bg = palette.diff_change },
	DiffFile           = { fg = palette.diff_text },

	Folded             = { fg = palette.white, bg = palette.base2 },
	VertSplit          = { fg = palette.outline, bg = palette.black },
	LineNr             = { fg = palette.base4, bg = palette.black, style = "bold" },         -- number column
	FoldColumn         = { fg = palette.white, bg = palette.black },
	SignColumn         = { fg = palette.white,  bg = palette.black },
	ColorColumn        = { bg = palette.black },
	Conceal            = { fg = palette.base8 },-- { bg = config.transparent_background and "NONE" or palette.black },
	QuickFixLine       = { fg = palette.purple, style = 'bold' },
	Repeat             = { fg = palette.pink },
	Whitespace         = { fg = palette.base4 },
	WildMenu           = { fg = palette.white, bg = palette.black },
	WarningMsg         = { fg = palette.yellow, bg = palette.black, style = 'bold' },
	Search             = { fg = palette.black, bg = palette.red },
	IncSearch          = { fg = palette.black, bg = palette.red },
	CurSearch          = { fg = palette.black, bg = palette.red },
	Delimiter          = { fg = palette.white },


	Underline          = { style = "underline" },
	Label              = { fg = palette.white },-- underline Highlighted defination
	MatchParen         = { fg = palette.pink },
	MatchParenCur      = { style = "underline" },
	MatchWord          = { style = "underline" },
	MatchWordCur       = { style = "underline" },
	MoreMsg            = { fg = palette.white },
	ModeMsg            = { fg = palette.white, bg = palette.black },
	MsgArea            = { fg = palette.white, bg = palette.black, },
	MsgSeparator       = { fg = palette.white, bg = palette.black },

	Error              = { fg = palette.red, bg = palette.black, style = "bold" },
	ErrorMsg           = { fg = palette.red, bg = palette.black, style = "bold" },-- command error message
	Debug              = { fg = palette.orange },

	--Substitute         = { fg=colors.SubstituteFG, bg=colors.SubstituteBG },

	-----------------------------------------
	-- LANGUAGE SYNTAX
	-----------------------------------------
	Boolean            = { fg = palette.purple },
	Character          = { fg = palette.yellow },
	Comment            = { fg = palette.base4 , style = "NONE" },
	Conditional        = { fg = palette.red },
	Constant           = { fg = palette.cyan },
	Define             = { fg = palette.red },
	Exception          = { fg = palette.red },
	Float              = { fg = palette.purple },
	Identifier         = { fg = palette.white },
	--Ignore             = { },
	Macro              = { fg = palette.red },
	NonText            = { fg = palette.base8 },
	Number             = { fg = palette.purple },
	Operator           = { fg = palette.red },
	PreCondit          = { fg = palette.red },
	PreProc            = { fg = palette.green },
	Question           = { fg = palette.yellow },
	Special            = { fg = palette.white },
	SpecialChar        = { fg = palette.red },
	SpecialComment     = { fg = palette.base8 },
	SpecialKey         = { fg = palette.red },
	SpellBad           = { fg = palette.pink,   style = "underline" },
	SpellCap           = { fg = palette.purple,   style = "underline" },
	SpellLocal         = { fg = palette.red, style = "underline" },
	SpellRare          = { fg = palette.cyan,  style = "underline" },
	Statement          = { fg = palette.red },
	StorageClass       = { fg = palette.cyan },
	String             = { fg = palette.yellow },
	Structure          = { fg = palette.cyan },
	--TabLine            = { },
	--TabLineFill        = { },
	TabLineSel         = { bg = palette.base4 },
	Tag                = { fg = palette.cyan },
	Title              = { fg = palette.yellow, style = "bold" },
	Todo               = { fg = palette.orange },
	Type               = { fg = palette.cyan },
	Typedef            = { fg = palette.cyan },
	Variable           = { fg = palette.white },
	--URI                = { fg = colors.URI,        style="underline" },
	Parameter          = { fg = palette.white },
	Keyword            = { fg = palette.red },
	Include            = { fg = palette.red },
	Function           = { fg = palette.green },
	KeywordFunction    = { fg = palette.red, style="NONE" },
	KeywordReturn      = { fg = palette.red },
	KeywordOperator    = { fg = palette.red },
	Method             = { fg = palette.green },
	Constructor        = { fg = palette.cyan },
	FuncBuiltin        = { fg = palette.cyan },
	--Warning            = { fg = palette.red },
	--Note               = { fg = colors.Note },
	TagAttribute       = { fg = palette.green },
	Annotation         = { fg = palette.green },
	Attribute          = { fg = palette.green },
	ConstBuiltin       = { fg = palette.purple },
	ConstMacro         = { fg = palette.purple },
	Field              = { fg = palette.white },
	FuncMacro          = { fg = palette.green },
	--Literal            = { fg = colors.Literal },
	Namespace          = { fg = palette.purple },
	Property           = { fg = palette.white },
	PunctBracket       = { fg = palette.white },
	--TableBlock         = { fg = colors.TableBlock },
	PunctDelimiter     = { fg = palette.white },
	PunctSpecial       = { fg = palette.red },
	StringEscape       = { fg = palette.purple },
	StringRegex        = { fg = palette.purple },
	--Strong             = { fg = colors.Strong },
	--Symbol             = { fg = colors.Symbol },
	TagDelimiter       = { fg = palette.white },
	Text               = { fg = palette.white },
	--QueryLinterError   = { fg = colors.QueryLinterError },
	--TypeBuiltin        = { fg = colors.TypeBuiltin },
	VariableBuiltin    = { fg = palette.orange },
	ParameterReference = { fg = palette.white },
	Emphasis           = { style = "italic" },
}

M.plugins = {

	-----------------------------------------
	-- PLUGINS
	-----------------------------------------
  --
  -- BUFFERLINE
  OffsetTitle = { fg = palette.white, bg = palette.black, style = 'bold' },
	-- CMP: github.com/hrsh7th/nvim-cmp
	-----------------------------------------
	CmpDocumentation       = { fg = palette.white, bg = palette.black },
	CmpDocumentationBorder = { fg = palette.outline, bg = palette.black },
	CmpItemAbbr            = { fg = palette.white },
	CmpItemAbbrDeprecated  = { fg = palette.base8 },
	CmpItemAbbrMatch       = { fg = palette.green },
	CmpItemAbbrMatchFuzzy  = { fg = palette.green },
	CmpItemMenu            = { fg = palette.base8 },
	CmpItemKindClass = { fg = palette.orange },
	CmpItemKindDefault = { fg = palette.white },
	CmpItemKindEnum = { fg = palette.orange },
	CmpItemKindEnumMember = { fg = palette.green },
	CmpItemKindEvent = { fg = palette.orange },
	CmpItemKindField = { fg = palette.green },
	CmpItemKindFunction = { fg = palette.cyan },
	CmpItemKindInterface = { fg = palette.orange },
	CmpItemKindKeyword = { fg = palette.red },
	CmpItemKindMethod = { fg = palette.cyan },
	CmpItemKindModule = { fg = palette.yellow },
	CmpItemKindOperator = { fg = palette.green },
	CmpItemKindProperty = { fg = palette.green },
	CmpItemKindStruct = { fg = palette.orange },
	CmpItemKindText = { fg = palette.white },
	CmpItemKindTypeParameter = { fg = palette.green },
	CmpItemKindUnit = { fg = palette.orange },
	CmpItemKindVariable = { fg = palette.red },

	-- DIFFVIEW: github.com/sindrets/diffview.nvim
	-----------------------------------------
	DiffViewNormal             = { fg = palette.white },
	DiffviewFilePanelDeletion  = { fg = palette.red },
	DiffviewFilePanelInsertion = { fg = palette.green },
	DiffviewStatusAdded        = { fg = palette.green },
	DiffviewStatusDeleted      = { fg = palette.red },
	DiffviewStatusModified     = { fg = palette.yellow },
	DiffviewStatusRenamed      = { fg = palette.yellow },

	-- INDENT-BLANKLINE: github.com/lukas-reineke/indent-blankline.nvim
	-----------------------------------------
	IndentBlanklineChar        = { fg = palette.base2 },
	IndentBlanklineContextChar = { fg = palette.base4 },
	IndentBlanklineSpaceChar   = { fg = palette.red },
	IndentBlanklineIndent1     = { fg = palette.base2 },
	IndentBlanklineIndent2     = { fg = palette.base2 },
	IndentBlanklineIndent3     = { fg = palette.base2 },
	IndentBlanklineIndent4     = { fg = palette.base2 },
	IndentBlanklineIndent5     = { fg = palette.base2 },
	IndentBlanklineIndent6     = { fg = palette.base2 },
	IndentBlanklineIndent7     = { fg = palette.base2 },
	IndentBlanklineIndent8     = { fg = palette.base2 },

	-- Lsp: neovim.io/doc/user/lsp.html
	-----------------------------------------
	DiagnosticError           = { fg = palette.red },
	DiagnosticFloatingError   = { fg = palette.red },
	DiagnosticFloatingHint    = { fg = palette.cyan },
	DiagnosticFloatingInfo    = { fg = palette.white },
	DiagnosticFloatingWarn    = { fg = palette.yellow },
	DiagnosticHint            = { fg = palette.cyan },
	DiagnosticInfo            = { fg = palette.white },
	DiagnosticSignError       = { fg = palette.red, bg = palette.black },
	DiagnosticSignHint        = { fg = palette.cyan, bg = palette.black },
	DiagnosticSignInfo        = { fg = palette.white, bg = palette.black },
	DiagnosticSignWarn        = { fg = palette.yellow, bg = palette.black },
	DiagnosticUnderlineError  = { style="underline" },
	DiagnosticUnderlineHint   = { style="underline" },
	DiagnosticUnderlineInfo   = { style="underline" },
	DiagnosticUnderlineWarn   = { style="underline" },
	DiagnosticVirtualTextError= { fg = palette.red },
	DiagnosticVirtualTextHint = { fg = palette.cyan },
	DiagnosticVirtualTextInfo = { fg = palette.white },
	DiagnosticVirtualTextWarn = { fg = palette.yellow },
	DiagnosticWarn            = { fg = palette.yellow },

	-- NVIM-TREE: github.com/kyazdani42/nvim-tree.lua
	-----------------------------------------
	NvimTreeNormal       = { fg = palette.white, bg = palette.black },
	NvimTreeCursorLine   = { fg = palette.red, bg = palette.black },
	NvimTreeVertSplit    = { fg = palette.red, bg = palette.black },
	NvimTreeIndentMarker = { fg = palette.base2 },

	-- FILE
	NvimTreeExecFile     = { fg = palette.white },
	NvimTreeOpenedFile   = { fg = palette.red },
	NvimTreeImageFile    = { fg = palette.white },
	NvimTreeSpecialFile  = { fg = palette.white },
	NvimTreeSymlink      = { fg = palette.white },
  NvimTreeFileIcon     = { fg = palette.base8 },

	-- FOLDER
	NvimTreeFolderIcon   = { fg = palette.red },
	NvimTreeFolderName   = { fg = palette.white },
  NvimTreeEmptyFolderName   = { fg = palette.white },
	NvimTreeOpenedFolderName = { fg = palette.white },
	NvimTreeRootFolder   = { fg = palette.white, style = "bold" },

	-- LSP DIAGNOSTICS
	NvimTreeLspDiagnosticsError = { fg = palette.red },
	NvimTreeLspDiagnosticsWarning = { fg = palette.orange },
	NvimTreeLspDiagnosticsInformation = { fg = palette.cyan },
	NvimTreeLspDiagnosticsHint = { fg = palette.yellow },

	-- GIT
	NvimTreeGitDeleted   = { fg = palette.red },
	NvimTreeGitDirty     = { fg = palette.green },
	NvimTreeGitMerge     = { fg = palette.cyan },
	NvimTreeGitNew       = { fg = palette.green },
	NvimTreeGitRenamed   = { fg = palette.cyan },
	NvimTreeGitStaged    = { fg = palette.green },
	NvimTreeGitIgnored    = { fg = palette.base4 },

	-- NvimTreeFileDirty = { fg = palette.white },
	-- NvimTreeFileStaged = { fg = palette.white },
	-- NvimTreeFileMerge = { fg = palette.white },
	-- NvimTreeFileRenamed = { fg = palette.white },
	-- NvimTreeFileNew = { fg = palette.white },
	-- NvimTreeFileDeleted = { fg = palette.white },
	-- NvimTreeFileIgnored = { fg = palette.white },

	--NvimTreeCursorColumn = { fg = palette.green, bg = palette.green },

	-- TREESITTER:  github.com/nvim-treesitter/nvim-treesitter
	-----------------------------------------
	TSTitle              = { fg = palette.yellow, style = "bold" },
	--TSURI                = { fg = colors.URI,        style="underline" },
	TSVariable           = { fg = palette.white },
	TSParameter          = { fg = palette.white },
	TSComment            = { fg = palette.base4, style="italic" },
	TSKeyword            = { fg = palette.red },
	TSType               = { fg = palette.cyan },
	TSError              = { fg = palette.red, style="bold" },
	TSInclude            = { fg = palette.red },
	TSString             = { fg = palette.yellow },
	TSFunction           = { fg = palette.green },
	TSKeywordFunction    = { fg = palette.red, style="NONE" },
	TSKeywordReturn      = { fg = palette.red },
	TSKeywordOperator    = { fg = palette.red },
	TSOperator           = { fg = palette.red },
	TSConditional        = { fg = palette.red },
	TSException          = { fg = palette.red },
	TSBoolean            = { fg = palette.purple },
	TSNumber             = { fg = palette.purple },
	TSMethod             = { fg = palette.green },
	TSConstructor        = { fg = palette.cyan },
	TSFuncBuiltin        = { fg = palette.cyan },
	--TSWarning            = { fg = colors.Warning },
	--TSNote               = { fg = colors.Note },
	TSTag                = { fg = palette.cyan },
	TSTagAttribute       = { fg = palette.green },
	TSAnnotation         = { fg = palette.green },
	TSAttribute          = { fg = palette.green },
	TSCharacter          = { fg = palette.yellow },
	TSConstBuiltin       = { fg = palette.purple },
	TSConstMacro         = { fg = palette.purple },
	TSConstant           = { fg = palette.cyan },
	TSField              = { fg = palette.white },
	TSFloat              = { fg = palette.purple },
	TSFuncMacro          = { fg = palette.green },
	TSLabel              = { fg = palette.white },
	--TSLiteral            = { fg = colors.Literal },
	TSNamespace          = { fg = palette.purple },
	TSProperty           = { fg = palette.white },
	TSPunctBracket       = { fg = palette.white },
	TSPunctDelimiter     = { fg = palette.white },
	TSPunctSpecial       = { fg = palette.red },
	TSRepeat             = { fg = palette.pink },
	TSStringEscape       = { fg = palette.purple },
	TSStringRegex        = { fg = palette.purple },
	--TSStrong             = { fg = colors.Strong },
	TSStructure          = { fg = palette.cyan },
	--TSSymbol             = { fg = colors.Symbol },
	TSTagDelimiter       = { fg = palette.white },
	TSText               = { fg = palette.white },
	--TSQueryLinterError   = { fg = colors.QueryLinterError },
	--TSTypeBuiltin        = { fg = colors.TypeBuiltin },
	TSVariableBuiltin    = { fg = palette.orange },
	TSParameterReference = { fg = palette.white },
	TSEmphasis           = { style = "italic" },
	TSUnderline          = { style = "underline" },
	
	DashboardHeader = { fg = palette.red },
	DashboardFooter = { fg = palette.base5 },
	DashboardProjectTitle = { fg = palette.red },
	DashboardProjectTitleIcon = { fg = palette.red },
	DashboardProjectIcon = { fg = palette.red },
	DashboardMruTitle = { fg = palette.red },
	DashboardMruIcon = { fg = palette.red },
	DashboardFiles = { fg = palette.white },
	DashboardShotCutIcon = { fg = palette.cyan },
	
	TelescopeBorder = { fg = palette.outline },
	TelescopeTitle = { fg = palette.red },
	TelescopePromptTitle = { fg = palette.red },
	TelescopeResultsTitle = { fg = palette.red },
	TelescopePreviewTitle = { fg = palette.red },
	TelescopePromptCounter = { fg = palette.base6 },
	TelescopePreviewPipe = { fg = palette.white }, 
   	TelescopePreviewCharDev = { fg = palette.white }, 
   	TelescopePreviewDirectory = { fg = palette.white }, 
   	TelescopePreviewBlock = { fg = palette.white }, 
   	TelescopePreviewLink = { fg = palette.white }, 
   	TelescopePreviewSocket = { fg = palette.white }, 
   	TelescopePreviewRead = { fg = palette.white }, 
   	TelescopePreviewWrite = { fg = palette.white }, 
   	TelescopePreviewExecute = { fg = palette.white }, 
   	TelescopePreviewHyphen = { fg = palette.white }, 
   	TelescopePreviewSticky = { fg = palette.white }, 
   	TelescopePreviewSize = { fg = palette.white }, 
   	TelescopePreviewUser = { fg = palette.white }, 
   	TelescopePreviewGroup = { fg = palette.white },
   	TelescopePreviewDate = { fg = palette.white }, 
	TelescopePreviewMessage = { fg = palette.white },
	TelescopePreviewMessageFillchar = { fg = palette.black },
	
	TelescopeResultsDiffChange = { fg = palette.yellow },
   	TelescopeResultsDiffAdd = { fg = palette.green },
   	TelescopeResultsDiffDelete = { fg = palette.red },
   	TelescopeResultsDiffUntracked = { fg = palette.white },
	
	
	TelescopeSelection = { fg = palette.red },
	TelescopeSelectionCaret = { fg = palette.red },
	TelescopeMultiSelection = { fg = palette.red },
	TelescopeMultiIcon = { fg = palette.red },
	TelescopeNormal = { fg = palette.white },
	TelescopePreviewNormal = { fg = palette.white },
	TelescopePromptNormal = { fg = palette.white },
	TelescopeResultsNormal = { fg = palette.white },
	TelescopeMatching = { fg = palette.green },

  offset_separator = { fg = palette.red, bg = palette.black },
}

return M
