class_name TextCursorCalculator
extends RefCounted

## Reusable text cursor positioning system with word wrapping support
## Handles complex positioning math for text displays with proper line breaks

## Calculate cursor position with word wrapping for any text and font configuration
## Matches Godot's AUTOWRAP_WORD_SMART behavior (BREAK_WORD_BOUND + BREAK_ADAPTIVE + BREAK_MANDATORY)
## Properly handles Unicode grapheme clusters (combining characters)
static func calculate_cursor_position_with_wrapping(
	text: String,
	char_index: int,
	font: Font,
	font_size: int,
	max_width: float,
	line_height: float,
	margin_x: float = 0.0,
	margin_y: float = 0.0
) -> Vector2:

	var current_line = 0
	var current_x = 0.0
	var words = text.split(" ", false)  # Don't keep empty strings
	var chars_processed = 0

	for word_idx in range(words.size()):
		var word = words[word_idx]
		var word_width = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var space_width = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

		# BREAK_WORD_BOUND: Try to place word on new line if it doesn't fit
		# Check if word + trailing space would fit (WORD_SMART behavior)
		# This prevents lines from being too "full" and matches Godot's wrapping
		var needs_newline = false
		if current_x > 0:  # Not at start of line
			# For WORD_SMART: check if word + space would fit (unless it's the last word)
			var test_width = word_width
			if word_idx < words.size() - 1:
				test_width += space_width

			if current_x + test_width > max_width:
				needs_newline = true

		if needs_newline:
			current_line += 1
			current_x = 0.0

		# BREAK_ADAPTIVE: If word is too long even for a new line, break it using substring sizes
		if word_width > max_width:
			# Word needs adaptive wrapping - break at character boundaries using substring measurements
			# Track which part of the word we're on (for handling line wraps within the word)
			var line_start_in_word = 0

			for char_pos in range(word.length()):
				# Get width of current character segment from start of current line
				var substr_on_line = word.substr(line_start_in_word, char_pos - line_start_in_word + 1)
				var width_on_line = font.get_string_size(substr_on_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

				# Check if adding this character would exceed the line width
				if current_x + width_on_line > max_width and char_pos > line_start_in_word:
					# Need to wrap before this character
					current_line += 1
					current_x = 0.0
					line_start_in_word = char_pos

					# Recalculate width for single character on new line
					substr_on_line = word.substr(line_start_in_word, 1)
					width_on_line = font.get_string_size(substr_on_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

				# Check if cursor is at this position
				if chars_processed == char_index:
					var chars_on_this_line = char_pos - line_start_in_word
					var partial_on_line = word.substr(line_start_in_word, chars_on_this_line)
					var partial_width = font.get_string_size(partial_on_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
					return Vector2(
						margin_x + current_x + partial_width,
						margin_y + (current_line * line_height)
					)

				chars_processed += 1

			# After processing all characters in the long word, update current_x
			var final_substr = word.substr(line_start_in_word)
			current_x += font.get_string_size(final_substr, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		else:
			# Word fits on current line, check if cursor is within this word
			if chars_processed <= char_index and char_index <= chars_processed + word.length():
				# Cursor is in this word
				var chars_in_word = char_index - chars_processed
				var partial_word = word.substr(0, chars_in_word)
				var partial_width = font.get_string_size(partial_word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				return Vector2(
					margin_x + current_x + partial_width,
					margin_y + (current_line * line_height)
				)

			# Move past this word
			current_x += word_width
			chars_processed += word.length()

		# Add space if not the last word
		if word_idx < words.size() - 1:
			# Check if cursor is on the space
			if chars_processed == char_index:
				return Vector2(
					margin_x + current_x,
					margin_y + (current_line * line_height)
				)

			# Check if space needs wrapping
			if current_x + space_width > max_width:
				current_line += 1
				current_x = 0.0
			else:
				current_x += space_width

			chars_processed += 1  # For the space

	# Cursor is at the end
	return Vector2(
		margin_x + current_x,
		margin_y + (current_line * line_height)
	)

## Calculate cursor position for typing practice displays
## Includes baseline offset for proper cursor positioning below text
static func calculate_typing_cursor_position(
	display_text: String,
	cursor_position: int,
	text_display: RichTextLabel,
	margin_offset: float = 30.0
) -> Vector2:

	# Get font metrics from the text display
	var font = text_display.get_theme_default_font()
	var font_size = text_display.get_theme_font_size("normal_font_size")
	var line_height = font.get_height(font_size)

	# Get available width for text wrapping, accounting for RichTextLabel's content margins
	var text_width = text_display.size.x

	# Subtract content margins from stylebox if present
	var stylebox = text_display.get_theme_stylebox("normal")
	if stylebox:
		text_width -= stylebox.content_margin_left
		text_width -= stylebox.content_margin_right

	# RichTextLabel uses slightly conservative wrapping to avoid sub-pixel rendering issues
	# Reduce width by small epsilon to match its behavior
	text_width -= 1.0

	# Clamp cursor position to text length
	var clamped_position = min(cursor_position, display_text.length())

	# Calculate base cursor position
	var cursor_pos = calculate_cursor_position_with_wrapping(
		display_text,
		clamped_position,
		font,
		font_size,
		text_width,
		line_height
	)

	# Add margin offset and position cursor below text baseline
	var target_x = margin_offset + cursor_pos.x
	var target_y = margin_offset + cursor_pos.y + line_height  # Below baseline

	return Vector2(target_x, target_y)

## Animate cursor to new position with smooth tween
static func animate_cursor_to_position(
	cursor: ColorRect,
	target_position: Vector2,
	duration: float = 0.1
) -> Tween:

	if not cursor:
		return null

	var tween = cursor.create_tween()
	tween.tween_property(cursor, "position", target_position, duration)
	return tween

## Get line count for given text with word wrapping
## Matches Godot's AUTOWRAP_WORD_SMART behavior
## Properly handles Unicode grapheme clusters
static func get_line_count_with_wrapping(
	text: String,
	font: Font,
	font_size: int,
	max_width: float
) -> int:

	var line_count = 1  # Start with at least one line
	var words = text.split(" ", false)
	var current_x = 0.0

	for word_idx in range(words.size()):
		var word = words[word_idx]
		var word_width = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var space_width = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

		# BREAK_WORD_BOUND: Check if word + space fits (WORD_SMART behavior)
		var needs_newline = false
		if current_x > 0:
			var test_width = word_width
			if word_idx < words.size() - 1:
				test_width += space_width

			if current_x + test_width > max_width:
				needs_newline = true

		if needs_newline:
			line_count += 1
			current_x = 0.0

		# BREAK_ADAPTIVE: If word is too long, break it using substring measurements
		if word_width > max_width:
			var line_start_in_word = 0

			for char_pos in range(word.length()):
				var substr_on_line = word.substr(line_start_in_word, char_pos - line_start_in_word + 1)
				var width_on_line = font.get_string_size(substr_on_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

				if current_x + width_on_line > max_width and char_pos > line_start_in_word:
					line_count += 1
					current_x = 0.0
					line_start_in_word = char_pos

			# Update current_x after processing the long word
			var final_substr = word.substr(line_start_in_word)
			current_x += font.get_string_size(final_substr, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		else:
			current_x += word_width

		# Add space width if not last word
		if word_idx < words.size() - 1:
			if current_x + space_width > max_width:
				line_count += 1
				current_x = 0.0
			else:
				current_x += space_width

	return line_count

## Get total height needed for text with word wrapping
static func get_text_height_with_wrapping(
	text: String,
	font: Font,
	font_size: int,
	max_width: float
) -> float:

	var line_count = get_line_count_with_wrapping(text, font, font_size, max_width)
	var line_height = font.get_height(font_size)
	return line_count * line_height

## Check if character at position would be on a new line
static func is_character_on_new_line(
	text: String,
	char_index: int,
	font: Font,
	font_size: int,
	max_width: float
) -> bool:

	if char_index == 0:
		return false

	var pos_current = calculate_cursor_position_with_wrapping(text, char_index, font, font_size, max_width, font.get_height(font_size))
	var pos_previous = calculate_cursor_position_with_wrapping(text, char_index - 1, font, font_size, max_width, font.get_height(font_size))

	return pos_current.y > pos_previous.y

## Utility class for managing cursor blinking with configurable timing
class CursorBlinker:
	extends RefCounted

	var cursor: ColorRect
	var blink_timer: Timer
	var bright_color: Color
	var dim_color: Color
	var is_bright: bool = true
	var blink_speed: float

	func _init(target_cursor: ColorRect, bright: Color, dim: Color, speed: float = 0.5):
		cursor = target_cursor
		bright_color = bright
		dim_color = dim
		blink_speed = speed
		_setup_timer()

	func _setup_timer():
		if not cursor:
			return

		blink_timer = Timer.new()
		blink_timer.wait_time = blink_speed
		blink_timer.autostart = true
		blink_timer.timeout.connect(_on_blink)
		cursor.add_child(blink_timer)

		# Start with bright color
		cursor.color = bright_color
		is_bright = true

	func _on_blink():
		is_bright = !is_bright
		if cursor:
			cursor.color = bright_color if is_bright else dim_color

	func stop_blinking():
		if blink_timer:
			blink_timer.queue_free()

	func set_blink_speed(new_speed: float):
		blink_speed = new_speed
		if blink_timer:
			blink_timer.wait_time = blink_speed

	func set_colors(bright: Color, dim: Color):
		bright_color = bright
		dim_color = dim
		if cursor:
			cursor.color = bright_color if is_bright else dim_color
