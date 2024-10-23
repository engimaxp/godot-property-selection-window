# Property Selection Window Plugin

A powerful Godot plugin that provides an intuitive interface for selecting and monitoring node properties in the Godot editor. This plugin enhances your workflow by making property management more efficient and user-friendly, with features like filtering, searching, and type-based filtering of properties.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [Advanced Features](#advanced-features)
- [Example Implementation](#example-implementation)
- [API Reference](#api-reference)
    - [Signals](#signals)
    - [Methods](#methods)
- [License](#license)
- [Contributing](#contributing)

## Features

- **Property Tree View**: Hierarchical display of all available node properties
- **Advanced Filtering**:
  - Search functionality with debounce for better performance
  - Type-based filtering (Boolean, Integer, Float, String, Vector2, Vector3, Color, Object)
  - Option to show/hide engine-managed properties
- **Smart Property Display**:
  - Automatic type detection and appropriate formatting
  - Property values preview
  - Circular reference detection and handling
- **Selection Management**:
  - Checkbox-based property selection
  - Bulk property selection/deselection
  - Persistence of selection state during filtering
- **User Interface**:
  - Clean, editor-styled interface
  - Responsive layout with proper column management
  - Icon support for different property types

## Installation

1. **Download the Plugin**:
   - Download the `PropertySelectionWindow` plugin from the Godot Asset Library or directly from the repository.

2. **Install the Plugin**:
   - Extract the downloaded files into your project's `res://addons/` directory.
   - Ensure the folder structure is as follows:
     ```
     res://addons/property_selection_window/
     ```

3. **Activate the Plugin**:
   - Open your Godot project
   - Go to **Project** > **Project Settings** > **Plugins**
   - Find `Property Selection Window` in the list and set it to **Active**

## Usage

### Basic Usage

1. **Create a Property Selection Window**:
```gdscript
var property_selector = PropertySelectionWindow.new()
property_selector.create_window(
    target_node,                # The node whose properties you want to select
    initially_selected,         # Array of previously selected properties (optional)
    show_hidden_properties,     # Whether to show engine-managed properties (optional)
    type_filter,               # Initial type filter (-1 for none) (optional)
    callback                    # Callback function for when properties are selected (optional)
)
```

2. **Handle Selected Properties**:
```gdscript
# Using a callback function
func _on_properties_selected(selected_properties: Array[String]):
    print("Selected properties:", selected_properties)

# Or connect to the signal
property_selector.properties_selected.connect(_on_properties_selected)
```

### Advanced Features

1. **Filtering Properties**:
```gdscript
# Set type filter programmatically
property_selector.set_type_filter(TYPE_FLOAT)  # Show only float properties

# Set search filter
property_selector.set_filter("position")  # Filter properties containing "position"

# Toggle hidden properties
property_selector.toggle_hidden_properties(true)  # Show all properties
```

2. **Tree Management**:
```gdscript
# Expand/Collapse all properties
property_selector.expand_all()
property_selector.collapse_all()

# Refresh the property tree
property_selector.refresh_tree()
```

3. **Property Access**:
```gdscript
# Check if a property exists
var exists = property_selector.property_exists("position")

# Get property type
var type = property_selector.get_property_type("position")

# Get/Set property value
var value = property_selector.get_property_value("position")
property_selector.set_property_value("position", Vector2(100, 100))
```

## Example Implementation

Here's an example of how the plugin is used in the [TimeRewind2D](https://github.com/imtani/godot-time-rewind-2d/) plugin:

```gdscript
func _open_property_selector_window(time_rewind: Node2D) -> void:
    if not is_instance_valid(time_rewind):
        push_error("TimeRewind2D: 'time_rewind' is not a valid instance.")
        return
    
    if not is_instance_valid(time_rewind.body):
        push_error("TimeRewind2D: Cannot open property selection window. Body is not valid.")
        return

    property_selector = PropertySelectionWindow.new()
    
    var rewindable_properties = time_rewind.get("rewindable_properties")
    if rewindable_properties == null:
        rewindable_properties = []

    property_selector.create_window(
        time_rewind.body,           # Target node
        rewindable_properties,      # Initially selected properties
        false,                      # Don't show hidden properties
        -1,                         # No type filter
        func(selected_properties: Array[String]):
            time_rewind.set("rewindable_properties", selected_properties)
    )
```

## API Reference

### Signals
- `properties_selected(selected_properties: Array[String])`: Emitted when properties are confirmed

### Methods
- `create_window(target: Node, initially_selected: Array = [], show_hidden: bool = false, type_filter: int = -1, callback: Callable = Callable())`: Creates and shows the property selection window
- `set_target(new_target: Node)`: Changes the target node
- `set_filter(filter_text: String)`: Sets the search filter
- `set_type_filter(filter: int)`: Sets the type filter
- `toggle_hidden_properties(show: bool)`: Shows/hides engine-managed properties
- `expand_all()`: Expands all tree items
- `collapse_all()`: Collapses all tree items
- `refresh_tree()`: Refreshes the property tree
- `get_all_properties() -> Array[String]`: Returns all available properties
- `property_exists(property_name: String) -> bool`: Checks if a property exists
- `get_property_type(property_name: String) -> int`: Returns the type of a property
- `get_property_value(property_name: String) -> Variant`: Gets the value of a property
- `set_property_value(property_name: String, value: Variant)`: Sets the value of a property

## License

This plugin is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute it as needed, keeping the original license intact.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests with improvements or bug fixes.