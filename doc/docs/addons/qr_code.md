# QR Code

QR Code generation either with the included `QRCodeRect` node or use the encoding result of the `QRCode` class.

## Compatibility

| Godot | Version  |
|-------|----------|
| 4.3   | >= 1.1.0 |
| 4.2   | >= 1.1.0 |
| 4.1   | <= 1.0.0 |

## Screenshot

![QRCodeRect node inspector screenshot](qr_code/qr_code.png "QRCodeRect in inspector")

## Example

<!-- kny:source /examples/qr_code/ -->

## Interface

## QRCodeRect

<!-- kny:badge extends TextureRect -->

<!-- kny:source /addons/qr_code/qr_code_rect.gd res://addons/qr_code/qr_code_rect.gd -->

`TextureRect` like node. The texture is updated by itself.
When using byte encoding you can also pass strings for specific ECI values (ISO 8859-1, Shift JIS, UTF-8, UTF-16, US ASCII), the input string will be automatically converted to an byte array.

#### Properties

| Name                | Type                                             | Description                                                                                                                                                                                                              |
|---------------------|--------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| mode                | [QRCode.Mode](#qrcodemode)                       | QR Code mode                                                                                                                                                                                                             |
| error_correction    | [QRCode.ErrorCorrection](#qrcodeerrorcorrection) | Error correction value.                                                                                                                                                                                                  |
| use_eci             | String                                           | Use Extended Channel Interpretation (ECI)                                                                                                                                                                                |
| eci_value           | String                                           | Extended Channel Interpretation (ECI) Value                                                                                                                                                                              |
| data                | Variant                                          | Type varies based on the encoding mode.                                                                                                                                                                                  |
| auto_version        | bool                                             | Use automatically the smallest QR Code version.                                                                                                                                                                          |
| version             | int                                              | QR Code version (size).                                                                                                                                                                                                  |
| auto_mask_pattern   | bool                                             | Use automatically the best mask pattern.                                                                                                                                                                                 |
| mask_pattern        | int                                              | QR Code mask pattern.                                                                                                                                                                                                    |
| light_module_color  | Color                                            | Color of the light modules.                                                                                                                                                                                              |
| dark_module_color   | Color                                            | Color of the dark modules.                                                                                                                                                                                               |
| auto_module_px_size | bool                                             | Automatically set the module pixel size based on the size. Do not use expand mode `KEEP_SIZE` when using it.<br>Turn this off when the QR Code changes or is resized often, as it impacts the performance quite heavily. |
| module_px_size      | int                                              | Use that many pixel for one module.                                                                                                                                                                                      |
| quiet_zone_size     | int                                              | Use that many modules for the quiet zone. A value of 4 is recommended.                                                                                                                                                   |

### QRCode

<!-- kny:badge extends RefCounted -->

<!-- kny:source /addons/qr_code/qr_code.gd res://addons/qr_code/qr_code.gd -->

QRCode class to generate QR Codes.

#### Properties

| Name              | Type                                             | Description                                     |
|-------------------|--------------------------------------------------|-------------------------------------------------|
| mode              | [QRCode.Mode](#qrcodemode)                       | QR Code mode.                                   |
| error_correction  | [QRCode.ErrorCorrection](#qrcodeerrorcorrection) | Error correction value.                         |
| use_eci           | String                                           | Use Extended Channel Interpretation (ECI)       |
| eci_value         | String                                           | Extended Channel Interpretation (ECI) Value     |
| auto_version      | bool                                             | Use automatically the smallest QR Code version. |
| version           | int                                              | QR Code version (size).                         |
| auto_mask_pattern | bool                                             | Use automatically the best mask pattern.        |
| mask_pattern      | int                                              | QR Code mask pattern.                           |

#### Methods

`get_module_count() -> int`
:     Return the module count per side.

`calc_min_version() -> int`
:     Return the minimal version required to encode the data.

`generate_image(module_px_size: int = 1, light_module_color: Color = Color.WHITE, dark_module_color: Color = Color.BLACK) -> Image`
:     Generate an image. This method can be called repeatedly, as encoding will only happens once and be cached.

`put_numeric(number: String) -> void`
:     Put a numeric text. Invalid characters are removed. Will change the encoding mode to `Mode.NUMERIC`.

`put_alphanumeric(text: String) -> void`
:     Put a alphanumeric text. Invalid characters are removed. Will change the encoding mode to `Mode.ALPHANUMERIC`.

`put_byte(data: PackedByteArray) -> void`
:     Put a bytes. Will change the encoding mode to `Mode.BYTE`.

`put_kanji(data: String) -> void`
:     Put a kanji text. Invalid characters are removed. Will change the encoding mode to `Mode.KANJI`.

`encode() -> PackedByteArray`
:     Get the QR Code row by row in one array. To get the row size use `get_module_count`.

### QRCode.Mode

<!-- kny:source /addons/qr_code/qr_code.gd res://addons/qr_code/qr_code.gd -->

Encoding mode enum.

| Name         | Value |
|--------------|-------|
| NUMERIC      | 1     |
| ALPHANUMERIC | 2     |
| BYTE         | 4     |
| KANJI        | 8     |

### QRCode.ErrorCorrection

<!-- kny:source /addons/qr_code/qr_code.gd res://addons/qr_code/qr_code.gd -->

Error correction enum.

| Name     | Value |
|----------|-------|
| LOW      | 1     |
| MEDIUM   | 0     |
| QUARTILE | 3     |
| HIGH     | 2     |

### QRCode.ECI

<!-- kny:source /addons/qr_code/qr_code.gd res://addons/qr_code/qr_code.gd -->

ECI values. See source code for available values.

### ShiftJIS

<!-- kny:source /addons/qr_code/shift_jis.gd res://addons/qr_code/shift_jis.gd -->

Shift JIS encoding utility.

## Methods

`static func to_shift_jis_2004_buffer(text: String) -> PackedByteArray`
:     Convert text to Shift JIS 2004 encoded bytes. Returns u16 int array. Unknown characters are skipped.

`static func get_string_from_shift_jis_2004(arr: PackedByteArray) -> String`
:     Get text from Shift JIS 2004 encoded bytes. Requires an u16 int array. Unknown characters are skipped.

`static func to_jis_8_buffer(text: String) -> PackedByteArray`
:     Convert text to JIS 8 encoded bytes. Returns u8 int array. Unknown characters are skipped.

`static func get_string_from_jis_8(arr: PackedByteArray) -> String`
:     Get text from JIS 8 encoded bytes. Requires an u8 int array. Unknown characters are skipped.

## Changelog

### 1.1.3

- Code improvements

### 1.1.2

- Use absolute paths in preloads

### 1.1.1

- Code optimizing

### 1.1.0

- Require Godot 4.2
- Add more values to plugin.cfg
- Add static typing in for loops

### 1.0.0

- Renamed `get_string_from_jis_2004` to `get_string_from_shift_jis_2004`

### 0.3.1

- Improve inspector properties
- Improve input handling of byte data based on ECI usage

### 0.3.0

- Make ECI value optional

### 0.2.0

- Added quiet zone size property
