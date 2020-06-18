import sys
import os
import json
import urllib.request
import subprocess
import shlex
import logging

from gi.repository import Gio
from gi.repository import GLib
from configparser import ConfigParser
from datetime import datetime, timedelta

BUS_NAME = 'com.kugiigi.indicator.darkmode'
BUS_OBJECT_PATH = '/com/kugiigi/indicator/darkmode'
BUS_OBJECT_PATH_PHONE = BUS_OBJECT_PATH + '/phone'

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


class ImmersiveIndicator(object):
    ROOT_ACTION = 'root'
    CURRENT_ACTION = "toggle"
    SETTINGS_ACTION = 'settings'
    MAIN_SECTION = 0
    
    AMBIANCE_TEXT = "Ubuntu.Components.Themes.Ambiance"
    SURUDARK_TEXT = "Ubuntu.Components.Themes.SuruDark"
    ENABLED_ICON = "weather-clear-night-symbolic"
    DISABLED_ICON = "night-mode"
    
    config_file = "/home/phablet/.config/indicator-darkmode/indicator-darkmode.conf"  # TODO don't hardcode this
    theme_ini = "/home/phablet/.config/ubuntu-ui-toolkit/theme.ini"
    config_parser = ConfigParser()
    theme_parser = ConfigParser()
    
    def __init__(self, bus):
        self.bus = bus
        self.action_group = Gio.SimpleActionGroup()
        self.menu = Gio.Menu()
        self.sub_menu = Gio.Menu()

        self.current_switch_icon = self.DISABLED_ICON

    def get_text(self, condition):
        text = 'Indicator Suru Dark Mode'
        return text

    def get_icon(self, condition):
        icon = self.FOG
        return icon

    def toggle_mode_activated(self, action, data):
        logger.debug('toggle_mode_activated')
        
        if self.autoSwitchEnabled() == False:
            self.toggleTheme()
        
        self.update_darkmode(set_timeout=False)
        
    def settings_action_activated(self, action, data):
        logger.debug('settings_action_activated')
        subprocess.Popen(shlex.split('ubuntu-app-launch indicator-darkmode.kugiigi_indicator-darkmode'))


    def _setup_actions(self):
        root_action = Gio.SimpleAction.new_stateful(self.ROOT_ACTION, None, self.root_state())
        self.action_group.insert(root_action)
        
        current_action = Gio.SimpleAction.new_stateful(self.CURRENT_ACTION, None, GLib.Variant.new_boolean(self.current_state()))
        current_action.connect('activate', self.toggle_mode_activated)
        self.action_group.insert(current_action)
        
        settings_action = Gio.SimpleAction.new(self.SETTINGS_ACTION, None)
        settings_action.connect('activate', self.settings_action_activated)
        self.action_group.insert(settings_action)


    def _create_section(self):
        section = Gio.Menu()
        
        current_menu_item = Gio.MenuItem.new('Suru Dark Mode', 'indicator.{}'.format(self.CURRENT_ACTION))
        current_menu_item.set_attribute_value('x-canonical-type', GLib.Variant.new_string('com.canonical.indicator.switch'))
        section.append_item(current_menu_item)
        
        settings_menu_item = Gio.MenuItem.new('Suru Dark Mode Settings...', 'indicator.{}'.format(self.SETTINGS_ACTION))
        section.append_item(settings_menu_item)


        return section

    def _setup_menu(self):
        self.sub_menu.insert_section(self.MAIN_SECTION, 'Suru Dark Mode', self._create_section())

        root_menu_item = Gio.MenuItem.new('Suru Dark Mode', 'indicator.{}'.format(self.ROOT_ACTION))
        root_menu_item.set_attribute_value('x-canonical-type', GLib.Variant.new_string('com.canonical.indicator.root'))
        root_menu_item.set_submenu(self.sub_menu)
        self.menu.append_item(root_menu_item)

    def _update_menu(self):
        self.sub_menu.remove(self.MAIN_SECTION)
        self.sub_menu.insert_section(self.MAIN_SECTION, 'Suru Dark Mode', self._create_section())

    def update_darkmode(self, set_timeout=True): 
        if self.autoSwitchEnabled() == True:
            currentTheme = self.current_theme()
            startTime = self.startTime().split(':')
            endTime = self.endTime().split(':')
            
            now = datetime.now()
            
            start = now.replace(hour=int(startTime[0]), minute=int(startTime[1]), second=0, microsecond=0)
            
            end = now.replace(hour=int(endTime[0]), minute=int(endTime[1]), second=0, microsecond=0)
            reverseLogic = (int(startTime[0]) > int(endTime[0])) or (int(startTime[0]) == int(endTime[0]) and int(startTime[1]) > int(endTime[1]))
            
            if (((reverseLogic == False and now >= start and now <= end) or (reverseLogic == True and ((now >= start and now >= end) or (now <= start and now <= end)))) and currentTheme != self.SURUDARK_TEXT) \
                or (((reverseLogic == False and (now < start or now > end)) or (reverseLogic == True and now < start and now > end)) and currentTheme != self.AMBIANCE_TEXT):
                self.toggleTheme()
        
        logger.debug('Updated theme to: {}'.format(self.current_theme()))
        self.action_group.change_action_state(self.ROOT_ACTION, self.root_state())
        self.action_group.change_action_state(self.CURRENT_ACTION, GLib.Variant.new_boolean(self.current_state()))
        self._update_menu()
        
        if set_timeout == True:
            # Stop timeout and recreate another so that we get the value of interval minutes in real time
            GLib.timeout_add_seconds(60 * self.checkInterval(), self.update_darkmode)        
        return False
        
    def toggleTheme(self):
        self.theme_parser.read(self.theme_ini)
        general_config = self.theme_parser["General"]
        currentTheme = self.current_theme()
        
        if currentTheme == self.SURUDARK_TEXT:
            general_config['theme'] = self.AMBIANCE_TEXT
            self.current_switch_icon = self.DISABLED_ICON
        else:
            general_config['theme'] = self.SURUDARK_TEXT
            self.current_switch_icon = self.ENABLED_ICON
        
        #Write changes back to file
        with open(self.theme_ini, 'w') as conf:
            self.theme_parser.write(conf)

    def run(self):
        self._setup_actions()
        self._setup_menu()

        self.bus.export_action_group(BUS_OBJECT_PATH, self.action_group)
        self.menu_export = self.bus.export_menu_model(BUS_OBJECT_PATH_PHONE, self.menu)
        
        self.update_darkmode()

    def root_state(self):
        vardict = GLib.VariantDict.new()
        
        currentState = self.current_state()
        if currentState == True:
            vardict.insert_value('visible', GLib.Variant.new_boolean(True))
        else:
            vardict.insert_value('visible', GLib.Variant.new_boolean(False))
        
        vardict.insert_value('title', GLib.Variant.new_string('Suru Dark Mode'))

        icon = Gio.ThemedIcon.new(self.current_icon())
        vardict.insert_value('icon', icon.serialize())

        return vardict.end()
        
    def autoSwitchEnabled(self):
        try:
            self.config_parser.read(self.config_file)
            general_config = self.config_parser["General"]
            return general_config['autoDarkMode'].strip() == 'true'
        except:
            return False
        
    def checkInterval(self):
        try:
            self.config_parser.read(self.config_file)
            general_config = self.config_parser["General"]
            value = general_config['checkInterval'].strip()
            if value:
                return int(value)
            else:
                return 15
        except:
            return 15
        
        
    def startTime(self):
        try:
            self.config_parser.read(self.config_file)
            general_config = self.config_parser["General"]
            value = general_config['startTime'].strip()
            if value:
                return value
            else:
                return "19:00"
        except:
            return "19:00"
        
    def endTime(self):
        try:
            self.config_parser.read(self.config_file)
            general_config = self.config_parser["General"]
            value =  general_config['endTime'].strip()
            if value:
                return value
            else:
                return "06:00"
        except:
            return "06:00"

    def current_icon(self):
        currentState = self.current_state()
        if currentState == True:
            icon = self.ENABLED_ICON
        else:
            icon = self.current_switch_icon
        return icon
        
    def current_theme(self):
        self.theme_parser.read(self.theme_ini)
        general_config = self.theme_parser["General"]
        return general_config['theme'].strip()
        
    def current_state(self):
        currentValue = self.current_theme()
        if currentValue == self.SURUDARK_TEXT:
            state = True
        else:
            state = False
        return state



if __name__ == '__main__':
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    proxy = Gio.DBusProxy.new_sync(bus, 0, None, 'org.freedesktop.DBus', '/org/freedesktop/DBus', 'org.freedesktop.DBus', None)
    result = proxy.RequestName('(su)', BUS_NAME, 0x4)
    if result != 1:
        logger.critical('Error: Bus name is already taken')
        sys.exit(1)

    wi = ImmersiveIndicator(bus)
    wi.run()

    logger.debug('Dark Mode Indicator startup completed')
    GLib.MainLoop().run()
