#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "indicator.h"

void IndicatorPlugin::registerTypes(const char *uri) {
    //@uri Indicator
    qmlRegisterSingletonType<Indicator>(uri, 1, 0, "Indicator", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Indicator; });
}

void IndicatorPlugin::initializeEngine(QQmlEngine *engine, const char *uri) {
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
