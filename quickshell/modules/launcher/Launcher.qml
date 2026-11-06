import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.config.components

Scope {
    id: root

    property bool shown: false
    readonly property bool physicalMode: UserSettings.launcherMode === "physical"
    readonly property real menuScale: UserSettings.layout("appLauncher", { scale: 1, layer: "top" }).scale
    property var apps: []
    property var recents: []

    // Recomputed whenever the query changes.
    property var filteredApps: []

    function open() {
        appProc.running = true
        shown = true
        updateResults()
    }

    function close() {
        shown = false
        searchField.text = ""
        listView.currentIndex = 0
    }

    function toggle() {
        shown ? close() : open()
    }

    function launch(app) {
        if (!app)
            return

        Quickshell.execDetached(["sh", "-c", app.exec])

        root.recents = [
            app.name,
            ...root.recents.filter(n => n !== app.name)
        ].slice(0, 8)

        close()
    }

    // ---------------------------------------------------------
    // SEARCH
    // ---------------------------------------------------------

    function normalize(text) {
        if (!text)
            return ""

        return text
            .toString()
            .toLowerCase()
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
    }

    function words(text) {
        return normalize(text)
            .split(/[\s._\-:\/]+/)
            .filter(Boolean)
    }

    /*
     * Fuzzy subsequence matching.
     *
     * "ff"      -> Firefox
     * "firefox" -> Firefox
     * "fox"     -> Firefox
     * "settings" -> Settings
     *
     * Returns a score where higher is better.
     */
    function fuzzyScore(query, text) {
        query = normalize(query)
        text = normalize(text)

        if (!query || !text)
            return 0

        // Exact match
        if (text === query)
            return 10000

        // Exact prefix
        if (text.startsWith(query))
            return 8000 - text.length

        // Word prefix
        const textWords = words(text)

        for (const word of textWords) {
            if (word === query)
                return 9500

            if (word.startsWith(query))
                return 7000 - word.length
        }

        // Normal substring
        const substringIndex = text.indexOf(query)

        if (substringIndex !== -1) {
            return 5000 - substringIndex * 10 - text.length
        }

        // Fuzzy subsequence
        let queryIndex = 0
        let score = 0
        let lastIndex = -1
        let consecutive = 0

        for (let i = 0; i < text.length && queryIndex < query.length; i++) {
            if (text[i] !== query[queryIndex])
                continue

            if (lastIndex === i - 1) {
                consecutive++
                score += 80 + consecutive * 20
            } else {
                consecutive = 0
                score += 25
            }

            // Characters near the beginning are more valuable.
            score += Math.max(0, 30 - i)

            // Matching at a word boundary is valuable.
            if (
                i === 0 ||
                /[\s._\-:\/]/.test(text[i - 1])
            ) {
                score += 150
            }

            lastIndex = i
            queryIndex++
        }

        // Query wasn't completely matched.
        if (queryIndex !== query.length)
            return -1

        // Penalize long gaps / long names.
        score -= text.length
        score -= Math.max(0, lastIndex - query.length) * 2

        return score
    }

    function scoreApp(app, query) {
        if (!app || !app.name)
            return -1

        const name = app.name
        const exec = app.exec || ""
        const comment = app.comment || ""

        const nameScore = fuzzyScore(query, name)

        // Keep name matches strongest while still allowing useful searches
        // such as "browser" to match an app whose description says browser.
        let score = nameScore

        // Allow searching executable names as a secondary signal.
        const execScore = fuzzyScore(query, exec)

        if (execScore >= 0)
            score = Math.max(score, Math.min(execScore * 0.15, 500))

        const commentScore = fuzzyScore(query, comment)
        if (commentScore >= 0)
            score = Math.max(score, Math.min(commentScore * 0.12, 350))

        return score
    }

    function searchApps(query) {
        query = query.trim()

        if (!query) {
            if (recents.length === 0)
                return apps

            const recentApps = []

            for (const name of recents) {
                const app = apps.find(a => a.name === name)

                if (app)
                    recentApps.push(app)
            }

            const recentNames = new Set(recents)

            const rest = apps.filter(
                app => !recentNames.has(app.name)
            )

            return recentApps.concat(rest)
        }

        const results = []

        for (const app of apps) {
            const score = scoreApp(app, query)

            if (score < 0)
                continue

            results.push({
                app: app,
                score: score
            })
        }

        results.sort((a, b) => {
            if (b.score !== a.score)
                return b.score - a.score

            return a.app.name.localeCompare(b.app.name)
        })

        return results.map(result => result.app)
    }

    function updateResults() {
        filteredApps = searchApps(searchField.text)
        listView.currentIndex = filteredApps.length > 0 ? 0 : -1
    }

    // ---------------------------------------------------------
    // HIGHLIGHT
    // ---------------------------------------------------------

    function escapeHtml(text) {
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;")
    }

    function highlight(name, query) {
        if (!query)
            return escapeHtml(name)

        const original = name
        const normalizedName = normalize(name)
        const normalizedQuery = normalize(query)

        const idx = normalizedName.indexOf(normalizedQuery)

        // Exact substring: highlight it directly.
        if (idx !== -1) {
            return (
                escapeHtml(original.substring(0, idx)) +
                "<b><font color=\"" + Colors.color(4) + "\">" +
                escapeHtml(
                    original.substring(
                        idx,
                        idx + query.length
                    )
                ) +
                "</font></b>" +
                escapeHtml(
                    original.substring(idx + query.length)
                )
            )
        }

        // Fuzzy highlight.
        let result = ""
        let queryIndex = 0

        for (let i = 0; i < original.length; i++) {
            const char = normalize(original[i])

            if (
                queryIndex < normalizedQuery.length &&
                char === normalizedQuery[queryIndex]
            ) {
                result +=
                    "<b><font color=\"" +
                    Colors.color(4) +
                    "\">" +
                    escapeHtml(original[i]) +
                    "</font></b>"

                queryIndex++
            } else {
                result += escapeHtml(original[i])
            }
        }

        return result
    }

    // ---------------------------------------------------------
    // IPC
    // ---------------------------------------------------------

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle()
        }

        function open(): void {
            root.open()
        }

        function close(): void {
            root.close()
        }
    }

    // ---------------------------------------------------------
    // APPLICATION DISCOVERY
    // ---------------------------------------------------------

    Process {
        id: appProc

        command: [
            "python3",
            `${Quickshell.env("HOME")}/.config/quickshell/scripts/list-apps.py`
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.apps = JSON.parse(this.text)
                    root.updateResults()
                } catch (e) {
                    root.apps = []
                    root.filteredApps = []
                }
            }
        }
    }

    // ---------------------------------------------------------
    // WINDOW
    // ---------------------------------------------------------

    PanelWindow {
        id: win

        visible: root.shown
        color: "transparent"
        WlrLayershell.namespace: "quickshell:launcher"
        WlrLayershell.layer: UserSettings.layout("appLauncher", { layer: "top" }).layer === "under" ? WlrLayer.Bottom : WlrLayer.Top
        width: root.physicalMode
            ? Math.min(520, Math.max(280, (Quickshell.screens[0]?.width ?? 1280) * 0.4)) * root.menuScale
            : (Quickshell.screens[0]?.width ?? 1280)
        height: Quickshell.screens[0]?.height ?? 800
        exclusiveZone: root.shown && root.physicalMode ? width : 0

        anchors {
            top: true
            bottom: true
            left: true
            // Physical mode is a left-edge panel with a reserved work area;
            // widget mode uses the full-screen surface for its centered card.
            right: !root.physicalMode
        }

        HyprlandFocusGrab {
            windows: [win]
            active: root.shown

            onCleared: root.close()
        }

        onVisibleChanged: {
            if (visible)
                searchField.forceActiveFocus()
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()

            GlassCard {
                id: card

                anchors {
                    left: root.physicalMode ? parent.left : undefined
                    right: root.physicalMode ? parent.right : undefined
                    top: root.physicalMode ? parent.top : undefined
                    bottom: root.physicalMode ? parent.bottom : undefined
                    centerIn: root.physicalMode ? undefined : parent
                    margins: 0
                }

                width: root.physicalMode ? parent.width : Math.min(760, win.width - 48) * root.menuScale
                height: root.physicalMode ? parent.height : Math.min(660, win.height - 64) * root.menuScale

                cardRadius: root.physicalMode ? 0 : Appearance.radiusLarge
                surfaceOpacity: root.physicalMode ? 1 : Appearance.panelOpacity
                borderWidth: root.physicalMode ? 0 : 1
                shadowRadius: root.physicalMode ? 0 : Appearance.shadowRadiusMedium
                shadowOffset: root.physicalMode ? 0 : Appearance.shadowOffsetMedium
                borderColor: Colors.outlineStrong

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    // -------------------------------------------------
                    // SEARCH FIELD
                    // -------------------------------------------------

                    TextField {
                        id: searchField

                        Layout.fillWidth: true
                        Layout.preferredHeight: 50

                        placeholderText: "Search applications..."

                        color: Colors.foreground

                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize + 2
                        font.weight: Font.Bold

                        background: Rectangle {
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.06)

                            border.width: 1
                            border.color: Colors.color(8)
                        }

                        Keys.onDownPressed: {
                            listView.incrementCurrentIndex()
                        }

                        Keys.onUpPressed: {
                            listView.decrementCurrentIndex()
                        }

                        Keys.onEscapePressed: {
                            root.close()
                        }

                        Keys.onReturnPressed: {
                            if (
                                listView.currentIndex >= 0 &&
                                listView.currentIndex < filteredApps.length
                            ) {
                                root.launch(
                                    filteredApps[listView.currentIndex]
                                )
                            }
                        }

                        Keys.onEnterPressed: {
                            if (
                                listView.currentIndex >= 0 &&
                                listView.currentIndex < filteredApps.length
                            ) {
                                root.launch(
                                    filteredApps[listView.currentIndex]
                                )
                            }
                        }

                        onTextChanged: {
                            root.updateResults()
                        }
                    }

                    // -------------------------------------------------
                    // RECENT LABEL
                    // -------------------------------------------------

                    Text {
                        visible:
                            searchField.text.length === 0 &&
                            root.recents.length > 0

                        text: "Recent"

                        color: Colors.color(8)

                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                    // -------------------------------------------------
                    // RESULTS
                    // -------------------------------------------------

                    ListView {
                        id: listView

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true

                        currentIndex:
                            filteredApps.length > 0 ? 0 : -1

                        highlightMoveDuration: 100

                        model: root.filteredApps

                        delegate: Rectangle {
                            width: listView.width
                            height: 62

                            radius: 8

                            color:
                                ListView.isCurrentItem
                                ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.18)
                                : rowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.045) : "transparent"
                            
                            border.width: ListView.isCurrentItem ? 1 : 0
                            border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.5)

                            RowLayout {
                                anchors.fill: parent

                                anchors.leftMargin: 14
                                anchors.rightMargin: 14

                                spacing: 13

                                Rectangle {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    radius: 10
                                    color: Qt.rgba(1, 1, 1, 0.06)

                                    Text {
                                        anchors.centerIn: parent
                                        text: (modelData.name || "?").slice(0, 1).toUpperCase()
                                        color: Colors.color(4)
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 15
                                        font.weight: Font.Bold
                                    }

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 3

                                        sourceSize.width: 30
                                        sourceSize.height: 30

                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true

                                        source: {
                                            if (!modelData.icon)
                                                return ""

                                            return modelData.icon.startsWith("/")
                                                ? "file://" + modelData.icon
                                                : Quickshell.iconPath(
                                                    modelData.icon,
                                                    "application-x-executable"
                                                )
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: root.highlight(modelData.name, searchField.text)
                                        textFormat: Text.RichText
                                        color: Colors.foreground
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSize + 1
                                        font.weight: Font.Bold
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: (modelData.comment || "").length > 0
                                        text: modelData.comment || ""
                                        color: Colors.color(7)
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSizeSmall
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    visible: searchField.text.length === 0 && index < 5
                                    text: index + 1
                                    color: ListView.isCurrentItem ? Colors.color(4) : Colors.textDim
                                    font.family: Appearance.monoFont
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent

                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: {
                                    listView.currentIndex = index
                                }

                                onClicked: {
                                    root.launch(modelData)
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: listView.count === 0

                            text:
                                searchField.text.length > 0
                                ? "No matches"
                                : "No applications"

                            color: Colors.color(8)

                            font.family: Appearance.fontFamily
                            font.weight: Font.Bold
                        }
                    }

                    // -------------------------------------------------
                    // FOOTER
                    // -------------------------------------------------

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        Text {
                            text: "↵  Launch"
                            color: Colors.color(8)

                            font.pixelSize: 10
                            font.family: Appearance.fontFamily
                        }

                        Text {
                            text: "↑ ↓  Navigate"
                            color: Colors.color(8)

                            font.pixelSize: 10
                            font.family: Appearance.fontFamily
                        }

                        Text {
                            text: "Esc  Close"
                            color: Colors.color(8)

                            font.pixelSize: 10
                            font.family: Appearance.fontFamily
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: `${filteredApps.length} results`
                            color: Colors.color(7)
                            font.pixelSize: 10
                            font.family: Appearance.fontFamily
                        }
                    }
                }

                Rectangle {
                    visible: root.physicalMode
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Colors.outline
                }

                Rectangle {
                    z: 20
                    visible: UserSettings.layoutEditMode
                    width: 20
                    height: 20
                    radius: 6
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: Colors.accentColor
                    Text { anchors.centerIn: parent; text: "↘"; color: Colors.background; font.pixelSize: 12 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeFDiagCursor
                        property real startScale: 1
                        property real startX: 0
                        property real startY: 0
                        onPressed: function(mouse) {
                            startScale = root.menuScale;
                            startX = mouse.x;
                            startY = mouse.y;
                        }
                        onPositionChanged: function(mouse) {
                            if (pressed) {
                                const state = UserSettings.layout("appLauncher", { scale: 1, layer: "top" });
                                state.scale = Math.max(0.65, Math.min(1.5, startScale + ((mouse.x - startX) + (mouse.y - startY)) / 220));
                                UserSettings.setLayout("appLauncher", state);
                            }
                        }
                    }
                }
            }
        }
    }
}
