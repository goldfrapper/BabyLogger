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

SOURCES += src/baby-logger.cpp

OTHER_FILES += qml/baby-logger.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/baby-logger.changes.in \
    rpm/baby-logger.spec \
    rpm/baby-logger.yaml \
    translations/*.ts \
    baby-logger.desktop \
    qml/pages/BabyModel.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/baby-logger-de.ts

