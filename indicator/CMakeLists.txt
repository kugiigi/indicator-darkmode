configure_file(kugiigi-indicator-darkmode.py ${CMAKE_CURRENT_BINARY_DIR}/kugiigi-indicator-darkmode.py)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/kugiigi-indicator-darkmode.py DESTINATION ${DATA_DIR}indicator)
install(FILES "kugiigi-indicator-darkmode.conf" DESTINATION ${DATA_DIR}indicator)
install(FILES "install.sh" DESTINATION ${DATA_DIR}indicator)
install(FILES "com.kugiigi.indicator.darkmode" DESTINATION ${DATA_DIR}indicator)
install(FILES "uninstall.sh" DESTINATION ${DATA_DIR}indicator)
