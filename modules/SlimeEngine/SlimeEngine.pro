TEMPLATE = subdirs

deployment.files += qmldir \
                    0.2

deployment.path = $$[QT_INSTALL_QML]/SlimeEngine
INSTALLS += deployment

OTHER_FILES += $$deployment.files
