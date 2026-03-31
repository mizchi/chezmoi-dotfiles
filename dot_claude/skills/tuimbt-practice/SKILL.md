---
name: tuimbt-practice
description: MoonBit TUI library practice guide for terminal UI apps, layouts, and reactive state.
---

# tui.mbt Practice Guide

MoonBit TUI library for building terminal user interfaces. Use when writing TUI applications with flexbox layouts, reactive state, and ANSI rendering.

## Package Structure

```
mizchi/tui/core       - Core types: Component, Color, BorderChars
mizchi/tui/components - UI components: button, input, tabs, etc.
mizchi/tui/render     - App, CharBuffer, ANSI output
mizchi/tui/events     - InputEvent, KeyEvent, MouseEvent
mizchi/tui/io         - Terminal I/O operations
mizchi/signals        - Reactive state management
```

## Basic App Structure

```moonbit
fn main {
  let (cols, rows) = @io.get_terminal_size()

  // Reactive state
  let count = @signals.signal(0)
  let running = @signals.signal(true)

  // Create app
  let app = @render.App::new(cols, rows)

  // Render function
  fn render_ui() -> @core.Component {
    @c.column([
      @c.text("Count: " + count.get().to_string()),
      @c.button("Click", id="btn"),
    ])
  }

  fn do_render() {
    @io.print_raw(app.render_frame(render_ui()))
  }

  fn do_quit() {
    running.set(false)
    @io.stop_keypress_listener()
    @io.cleanup_stdin()
    @io.print_raw(@render.App::restore_terminal())
  }

  // Event handler
  fn handle_key(key : String) {
    let event = @events.parse_input(key)
    if event.is_quit() {
      do_quit()
      return
    }
    // Handle input...
    do_render()
  }

  // Initialize
  @io.print_raw(@render.App::init_terminal())
  do_render()
  @io.start_keypress_listener(handle_key)
}
```

## Layout Components

### Container Layouts

```moonbit
// Vertical stack (column)
@c.column([child1, child2],
  gap=1.0,
  padding=1.0,
  border=Some(@core.BorderChars::rounded()))

// Horizontal stack (row)
@c.row([child1, child2],
  gap=2.0,
  justify=@c.align_center())

// Grid layout
@c.grid([items...],
  columns=3,
  column_gap=1.0,
  row_gap=1.0)

// Split panes
@c.hsplit(top_children, bottom_children, height,
  SplitSize::Percent(50.0), SplitSize::Percent(50.0))

@c.vsplit(left_children, right_children, width,
  SplitSize::Fixed(20.0), SplitSize::Flex(1.0))
```

### Sizing with Dimensions

```moonbit
// Fixed size
width=@c.dim_length(40.0)

// Percentage
width=@c.dim_percent(50.0)

// Auto (content-based)
width=@c.dim_auto()

// Flex grow/shrink
flex_grow=1.0
flex_shrink=0.0
```

## Common Components

### Text and Styling

```moonbit
@c.text("Hello", fg=@core.Color::cyan(), bold=true)
@c.bold("Bold text")
@c.colored("Colored", @core.Color::green())
```

### Buttons

```moonbit
@c.button("Click me",
  id="btn-action",
  state=@c.ButtonState::Normal,  // Normal, Hover, Focused, Disabled
  on_click=Some(fn() { ... }))
```

### Input Fields

```moonbit
@c.input(value,
  id="name-input",
  placeholder="Enter name",
  state=@c.InputState::Focused)  // Idle, Focused, Editing, Disabled

@c.textarea(value,
  id="description",
  rows=5,
  state=@c.TextareaState::Idle)
```

### Selection Components

```moonbit
// Checkbox
@c.checkbox(is_checked, id="check", focused=true)
@c.labeled_checkbox("Accept terms", is_checked)

// Switch
@c.switch(is_on, id="toggle")

// Radio group
let options = [
  RadioOption::{id: "a", label: "Option A"},
  RadioOption::{id: "b", label: "Option B"},
]
@c.radiogroup(options, selected_id, focused_id="a")

// Tabs
let tabs = [
  TabItem::{id: "tab1", label: "Tab 1"},
  TabItem::{id: "tab2", label: "Tab 2"},
]
@c.tabs(tabs, active_id, focused_id="tab1")
```

### Progress Indicators

```moonbit
@c.progress_bar(0.75, width, show_percent=true)
@c.spinner(tick)
@c.loading_dots(tick)
```

### Modals and Dialogs

```moonbit
@c.modal_with_backdrop(
  @c.column([content...]),
  width=@c.dim_length(40.0),
  border=Some(@core.BorderChars::rounded()))

@c.confirm_dialog("Are you sure?",
  confirm_label="Yes",
  cancel_label="No")
```

