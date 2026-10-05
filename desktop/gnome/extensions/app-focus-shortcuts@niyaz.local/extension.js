import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Meta from 'gi://Meta';
import Shell from 'gi://Shell';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as Util from 'resource:///org/gnome/shell/misc/util.js';

const JUST_PERFECTION_UUID = 'just-perfection-desktop@just-perfection';
const JUST_PERFECTION_SCHEMA = 'org.gnome.shell.extensions.just-perfection';

const SHORTCUTS = [
    {
        key: 'files-shortcut',
        appId: 'org.gnome.Nautilus.desktop',
        launchArgv: ['nautilus', '--new-window', GLib.build_filenamev([GLib.get_home_dir(), 'Projects'])],
    },
    {
        key: 'settings-shortcut',
        appId: 'org.gnome.Settings.desktop',
        launchArgv: ['gnome-control-center'],
    },
];

export default class AppFocusShortcuts extends Extension {
    enable() {
        this._settings = this.getSettings();
        this._dateMenu = Main.panel.statusArea.dateMenu.menu;
        this._revealedPanel = false;

        for (const shortcut of SHORTCUTS) {
            Main.wm.addKeybinding(
                shortcut.key,
                this._settings,
                Meta.KeyBindingFlags.NONE,
                Shell.ActionMode.NORMAL | Shell.ActionMode.OVERVIEW,
                () => this._focusOrLaunch(shortcut)
            );
        }

        Main.wm.addKeybinding(
            'notification-shortcut',
            this._settings,
            Meta.KeyBindingFlags.NONE,
            Shell.ActionMode.NORMAL | Shell.ActionMode.OVERVIEW | Shell.ActionMode.POPUP,
            () => this._toggleNotificationPanel()
        );

        this._menuStateId = this._dateMenu.connect('open-state-changed', (_menu, isOpen) => {
            if (!isOpen && this._revealedPanel) {
                this._revealedPanel = false;
                this._justPerfectionSettings()?.set_boolean('panel', false);
            }
        });
    }

    disable() {
        for (const shortcut of SHORTCUTS)
            Main.wm.removeKeybinding(shortcut.key);

        Main.wm.removeKeybinding('notification-shortcut');

        if (this._openIdleId) {
            GLib.source_remove(this._openIdleId);
            this._openIdleId = null;
        }

        this._dateMenu.disconnect(this._menuStateId);
        if (this._revealedPanel)
            this._justPerfectionSettings()?.set_boolean('panel', false);

        this._dateMenu = null;
        this._settings = null;
        this._jpSettings = null;
    }

    _focusOrLaunch(shortcut) {
        const app = Shell.AppSystem.get_default().lookup_app(shortcut.appId);
        const windows = app?.get_windows() ?? [];
        const window = windows.find(win => !win.skip_taskbar) ?? windows[0];

        if (window)
            Main.activateWindow(window);
        else
            Util.spawn(shortcut.launchArgv);
    }

    _toggleNotificationPanel() {
        if (this._openIdleId)
            return;

        if (this._dateMenu.isOpen) {
            this._dateMenu.close();
            return;
        }

        const jpSettings = this._justPerfectionSettings();
        if (jpSettings && !jpSettings.get_boolean('panel')) {
            this._revealedPanel = true;
            jpSettings.set_boolean('panel', true);
        }

        this._openIdleId = GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
            this._openIdleId = null;
            this._dateMenu.open();
            return GLib.SOURCE_REMOVE;
        });
    }

    _justPerfectionSettings() {
        if (this._jpSettings)
            return this._jpSettings;

        const jp = Main.extensionManager.lookup(JUST_PERFECTION_UUID);
        if (!jp)
            return null;

        const source = Gio.SettingsSchemaSource.new_from_directory(
            jp.dir.get_child('schemas').get_path(),
            Gio.SettingsSchemaSource.get_default(),
            false
        );
        this._jpSettings = new Gio.Settings({
            settings_schema: source.lookup(JUST_PERFECTION_SCHEMA, true),
        });
        return this._jpSettings;
    }
}
