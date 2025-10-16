class_name TextCursorCalculator
extends RefCounted

## Reusable text cursor positioning system with word wrapping support
## Handles complex positioning math for text displays with proper line breaks

## Calculate cursor position with word wrapping for any text and font configuration
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
	var words = text.split(" ")
	var chars_processed = 0

	for word_idx in range(words.size()):
		var word = words[word_idx]
		var word_width = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var space_width = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

		# Check if we need a new line for this word
		if current_x + word_width > max_width and current_x > 0:
			current_line += 1
			current_x = 0.0

		# Check if cursor is within this word
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

	# Get available width for text wrapping
	var text_width = text_display.size.x

	# Debug logging
	print("[TextCursorCalculator] RichTextLabel size: %s" % text_display.size)
	print("[TextCursorCalculator] Text width for wrapping: %.2f px" % text_width)
	print("[TextCursorCalculator] Font size: %d" % font_size)
	print("[TextCursorCalculator] Cursor position: %d / %d" % [cursor_position, display_text.length()])

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
static func get_line_count_with_wrapping(
	text: String,
	font: Font,
	font_size: int,
	max_width: float
) -> int:

	var line_count = 1  # Start with at least one line
	var words = text.split(" ")
	var current_x = 0.0

	for word in words:
		var word_width = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var space_width = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

		# Check if we need a new line for this word
		if current_x + word_width > max_width and current_x > 0:
			line_count += 1
			current_x = word_width + space_width
		else:
			current_x += word_width + space_width

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
