from PyQt5 import QtCore, QtGui, QtWidgets

# func for set settings for button
def set_font(font_family, size, is_bold):
    font = QtGui.QFont(font_family, size)
    font.setBold(is_bold)
    return font

# func for default settings for buttons
def set_btn(btn):
    btn.setAutoFillBackground(False)
    btn.setAutoDefault(False)
    btn.setDefault(False)
    btn.setFlat(False)

def create_ui(MainWindow):
    MainWindow.setWindowTitle("Кухня")
    
    centralwidget = QtWidgets.QWidget(MainWindow)
    centralwidget.setObjectName("centralwidget")
    gridLayout = QtWidgets.QGridLayout(centralwidget)
    gridLayout.setObjectName("gridLayout")

    # name
    name_label = QtWidgets.QLabel(centralwidget)
    name_label.setFont(set_font("Century Gothic", 16, True))
    name_label.setText("Кухня")
    name_label.setObjectName("name_label")
    gridLayout.addWidget(name_label, 0, 0, 1, 1)

    # tab widget for active and close orders
    tabWidget = QtWidgets.QTabWidget(centralwidget)
    tabWidget.setObjectName("tabWidget")

    # active order tab
    active_order = QtWidgets.QWidget()
    active_order.setObjectName("active_order")
    gridLayout_2 = QtWidgets.QGridLayout(active_order)
    gridLayout_2.setObjectName("gridLayout_2")

    scrollArea = QtWidgets.QScrollArea(active_order)
    scrollArea.setWidgetResizable(True)
    scrollArea.setObjectName("scrollArea")

    # scrollArea.setWidget(order_widg_1)
    gridLayout_2.addWidget(scrollArea, 0, 0, 1, 1)
    tabWidget.addTab(active_order, "Активные")

    # close order tab
    close_order = QtWidgets.QWidget()
    close_order.setObjectName("close_order")
    gridLayout_3 = QtWidgets.QGridLayout(close_order)
    gridLayout_3.setObjectName("gridLayout_3")

    scrollArea_2 = QtWidgets.QScrollArea(close_order)
    scrollArea_2.setWidgetResizable(True)
    scrollArea_2.setObjectName("scrollArea")
    scrollAreaWidgetContents = QtWidgets.QWidget()
    scrollAreaWidgetContents.setGeometry(QtCore.QRect(0, 0, 771, 361))
    scrollAreaWidgetContents.setObjectName("scrollAreaWidgetContents")

    formLayout_2 = QtWidgets.QFormLayout(scrollAreaWidgetContents)
    formLayout_2.setObjectName("formLayout_2")

    close_lbl_1 = QtWidgets.QLabel(scrollAreaWidgetContents)
    close_lbl_1.setFont(set_font("Century Gothic", 15, False))
    close_lbl_1.setText("Круассан с лососем | 14:48 | 15:35")
    close_lbl_1.setObjectName("close_lbl_1")
    formLayout_2.setWidget(0, QtWidgets.QFormLayout.LabelRole, close_lbl_1)

    close_btn_1 = QtWidgets.QPushButton(scrollAreaWidgetContents)
    close_btn_1.setFont(set_font("Century Gothic", 12, False))
    close_btn_1.setText("Готов")
    formLayout_2.setWidget(0, QtWidgets.QFormLayout.FieldRole, close_btn_1)

    scrollArea_2.setWidget(scrollAreaWidgetContents)
    gridLayout_3.addWidget(scrollArea_2, 0, 0, 1, 1)
    tabWidget.addTab(close_order, "Закрытые")

    gridLayout.addWidget(tabWidget, 1, 0, 1, 1)
    MainWindow.setCentralWidget(centralwidget)

    QtCore.QMetaObject.connectSlotsByName(MainWindow)

    return {
        "centralwidget": centralwidget,
        "name_label": name_label,
        "gridLayout": gridLayout,
        "tabWidget": tabWidget,
        "active_order": active_order,
        "gridLayout_2": gridLayout_2,
        "scrollArea": scrollArea,
        "scrollArea_2": scrollArea_2,
        "close_order": close_order,
        "gridLayout_3": gridLayout_3,
        "scrollAreaWidgetContents": scrollAreaWidgetContents
    }