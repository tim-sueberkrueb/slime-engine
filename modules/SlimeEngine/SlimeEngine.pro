TEMPLATE = subdirs

deployment.files += qmldir \
                    0.1 

deployment.path = $$[QT_INSTALL_QML]/SlimeEngine
INSTALLS += deployment

OTHER_FILES += $$deployment.files
