extends Node

const LEVEL_NOTSET: int = 0
const LEVEL_DEBUG: int = 10
const LEVEL_INFO: int = 20
const LEVEL_WARNING: int = 30
const LEVEL_ERROR: int = 40
const LEVEL_CRITICAL: int = 50

static func level_to_str(level: int) -> String:
    return Logger.level_to_str(level)

## Logger class with a fixed name and log level.
## Use level LEVEL_NOTSET to use log level of parent.
class Logger:
    extends RefCounted

    var name: String = "root"
    var _log_level: int = LEVEL_NOTSET
    var parent: Logger = null

    func _init(module_name: String, log_level: int = LEVEL_NOTSET, parent: Logger = null) -> void:
        self.name = module_name
        self.set_log_level(log_level)
        self.parent = parent

    func set_log_level(level: int) -> void:
        self._log_level = level

    func log_level() -> int:
        if self.parent != null and self._log_level == LEVEL_NOTSET:
            return self.parent.log_level()
        return self._log_level

    func create_child(module_name: String, log_level: int = LEVEL_NOTSET) -> Logger:
        return Logger.new(module_name, log_level, self)

    func debug(message: Variant, values: Array[Variant] = []) -> void:
        self.log(LEVEL_DEBUG, message, values)

    func info(message: Variant, values: Array[Variant] = []) -> void:
        self.log(LEVEL_INFO, message, values)

    func warning(message: Variant, values: Array[Variant] = []) -> void:
        self.log(LEVEL_WARNING, message, values)

    func error(message: Variant, values: Array[Variant] = []) -> void:
        self.log(LEVEL_ERROR, message, values)

    func critical(message: Variant, values: Array[Variant] = []) -> void:
        self.log(LEVEL_CRITICAL, message, values)

    func log(level: int, message: Variant, values: Array[Variant] = []) -> void:
        if self.log_level() <= level:
            self._log(level, self.name, message, values)

    static func level_to_str(level: int) -> String:
        if level <= 0:
            return "NOTSET"
        if level <= 10:
            return "DEBUG"
        if level <= 20:
            return "INFO"
        if level <= 30:
            return "WARNING"
        if level <= 40:
            return "ERROR"
        return "CRITICAL"

    func _log(level: int, module: String, message: Variant, values: Array[Variant] = []) -> void:
        var unix_time = Time.get_unix_time_from_system()
        var time: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
        time.merge(Time.get_time_dict_from_unix_time(unix_time))
        time["millisecond"] = int(str(unix_time).pad_decimals(3).split(".", true, 1)[1])
        var msg: String
        if values.is_empty():
            msg = "%04d-%02d-%02d %02d:%02d:%02d.%03d [%8s] [%10s] %s" % [time["year"], time["month"], time["day"], time["hour"], time["minute"], time["second"], time["millisecond"], level_to_str(level), module, message]
        else:
            msg = "%04d-%02d-%02d %02d:%02d:%02d.%03d [%8s] [%10s] %s" % [time["year"], time["month"], time["day"], time["hour"], time["minute"], time["second"], time["millisecond"],  level_to_str(level), module, message % values]
        print(msg)
        match level:
            LEVEL_CRITICAL, LEVEL_ERROR:
                push_error(msg)
            LEVEL_WARNING:
                push_warning(msg)

var root_logger: Logger = Logger.new("root", LEVEL_DEBUG)

func debug(message: Variant, values: Array[Variant] = []) -> void:
    self.root_logger.log(LEVEL_DEBUG, message, values)

func info(message: Variant, values: Array[Variant] = []) -> void:
    self.root_logger.log(LEVEL_INFO, message, values)

func warning(message: Variant, values: Array[Variant] = []) -> void:
    self.root_logger.log(LEVEL_WARNING, message, values)

func error(message: Variant, values: Array[Variant] = []) -> void:
    self.root_logger.log(LEVEL_ERROR, message, values)

func critical(message: Variant, values: Array[Variant] = []) -> void:
    self.root_logger.log(LEVEL_CRITICAL, message, values)

func log(level: int, module: String, message: Variant, values: Array[Variant] = []) -> void:
    if self.root_logger.log_level() <= level:
        self.root_logger._log(level, module, message, values)
