# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-babylogger

CONFIG += sailfishapp

SOURCES += src/harbour-babylogger.cpp

OTHER_FILES += qml/harbour-babylogger.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-babylogger.changes.in \
    rpm/harbour-babylogger.spec \
    rpm/harbour-babylogger.yaml \
    translations/*.ts \
    harbour-babylogger.desktop \
    qml/pages/BabyModel.qml \
    qml/pages/Counter.qml \
    qml/pages/LogMealDialog.qml\
    README.md \
    qml/pages/FirstPage.qml \
    qml/pages/LogEntryItem.qml \
    qml/pages/AboutPage.qml \
    qml/pages/Definition.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/ConfirmDialog.qml \
    CHANGELOG \
    qml/components/Settings.qml \
    qml/pages/DatetimeSelectionDialog.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/harbour-babylogger-fi.ts

RESOURCES += \
    resources.qrc
