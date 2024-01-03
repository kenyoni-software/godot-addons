extends Node

@export_node_path("OptionButton") var _logger_options_path; @onready var _logger_options: OptionButton = self.get_node(_logger_options_path)
@export_node_path("OptionButton") var _log_level_options_path; @onready var _log_level_options: OptionButton = self.get_node(_log_level_options_path)
@export_node_path("OptionButton") var _log_at_level_options_path; @onready var _log_at_level_options: OptionButton = self.get_node(_log_at_level_options_path)
@export_node_path("LineEdit") var _log_text_path; @onready var _log_text: LineEdit = self.get_node(_log_text_path)

var _logger: Array[GLogging.Logger] = [GLogging.root_logger]

func _ready() -> void:
    GLogging.info("ready and initialize GUI")
    self._logger.append(GLogging.root_logger.create_child("network"))
    self._logger.append(GLogging.root_logger.create_child("gui", GLogging.LEVEL_WARNING))
    for logger: GLogging.Logger in self._logger:
        self._logger_options.add_item(logger.name)
    self._log_level_options.select(GLogging.root_logger.log_level() / 10)
    GLogging.info("initialized logger %s %s", ["root", "and other"])

func _on_log_pressed() -> void:
    self._logger[self._logger_options.selected].log(self._log_at_level_options.get_item_id(self._log_at_level_options.selected), self._log_text.text)

func _on_log_level_item_selected(index: int) -> void:
    self._logger[self._logger_options.selected].set_log_level(self._log_level_options.get_item_id(index))

func _on_logger_item_selected(index: int) -> void:
    self._log_level_options.select(self._logger[index].log_level() / 10)
