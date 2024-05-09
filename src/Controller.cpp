#include "Controller.h"

namespace dh {

Controller::Controller(QObject *parent) : QObject(parent), _tCPClient(this)
{
    _model = ModelData::getDummyModelData();
    connect(&_tCPClient, &TCPClient::onResponce, this, &Controller::onResponceFromServer);

    _tCPClient.run();
}

Controller::~Controller() {
    _tCPClient.exit();
};

}
