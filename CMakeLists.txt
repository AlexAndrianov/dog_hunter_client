cmake_minimum_required(VERSION 3.21.1)

option(LINK_INSIGHT "Link Qt Insight Tracker library" ON)
option(BUILD_QDS_COMPONENTS "Build design studio components" ON)

project(dog_hunterApp LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 23)

find_package(Qt6 6.6.3 REQUIRED COMPONENTS Core Gui Qml Quick Network)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

#option(BUILD_QDS_COMPONENTS "Build design studio components" OFF)
#set(BUILD_QDS_COMPONENTS OFF CACHE BOOL "Build design studio components" FORCE)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.3)
    qt_standard_project_setup()
endif()

# Add the library subdirectory
add_subdirectory(core)

set(SOURCES
    src/Controller.cpp
    src/main.cpp
)

set(HEADERS
    src/Controller.h
    src/TCPClient.h
)

qt_add_executable(dog_hunterApp ${SOURCES} ${HEADERS})

qt_add_resources(dog_hunterApp "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

target_link_libraries(dog_hunterApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Network
    core
)

if (BUILD_QDS_COMPONENTS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/qmlcomponents)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/qmlmodules)

if (LINK_INSIGHT)
    include(${CMAKE_CURRENT_SOURCE_DIR}/insight)
endif ()

include(GNUInstallDirs)
install(TARGETS dog_hunterApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# make IDEs aware of the QML import path
set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")
