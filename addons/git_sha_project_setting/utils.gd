const GIT_SHA_PATH: String = "application/config/git_sha"

static func init_project_setting(key: String, default_value: Variant, type: int, type_hint: int) -> void:
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set_setting(key, default_value)
    ProjectSettings.set_initial_value(key, default_value)
    ProjectSettings.add_property_info({
        "name": key,
        "type": type,
        "hint": type_hint,
    })

class GitResult:
    extends RefCounted

    var git_sha: String
    var err_msg: String

    func _init(git_sha_: String, err_msg_: String) -> void:
        self.git_sha = git_sha_
        self.err_msg = err_msg_

static func update_git_sha() -> bool:
    var res: GitResult = get_git_sha()
    if res.err_msg != "":
        push_error(res.err_msg)
        return false
    if res.git_sha == "":
        ProjectSettings.set_setting(GIT_SHA_PATH, null)
    else:
        ProjectSettings.set_setting(GIT_SHA_PATH, res.git_sha)
    return true

static func get_git_sha() -> GitResult:
    # no git is ok
    if not FileAccess.file_exists("res://.git/HEAD"):
        return GitResult.new("", "")
    var file: FileAccess = FileAccess.open("res://.git/HEAD", FileAccess.READ)
    if file == null:
        return GitResult.new("", "could not open git HEAD file (" + String.num_int64(FileAccess.get_open_error()) + ")")
    var text: String = file.get_as_text().strip_edges()
    file = null

    var rx_sha: RegEx = RegEx.new()
    rx_sha.compile('^[0-9a-f]{5,40}$')
    var git_sha: RegExMatch = rx_sha.search(text)
    if git_sha != null:
        return GitResult.new(git_sha.get_string(0), "")

    var rx: RegEx = RegEx.new()
    rx.compile('^ref:\\s(.*)$')
    var git_head: RegExMatch = rx.search(text)
    if git_head == null:
        return GitResult.new("", "could not parse git head file")
    file = FileAccess.open("res://.git/" + git_head.get_string(1), FileAccess.READ)
    if file == null:
        return GitResult.new("", "could not open git reference file (" + String.num_int64(FileAccess.get_open_error()) + ")")

    var sha: String = file.get_as_text().strip_edges()
    file = null
    if sha == "":
        return GitResult.new("", "git sha was empty")
    return GitResult.new(sha, "")
