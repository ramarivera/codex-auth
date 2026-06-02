pub const ApiMode = enum {
    default,
    force_api,
    skip_api,
};

pub const ListOptions = struct {
    live: bool = false,
    api_mode: ApiMode = .default,
    active_only: bool = false,
};
pub const LoginOptions = struct {
    device_auth: bool = false,
};
pub const ImportSource = enum { standard, cpa };
pub const ImportOptions = struct {
    auth_path: ?[]u8,
    alias: ?[]u8,
    purge: bool,
    source: ImportSource,
};
pub const ExportFormat = enum { standard, cpa };
pub const ExportOptions = struct {
    dest_path: ?[]u8,
    format: ExportFormat,
};
pub const SwitchTarget = union(enum) {
    picker,
    query: []u8,
    previous,
};
pub const SwitchOptions = struct {
    target: SwitchTarget = .picker,
    live: bool = false,
    api_mode: ApiMode = .default,
};
pub const RemoveOptions = struct {
    selectors: [][]const u8,
    all: bool,
    live: bool = false,
    api_mode: ApiMode = .default,
};
pub const AliasSetOptions = struct {
    selector: []u8,
    alias: []u8,
};
pub const AliasClearOptions = struct {
    selector: []u8,
};
pub const AliasOptions = union(enum) {
    set: AliasSetOptions,
    clear: AliasClearOptions,
};
pub const CleanTarget = enum { accounts, background };
pub const CleanOptions = struct {
    target: CleanTarget = .accounts,
};
pub const LiveOptions = struct {
    interval_seconds: u16,
};
pub const AutoAction = enum { enable, disable };
pub const AutoThresholdOptions = struct {
    threshold_5h_percent: ?u8,
    threshold_weekly_percent: ?u8,
};
pub const AutoOptions = union(enum) {
    action: AutoAction,
    configure: AutoThresholdOptions,
};
pub const ConfigOptions = union(enum) { auto_switch: AutoOptions, live: LiveOptions };
pub const AppAction = enum { launch };
pub const AppPlatform = enum { win, wsl, mac };
pub const AppOptions = struct {
    action: AppAction,
    app_id: ?[]const u8 = null,
    codex_cli_path: ?[]const u8 = null,
    codex_home: ?[]const u8 = null,
    platform: ?AppPlatform = null,
    inherit_stdio: bool = false,
};
pub const DaemonMode = enum { watch, once };
pub const DaemonOptions = struct { mode: DaemonMode };
pub const HelpTopic = enum {
    top_level,
    list,
    status,
    login,
    import_auth,
    export_auth,
    switch_account,
    remove_account,
    alias,
    clean,
    config,
    daemon,
    app,
};

pub const Command = union(enum) {
    list: ListOptions,
    login: LoginOptions,
    import_auth: ImportOptions,
    export_auth: ExportOptions,
    switch_account: SwitchOptions,
    remove_account: RemoveOptions,
    alias: AliasOptions,
    clean: CleanOptions,
    config: ConfigOptions,
    app: AppOptions,
    status: void,
    daemon: DaemonOptions,
    version: void,
    help: HelpTopic,
};

pub const UsageError = struct {
    topic: HelpTopic,
    message: []u8,
};

pub const ParseResult = union(enum) {
    command: Command,
    usage_error: UsageError,
};