## Event Handling

### InputEvent Methods

```moonbit
let event = @events.parse_input(key)

// Keyboard checks
event.is_char('q')      // Specific character
event.is_ctrl('c')      // Ctrl+C
event.is_ctrl_c()       // Shorthand for Ctrl+C
event.is_escape()       // Escape key
event.is_enter()        // Enter key
event.is_tab()          // Tab
event.is_backtab()      // Shift+Tab
event.is_quit()         // q, Ctrl+C, or Escape

// Arrow keys
match event.is_arrow() {
  Some(@events.SpecialKey::Up) => scroll_up()
  Some(@events.SpecialKey::Down) => scroll_down()
  _ => ()
}

// Mouse events
match event.is_left_click() {
  Some(mouse) => handle_click(mouse.x, mouse.y)
  None => ()
}
event.is_scroll_up()
event.is_scroll_down()
```

### Mouse Click Dispatch

```moonbit
// Using Map
let handlers : Map[String, () -> Unit] = {
  "btn-plus": fn() { count.set(count.get() + 1) },
  "btn-minus": fn() { count.set(count.get() - 1) },
}

match event {
  @events.InputEvent::Mouse(mouse) =>
    match app.dispatch_click(mouse, handlers) {
      Some(id) => ()  // Handler was called
      None => ()      // No handler matched
    }
  _ => ()
}
```

## Focus Navigation

```moonbit
let focus = @c.FocusNav::new(["input1", "input2", "submit"])

// Handle Tab/Shift+Tab
if focus.handle_tab(event) {
  do_render()
  return
}

// Handle arrow keys
if focus.handle_arrows(event) {
  do_render()
  return
}

// Get state for rendering
let state = focus.input_state("input1")  // InputState based on focus
let btn_state = focus.button_state("submit")  // ButtonState based on focus
```

## Color System

```moonbit
// Named colors
@core.Color::red()
@core.Color::green()
@core.Color::blue()
@core.Color::cyan()
@core.Color::magenta()
@core.Color::yellow()
@core.Color::white()
@core.Color::black()
@core.Color::transparent()

// Custom RGB
@core.Color::rgb(100, 150, 200)
@core.Color::rgba(100, 150, 200, 0.5)
```

## Border Styles

```moonbit
@core.BorderChars::rounded()   // ╭╮╰╯─│
@core.BorderChars::single()    // ┌┐└┘─│
@core.BorderChars::double()    // ╔╗╚╝═║
@core.BorderChars::ascii()     // +-|
```

## Reactive State with Signals

```moonbit
// Create signal
let value = @signals.signal(0)

// Read value
let current = value.get()

// Update value
value.set(current + 1)

// Derived state in render function
fn render() -> @core.Component {
  let v = value.get()  // Reads current value
  @c.text(v.to_string())
}
```

## Scrolling

### ItemScroller (for item lists)

```moonbit
let scroller = @c.ItemScroller::new()

// Scroll control
scroller.up(1)
scroller.down(1, total_items, visible_height)
scroller.to_bottom(total_items, visible_height)

// Get visible slice
let visible = scroller.slice(items, visible_height)

// Show indicator
let indicator = scroller.indicator(total_items, visible_height)
```

### ScrollableView (for line-based content)

```moonbit
let view = @c.ScrollableView::new(width, visible_height)
view.set_lines(styled_lines)
view.up(1)
view.down(1)
view.follow_bottom()  // Auto-scroll to bottom
```

## Testing with HeadlessApp

```moonbit
test "button renders correctly" {
  let app = @c.HeadlessApp::new(width=40, height=10)
  let component = @c.button("Click", id="btn")
  let rendered = app.render(component)
  assert_true(rendered.content().contains("Click"))
}
```

## Best Practices

1. **Use `id` for interactive elements** - Required for click handling and focus
2. **Prefer methods over free functions** - `event.is_char('q')` not `is_char(event, 'q')`
3. **Use signals for reactive state** - Avoids manual re-render tracking
4. **Clean up on exit** - Call `cleanup_stdin()` and `restore_terminal()`
5. **Enable mouse if needed** - `@render.enable_mouse()` / `@render.disable_mouse()`

## Terminal Lifecycle

```moonbit
// Initialize
@io.print_raw(@render.App::init_terminal())  // Alt screen + hide cursor
@io.print_raw(@render.enable_mouse())        // Optional: enable mouse

// ... run app ...

// Cleanup
@io.print_raw(@render.disable_mouse())
@io.stop_keypress_listener()
@io.cleanup_stdin()
@io.print_raw(@render.App::restore_terminal())  // Restore screen + show cursor
```
