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
TARGET = baby_app

CONFIG += sailfishapp

SOURCES += src/baby_app.cpp

OTHER_FILES += qml/baby_app.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/baby_app.changes.in \
    rpm/baby_app.spec \
    rpm/baby_app.yaml \
    translations/*.ts \
    baby_app.desktop \
    qml/pages/BabyModel.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/baby_app-de.ts

