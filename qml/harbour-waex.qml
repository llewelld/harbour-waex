import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
import Amber.Web.Authorization 1.0

ApplicationWindow {
    initialPage: Component {
        Page {
            property string accessToken

            SilicaListView {
                anchors.fill: parent
                VerticalScrollDecorator {}
                model: ListModel{ id: statusList }
                header: Column {
                    width: parent.width
                    PageHeader { title: "Mastodon OAuth Example"}
                    Button {
                        text: "Authorise"
                        visible: !accessToken
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: oAuth.authorizeInBrowser()
                    }
                    Button {
                        text: "Update"
                        visible: accessToken
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: updateStatus()
                    }
                }

                delegate: BackgroundItem {
                    height: column.height
                    Column {
                        id: column
                        x: Theme.horizontalPageMargin
                        spacing: Theme.paddingSmall
                        width: parent.width - 2 * x
                        Label {
                            text: account.username
                            width: parent.width
                            color: Theme.highlightColor
                        }
                        Label {
                            text: content
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            OAuth2AcPkce {
                id: oAuth

                clientId: "2ofL_Jqs-A6II-uRZ8QXGIG5B6-jgmocLup1jloB8yc"
                clientSecret: "ADD YOUR CLIENT SECRET HERE"
                redirectListener.port: 7357

                scopes: ["read"]
                tokenEndpoint: "https://mastodon.social/oauth/token"
                authorizationEndpoint: "https://mastodon.social/oauth/authorize"

                onErrorOccurred: {
                    notification.body = error.message
                    notification.publish()
                }

                onReceivedAccessToken: {
                    accessToken = token.access_token
                    console.log("Token: " + accessToken)
                    notification.body = "Authorised"
                    notification.publish()
                }
            }

            Notification {
                id: notification
                summary: "Mastodon OAuth2"
            }

            function updateStatus() {
                var req = new XMLHttpRequest()
                req.onreadystatechange = function() {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        var timeline = JSON.parse(req.responseText)
                        statusList.clear()
                        for (var pos = 0; pos < timeline.length; pos++) {
                            statusList.append(timeline[pos])
                        }
                    }
                }
                req.open("GET", "https://mastodon.social/api/v1/timelines/home")
                req.setRequestHeader("Authorization", "Bearer " + accessToken)
                req.send()
            }
        }
    }
}
