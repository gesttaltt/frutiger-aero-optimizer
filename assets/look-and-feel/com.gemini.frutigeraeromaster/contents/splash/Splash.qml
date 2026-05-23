import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root
    property int stage: 0

    onStageChanged: {
        if (stage == 5) {
            fadeOut.running = true;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1D5F7A" }
            GradientStop { position: 1.0; color: "#2E8AB0" }
        }
    }

    // Try to load a background image
    Image {
        id: bgtexture
        anchors.fill: parent
        source: "images/background.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.6
        visible: status === Image.Ready
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30

        BusyIndicator {
            id: indicator
            running: true
            Layout.alignment: Qt.AlignHCenter
            contentItem: Item {
                implicitWidth: 64
                implicitHeight: 64
                RotationAnimator {
                    target: indicator.contentItem
                    from: 0
                    to: 360
                    duration: 1000
                    running: indicator.running
                    loops: Animation.Infinite
                }
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.beginPath();
                        ctx.arc(width / 2, height / 2, width / 2 - 4, 0, Math.PI * 2);
                        ctx.strokeStyle = "rgba(255, 255, 255, 0.2)";
                        ctx.lineWidth = 4;
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(width / 2, height / 2, width / 2 - 4, 0, Math.PI * 0.5);
                        ctx.strokeStyle = "white";
                        ctx.lineWidth = 4;
                        ctx.stroke();
                    }
                }
            }
        }

        Text {
            id: statusText
            text: "Welcome"
            font.pointSize: 28
            font.family: "Segoe UI, Selawik, sans-serif"
            color: "white"
            Layout.alignment: Qt.AlignHCenter
            style: Text.Outline
            styleColor: "rgba(0,0,0,0.2)"
        }
    }

    Image {
        id: watermark
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40
        source: "images/watermark.png"
        width: 128
        height: 128
        fillMode: Image.PreserveAspectFit
        opacity: 0.5
        visible: status === Image.Ready
    }

    Rectangle {
        id: transitionAnim
        anchors.fill: parent
        color: "black"
        opacity: 0
        visible: opacity > 0
    }

    NumberAnimation {
        id: fadeOut
        target: transitionAnim
        property: "opacity"
        from: 0
        to: 1
        duration: 600
    }
}
