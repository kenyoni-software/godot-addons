# App Settings

Download: [**Godot Asset Store**](https://store.godotengine.org/asset/kenyoni/app-settings) | [**GitHub**](https://github.com/kenyoni-software/godot-addons/releases)

A flexible settings management system with support for staged values, readonly mode, validation, and per-frame batched signals.

- **Staged or immediate settings** with optional custom apply logic
- **Hierarchical keys** for organized grouping of settings and easy section queries.  
- **ConfigFile integration** for saving and loading settings.  
- **Signal-driven updates** to respond to changes in settings efficiently.  
- **Utilities** for filtering, section extraction, and internal setting management.

It is built around three core classes: a `Registry` that owns and organizes `Setting` objects by hierarchical keys and an `AppSettings` node that wraps the registry and adds convenient per-frame batched signals for change detection. Settings support staged mode (queue changes before committing them all at once), readonly mode, custom validation and apply callbacks, and metadata. Configuration can be serialized to and loaded from Godot's built-in `ConfigFile` format, making save/load workflows straightforward.

The best is to create an autoload `AppSettings` or `GameSettings` that extends the provided `AppSettings` node. This allows you to easily access your settings from anywhere in your code and ensures that the per-frame signals are emitted correctly.

[AppSettings](#appsettings): App settings manager class  
[Registry](#registry): App settings manager class.  
[Setting](#setting): Class representing an individual setting.

A short incomplete overview:

```python
# create an autoload extending AppSettings
AppSettings.add_setting(Setting.new(&"graphics/fullscreen", false)
    .set_description("Enable fullscreen mode").
    .set_apply_fn(func(s): DisplayServer.window_set_mode(...))
    .set_validate_fn(func(_s, v): return v is bool)
)
# [...] more settings

# load & apply on startup
AppSettings.from_config(config)
AppSettings.apply_all()

# staged mode: queue changes until user confirms
AppSettings.get_setting(&"audio/volume").set_staged(true)
AppSettings.set_value(&"audio/volume", 0.8)
# or discard_staged_values()
AppSettings.apply_staged_values()

# save
AppSettings.to_config().save("user://settings.cfg")
```

## Compatibility

| Godot | Version |
| ----- | ------- |
| 4.7   | all     |
| 4.6   | all     |
| 4.5   | all     |
| 4.4   | all     |

## Example

{{ kny:source "/examples/app_settings/" }}

For this example to work you have to create an autoload named `GameSettings` with the script `res://addons/app_settings/game_settings.gd`.

## Interface

### AppSettings

{{ kny:badge extends Node --left-bg }}

{{ kny:source "/addons/kenyoni/app_settings/registry_node.gd" "res://addons/kenyoni/app_settings/app_settings.gd" }}

Node that wraps a `Registry` and adds per-frame batched signals.

#### Signals

| Name {: .kny-mono-font }                    | Description                                                                                                                                                 |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| settings_applied {: .kny-mono-font }        | Emitted once per frame when one or more settings were applied during that frame. Inspect `get_changed_applied_settings()` for the affected keys.            |
| settings_changed {: .kny-mono-font }        | Emitted once per frame when one or more effective setting values changed during that frame. Inspect `get_changed_settings()` for the affected keys.         |
| settings_staged_changed {: .kny-mono-font } | Emitted once per frame when one or more staged values were set or cleared during that frame. Inspect `get_changed_staged_settings()` for the affected keys. |
| applied {: .kny-mono-font }                 | Emitted immediately after a setting is applied. `key` is the key of the applied setting.                                                                    |
| changed {: .kny-mono-font }                 | Emitted immediately when a setting's effective value changes. `key` is the key of the changed setting.                                                      |
| staged_changed {: .kny-mono-font }          | Emitted immediately when a staged value is set or cleared. `key` is the key of the affected setting.                                                        |

#### Methods

void add_setting(setting: [Setting](#setting)) {: .kny-mono-font }
:     Add a new setting. The setting's key must be unique.

void apply_all() {: .kny-mono-font }
:     Call `apply()` on every registered setting unconditionally.

void apply_staged_values() {: .kny-mono-font }
:     Call `apply()` only on settings that have a pending staged value.

void discard_staged_values() {: .kny-mono-font }
:     Discard all pending staged values across every registered setting.

void from_config(config: {{ kny:godot ConfigFile }}) {: .kny-mono-font }
:     Load values from `config` into matching settings. See `Registry.from_config()` for full details.

{{ kny:godot PackedStringArray }} get_changed_applied_settings() const {: .kny-mono-font }
:     Return the keys of settings that were applied at least once since the previous `_process()` call. The array is cleared after each frame, so it only contains settings applied during the current frame.

{{ kny:godot PackedStringArray }} get_changed_settings() const {: .kny-mono-font }
:     Return the keys of settings whose effective values changed at least once since the previous `_process()` call. The array is cleared after each frame, so it only contains settings changed during the current frame.

{{ kny:godot PackedStringArray }} get_changed_staged_settings() const {: .kny-mono-font }
:     Return the keys of settings whose staged values were set or cleared at least once since the previous `_process()` call. The array is cleared after each frame, so it only contains settings changed during the current frame.

{{ kny:godot Array }}[[Setting](#setting)] get_section(section: {{ kny:godot String }}, depth: {{ kny:godot int }} = -1, filter: {{ kny:godot Callable }} = Registry._exclude_internal) const {: .kny-mono-font }
:     Return all `Setting` objects whose keys begin with `section`. `depth` limits the number of `/`-separated levels below `section` that are included; `-1` means unlimited. `filter` defaults to `Registry._exclude_internal`. See `Registry.get_section()` for full details.

{{ kny:godot PackedStringArray }} get_section_keys(section: {{ kny:godot String }}, depth: {{ kny:godot int }} = -1, filter: {{ kny:godot Callable }} = Registry._exclude_internal) const {: .kny-mono-font }
:     Return the keys of all settings whose keys begin with `section`. `depth` limits the number of `/`-separated levels below `section` that are included; `-1` means unlimited. `filter` defaults to `Registry._exclude_internal`. See `Registry.get_section_keys()` for full details.

[Setting](#setting) get_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Return the `Setting` for `key`, or `null` if it does not exist.

{{ kny:godot PackedStringArray }} get_sub_sections(parent_section: {{ kny:godot String }} = "", filter: {{ kny:godot Callable }} = Registry._exclude_internal) const {: .kny-mono-font }
:     Return the names of the immediate child sections under `parent_section`. The names order is not guaranteed to be stable. Pass an empty string to get the top-level section names. `filter` defaults to `Registry._exclude_internal`. See `Registry.get_sub_sections()` for full details.

{{ kny:godot Variant }} get_value(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Return the effective value of the setting identified by `key`. See `Setting.value()` for details on how values are determined.

{{ kny:godot bool }} has_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Return `true` if a setting with `key` exists.

{{ kny:godot bool }} has_staged_values() const {: .kny-mono-font }
:     Return `true` if at least one registered setting has a pending staged value.

void remove_setting(key: {{ kny:godot StringName }}) {: .kny-mono-font }
:     Remove the setting identified by `key`. Does nothing if the key does not exist.

void set_value(key: {{ kny:godot StringName }}, value: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Set the value of the setting identified by `key`. See `Setting.set_value()` for details on how values are assigned and validated.

{{ kny:godot ConfigFile }} to_config(filter: {{ kny:godot Callable }} = Registry._include_exported) const {: .kny-mono-font }
:     Serialize settings to a `ConfigFile` and return it. `filter` controls which settings are included; defaults to exported settings only. See `Registry.to_config()` for full details.

### Registry

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/kenyoni/app_settings/registry.gd" "res://addons/kenyoni/app_settings/registry.gd" }}

Container that owns and manages a collection of `Setting` objects.

#### Signals

| Name {: .kny-mono-font }                                            | Description                                                                                                                                                 |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| applied(key: {{ kny:godot StringName }}) {: .kny-mono-font }        | Emitted immediately after a setting's `apply()` completes. `key` is the key of the applied setting.                                                         |
| changed(key: {{ kny:godot StringName }}) {: .kny-mono-font }        | Emitted when a setting's effective value changes, either by direct assignment or when a staged value is committed. `key` is the key of the changed setting. |
| staged_changed(key: {{ kny:godot StringName }}) {: .kny-mono-font } | Emitted when a setting's staged value is set or cleared. `key` is the key of the affected setting.                                                          |

#### Methods

void add_setting(setting: [Setting](#setting)) {: .kny-mono-font }
:     Register `setting` with this registry and set its internal registry reference to `self`. Fails with a push_error if the key ends with `/` or contains `//`, if the setting already belongs to a different registry or if a setting with the same key already exists.

void apply_all() {: .kny-mono-font }
:     Call `apply()` on every registered setting unconditionally.

void apply_staged_values() {: .kny-mono-font }
:     Call `apply()` only on settings that have a pending staged value.

void discard_staged_values() {: .kny-mono-font }
:     Discard all pending staged values. `staged_changed` is emitted for each setting that had a staged value.

void from_config(config: {{ kny:godot ConfigFile }}) {: .kny-mono-font }
:     Load values from `config` into matching settings. For each `section`/`key` pair, the setting key is constructed as `"section/key"`. Only settings that exist, are exported, and are not readonly are updated. Unknown keys emit a warning.

{{ kny:godot Array }}[[Setting](#setting)] get_section(section: {{ kny:godot String }}, depth: {{ kny:godot int }} = -1, filter: {{ kny:godot Callable }} = _exclude_internal) const {: .kny-mono-font }
:     Return all `Setting` objects whose keys begin with `section`. Pass an empty string to match all settings. `depth` limits how many additional `/`-separated levels below `section` are included; `-1` means unlimited. `filter` returns only settings for which it returns `true`.

{{ kny:godot PackedStringArray }} get_section_keys(section: {{ kny:godot String }}, depth: {{ kny:godot int }} = -1, filter: {{ kny:godot Callable }} = _exclude_internal) const {: .kny-mono-font }
:     Return the keys of all settings whose keys begin with `section`. Pass an empty string to match all settings. `depth` limits how many additional `/`-separated levels below `section` are included; `-1` means unlimited.

[Setting](#setting) get_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Return the `Setting` for `key`, or `null` if no such setting exists.

{{ kny:godot PackedStringArray }} get_sub_sections(parent_section: {{ kny:godot String }} = "", filter: {{ kny:godot Callable }} = _exclude_internal) const {: .kny-mono-font }
:     Return the names of the immediate child sections under `parent_section`. The names order is not guaranteed to be stable. A child section name is the single path component that follows `parent_section` in a matching key. For example, given a key `"graphics/display/vsync"` and `parent_section = "graphics"`, this returns `["display"]`. Pass an empty string for `parent_section` to get the top-level section names. `filter` is a `Callable` with signature `func(setting: Setting) -> bool`.

{{ kny:godot Variant }} get_value(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Return the current effective value of the setting identified by `key`. Emits a warning and returns `null` if `key` does not exist.

{{ kny:godot bool }} has_setting(key: {{ kny:godot StringName }}) const {: .kny-mono-font }
:     Return `true` if a setting with `key` exists in this registry.

{{ kny:godot bool }} has_staged_values() const {: .kny-mono-font }
:     Return `true` if at least one registered setting has a pending staged value.

void remove_setting(key: {{ kny:godot StringName }}) {: .kny-mono-font }
:     Remove the setting identified by `key`. Does nothing if the key does not exist.

void set_value(key: {{ kny:godot StringName }}, value: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Set the value of the setting identified by `key`. Emits a warning if `key` does not exist. Staged mode, readonly mode, and validation all apply.

{{ kny:godot ConfigFile }} to_config(filter: {{ kny:godot Callable }} = _include_exported) const {: .kny-mono-font }
:     Serialize settings to a `ConfigFile`. Each setting's key is split on the last `/`: the left part becomes the section, the right part becomes the config key. Settings without a `/` are placed in the empty-string section. `filter` is a `Callable` with signature `func(setting: Setting) -> bool` that controls which settings are included. Defaults to `_include_exported`.

{{ kny:godot bool }} _exclude_internal(setting: [Setting](#setting)) static {: .kny-mono-font }
:     Return `true` for non-internal settings.

{{ kny:godot bool }} _include_exported(setting: [Setting](#setting)) static {: .kny-mono-font }
:     Return `true` for exported settings.

### Setting

{{ kny:badge extends RefCounted --left-bg }}

{{ kny:source "/addons/kenyoni/app_settings/setting.gd" "res://addons/kenyoni/app_settings/setting.gd" }}

A single configurable value identified by a hierarchical key. Each setting holds a current effective value, a default value, optional validation and apply callables, and metadata. Settings are owned by a `Registry`, which must be assigned before `apply()` is called.

**Staged mode** — when enabled, `set_value()` stores a pending value rather than applying it immediately. The pending value becomes the effective value only when `apply()` is called.

**Readonly mode** — when enabled, all writes via `set_value()` and `reset()` are silently ignored.

#### Methods

[Setting](#setting) add_meta(meta_key: {{ kny:godot StringName }}, val: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Store an arbitrary metadata value under `meta_key`. Fluent wrapper around `Object.set_meta()`. Returns `self` for method chaining.

void apply() {: .kny-mono-font }
:     Commit the current state and trigger side-effects. If a staged value is pending, it replaces the effective value, `staged_changed` is emitted, and `changed` is emitted if the value differed. Regardless of staged state, the apply callable is invoked(if set) and `applied` is emitted.

{{ kny:godot Variant }} default_value() const {: .kny-mono-font }
:     Return the default value supplied at construction time.

{{ kny:godot String }} description() const {: .kny-mono-font }
:     Return the description string, or an empty string if none is set.

void discard_staged_value() {: .kny-mono-font }
:     Discard any pending staged value. Emits `staged_changed` on the registry if a value was actually cleared.

{{ kny:godot bool }} has_staged_value() const {: .kny-mono-font }
:     Return `true` when a staged value is pending and has not yet been applied.

{{ kny:godot bool }} is_exported() const {: .kny-mono-font }
:     Return `true` when the setting is exported to config files. `true` by default.

{{ kny:godot bool }} is_internal() const {: .kny-mono-font }
:     Return `true` when the setting is marked as internal.

{{ kny:godot bool }} is_readonly() const {: .kny-mono-font }
:     Return `true` when the setting is readonly.

{{ kny:godot bool }} is_staged_mode() const {: .kny-mono-font }
:     Return `true` when staged mode is active.

{{ kny:godot StringName }} key() const {: .kny-mono-font }
:     Return the hierarchical key that uniquely identifies this setting.

void reset() {: .kny-mono-font }
:     Reset the setting to its default value. Has no effect when readonly.

[Setting](#setting) set_apply_fn(fn: {{ kny:godot Callable }}) {: .kny-mono-font }
:     Set the apply callable. Signature: `func(setting: Setting) -> void`. Returns `self` for method chaining.

[Setting](#setting) set_description(text: {{ kny:godot String }}) {: .kny-mono-font }
:     Set a human-readable description string. Returns `self` for method chaining.

[Setting](#setting) set_exported(exported: {{ kny:godot bool }} = true) {: .kny-mono-font }
:     Set whether the setting should be exported when generating configuration files. Returns `self` for method chaining.

[Setting](#setting) set_internal(internal: {{ kny:godot bool }} = true) {: .kny-mono-font }
:     Mark or unmark the setting as internal. Internal settings should be excluded from auto-generated UIs. Returns `self` for method chaining.

[Setting](#setting) set_readonly(readonly: {{ kny:godot bool }} = true) {: .kny-mono-font }
:     Enable or disable readonly mode. While readonly, `set_value()` and `reset()` are silently ignored. Returns `self` for method chaining.

[Setting](#setting) set_staged(staged: {{ kny:godot bool }} = true) {: .kny-mono-font }
:     Enable or disable staged mode. When `staged` is `false`, any pending staged value is discarded. Returns `self` for method chaining.

[Setting](#setting) set_validate_fn(fn: {{ kny:godot Callable }}) {: .kny-mono-font }
:     Set the validate callable. Signature: `func(setting: Setting, value: Variant) -> bool`. Returns `self` for method chaining.

void set_value(new_value: {{ kny:godot Variant }}) {: .kny-mono-font }
:     Assign `new_value` after passing it through the validator. Ignored if readonly. If `new_value` equals the current effective value and a staged value is pending, the staged value is cleared. In staged mode, stores `new_value` as pending and emits `staged_changed`. In normal mode, sets the value immediately, emits `changed`, and calls `apply()`.

{{ kny:godot Variant }} staged_or_value() const {: .kny-mono-font }
:     Return the staged value if one is pending, otherwise return the current effective value.

{{ kny:godot Variant }} staged_value() const {: .kny-mono-font }
:     Return the pending staged value, or `null` if none exists. Use `has_staged_value()` to distinguish a stored `null` from the absence of a staged value.

{{ kny:godot bool }} validate(value: {{ kny:godot Variant }}) const {: .kny-mono-font }
:     Return true if the value is valid according to the validate callable or if no validate callable is set.

{{ kny:godot Variant }} value() const {: .kny-mono-font }
:     Return the current effective value. Does not reflect any pending staged value.

## Changelog

### 1.0.1

- Fix `apply_staged_values()` not working due to a typo in the staged value check.

### 1.0.0

- Initial release for Godot 4.4
