#pragma once
#include <ranges>

//#include <QtCore>
#include <QObject>

#include "model.h"
#include "TCPClient.h"

namespace dh {

class WalkInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString name READ name)
    Q_PROPERTY(double latitude READ latitude)
    Q_PROPERTY(double longitude READ longitude)

public:
    WalkInfo(QObject *parent = nullptr) : QObject(parent) {}

    QString name() const
    {
        return _login;
    }

    double latitude() const
    {
        return _coordinate._latitude;
    }

    double longitude() const
    {
        return _coordinate._longitude;
    }

    QString _login;
    Coordinate _coordinate;
};

class Controller : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool inProcess READ inProcess NOTIFY inProcessChanged)
    Q_PROPERTY(bool walkWasSelected READ walkWasSelected NOTIFY walkWasSelectedChanged)
    Q_PROPERTY(QString selDogOwnerName READ selDogOwnerName NOTIFY selDogOwnerNameChanged)
    Q_PROPERTY(QString selDogOnWalkName READ selDogOnWalkName NOTIFY selDogOnWalkNameChanged)
    Q_PROPERTY(QString selDogOnWalkAge READ selDogOnWalkAge NOTIFY selDogOnWalkAgeChanged)
    Q_PROPERTY(QString selDogOnWalkBreede READ selDogOnWalkBreede NOTIFY selDogOnWalkBreedeChanged)

public:
    explicit Controller(QObject *parent = nullptr);

    virtual ~Controller();

    bool inProcess() const { return _inProcess; }

    bool walkWasSelected() const { return !!_selectedWalk; }

    QString selDogOwnerName() const {
        if(!_selectedWalk)
            return "";

        return QString::fromStdString(_model._dogOwners.at(_selectedWalk->_dogOwnerId)->_name);
    }

    QString selDogOnWalkName() const {
        if(!_selectedWalk)
            return "";

        return QString::fromStdString(_selectedWalk->_dogName);
    }

    QString selDogOnWalkAge() const {
        if(!_selectedWalk)
            return "";

        return QString::number(_model._dogOwners.at(_selectedWalk->_dogOwnerId)->getDog(_selectedWalk->_dogName)->age);
    }

    QString selDogOnWalkBreede() const {
        if(!_selectedWalk)
            return "";

        return QString::fromStdString(_model._dogOwners.at(_selectedWalk->_dogOwnerId)->getDog(_selectedWalk->_dogName)->_breed);
    }

    Q_INVOKABLE QList<WalkInfo*> getWalkInfo(double radius, double latitude, double longitude)
    {
        _selectedWalk = nullptr;
        _walksOnMap = _model.getWalks(Coordinate{(float)latitude, (float)longitude}, radius, QDateTime(QDate(2024, 5, 12), QTime(12, 0)));

        QList<WalkInfo*> res;
        for(const auto &walk : _walksOnMap)
        {
            WalkInfo *inf = new WalkInfo(this);
            inf->_coordinate = walk._coordinate;
            inf->_login = QString::fromStdString(walk._dogOwnerId);
            res.append(inf);
        }

        return res;
    }

    Q_INVOKABLE bool tryToSelectWalk(double latitude, double longitude)
    {
        auto filteredData = _walksOnMap | std::views::filter([&](const auto& walk) {
                                return Coordinate::distanceTo(walk._coordinate, Coordinate{(float)latitude, (float)longitude} ) <= 0.2;
                            });

        if(filteredData.empty())
            return false;

        _selectedWalk = std::make_shared<Walk>(*filteredData.begin());

        emit walkWasSelectedChanged();
        emit selDogOwnerNameChanged();
        emit selDogOnWalkNameChanged();
        emit selDogOnWalkAgeChanged();
        emit selDogOnWalkBreedeChanged();

        return true;
    }

signals:
    void inProcessChanged();
    void walkWasSelectedChanged();
    void selDogOwnerNameChanged();
    void selDogOnWalkNameChanged();
    void selDogOnWalkAgeChanged();
    void selDogOnWalkBreedeChanged();

    void loginResult(int);

private slots:
    void onResponceFromServer(RequestHandlerPtr responce)
    {
        qDebug() << "On responce from server side.";

        if(auto loginResponce =  qSharedPointerCast<LoginResponce>(responce))
        {
            if(loginResponce->_status == LoginResponce::ResponceStatus::Valid)
            {
                _model._dogOwners[_model._superUser = loginResponce->_dogOwner->_email]
                    = loginResponce->_dogOwner;
            }

            emit loginResult(static_cast<int>(loginResponce->_status));
        }

        _inProcess = false;
        emit inProcessChanged();
    }

public slots:

    void onLogin(QString name, QString password)
    {
        setInProcess();
        qDebug() << "onLogin " << name << " " << password;
        _tCPClient.addHandler(QSharedPointer<LoginRequest>::create(name, password));
    }

private:

    void setInProcess() {
        _inProcess = true;
        emit inProcessChanged();
    }

public:

    std::atomic<bool> _inProcess = false;
    ModelData _model;
    std::vector<Walk> _walksOnMap;
    TCPClient _tCPClient;
    std::shared_ptr<Walk> _selectedWalk = nullptr;
};

}
