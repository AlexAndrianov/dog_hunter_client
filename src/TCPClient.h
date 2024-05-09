#pragma once
#include "core/include/RequestHandler.h"

#include <QtCore>
#include <QMutexLocker>
#include <QtNetwork>

#include <queue>

namespace dh {

class TCPClient : public QObject {
    Q_OBJECT
public:

    explicit TCPClient(QObject *parent = nullptr) : QObject(parent) {}

    virtual ~TCPClient() {
        _socket.disconnectFromHost();
        _thread.quit();
    }

signals:
    void onResponce(RequestHandlerPtr);

public:

    void run()
    {
        _socket.moveToThread(&_thread);

        connect(&_thread, &QThread::started, [this]() {
            //const auto hostname = "10.0.2.2"; // for debug android emulator
            const auto hostname = "localhost";

            _socket.connectToHost(QString(hostname), 8080);

            if (!_socket.waitForConnected(-1)) {
                qDebug() << "Connection to server failed: " << _socket.error();
                return;
            }

            qDebug() << "Connected to server";

            auto getNextHandler = [this]() -> RequestHandlerPtr{
                QMutexLocker locker(&_requestQueueSyncer);

                auto getHandler = [this]() -> RequestHandlerPtr{
                    if(_requestQueue.empty())
                        return nullptr;

                    auto handler = _requestQueue.front();
                    _requestQueue.pop();
                    return handler;

                };

                if(_toStop)
                    return nullptr;

                auto nextHandler = getHandler();
                if(nextHandler)
                    return nextHandler;

                _condition.wait(&_requestQueueSyncer);

                if(_toStop)
                    return nullptr;

                return getHandler();
            };

            while(auto handler = getNextHandler())
            {
                auto jsonObj = handler->serialize();

                QJsonDocument jsonDoc(jsonObj);
                QByteArray requestData = jsonDoc.toJson(QJsonDocument::Indented);

                _socket.write(requestData);
                _socket.flush();

                qDebug() << "Handler was sent: " << jsonDoc;

                // Wait for response
                if(!_socket.waitForReadyRead(-1))
                {
                    qDebug() << "Socket error";
                    continue;
                }

                QByteArray responseData = _socket.readAll();
                qDebug() << "Received response:" << responseData;

                QJsonParseError error;
                jsonDoc = QJsonDocument::fromJson(responseData, &error);

                if (error.error != QJsonParseError::NoError) {
                    qDebug() << "Error parsing JSON:" << error.errorString();
                    continue;
                }

                qDebug() << "Handler was recieved: " << jsonDoc;
                auto respondedHandler = RequestHandler::create(jsonDoc);
                emit onResponce(respondedHandler);
            }

            _socket.close();
        });

        _thread.start();
    }

    void exit()
    {
        {
            QMutexLocker locker(&_requestQueueSyncer);
            _toStop = true;
            _condition.wakeOne();
        }

        _thread.wait();
    }

    void addHandler(RequestHandlerPtr handler)
    {
        QMutexLocker locker(&_requestQueueSyncer);
        _requestQueue.push(handler);
        _condition.wakeOne();
    }

private:
    QTcpSocket _socket;
    QThread _thread;

    QMutex _requestQueueSyncer;
    bool _toStop = false;
    QWaitCondition _condition;
    std::queue<RequestHandlerPtr> _requestQueue;
};

}
