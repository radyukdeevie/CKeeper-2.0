import sys
import psycopg2 as pg
from PyQt5 import QtWidgets, QtCore
from functools import partial
from _contructors.kit_build import create_ui, set_btn, set_font

class UI_MainWindow(object):
    def __init__(self, conn):
        self.conn = conn
        self.cur = conn.cursor()
    
    def setup_ui(self, MainWindow):
        elements = create_ui(MainWindow)
        self.centralwidget = elements["centralwidget"]
        self.name_label = elements["name_label"]
        self.gridLayout = elements["gridLayout"]
        self.tabWidget = elements["tabWidget"]
        self.active_order = elements["active_order"]
        self.gridLayout_2 = elements["gridLayout_2"]
        self.scrollArea = elements["scrollArea"]
        self.scrollArea_2 = elements["scrollArea_2"]
        self.close_order = elements["close_order"]
        self.gridLayout_3 = elements["gridLayout_3"]
        self.scrollAreaWidgetContents = elements["scrollAreaWidgetContents"]

        # Контейнер для виджетов заказов внутри scrollArea
        self.order_container = QtWidgets.QWidget()
        self.order_layout = QtWidgets.QVBoxLayout(self.order_container)
        self.scrollArea.setWidget(self.order_container)
  
        self.set_active_order()
    
    def on_btn_clicked(self, btn_id):
        print(f'Clicked {btn_id} button')
        try:
            self.cur.execute(
                "UPDATE list_order SET product_status_id = 2 WHERE product_id = %s", (btn_id,)
            )
            self.conn.commit()
            print(f'Updated product_id {btn_id} successfully')
        except Exception as e:
            print(f"Error occurred: {e}")
        self.set_active_order()

    def set_active_order(self):
        self.cur.execute(
            "SELECT product_name, lo.product_quantity, created_at, product_id "
            "FROM list_order lo "
            "JOIN product USING (product_id) "
            "JOIN active_order USING (order_id) "
            "WHERE product_status_id = 1"
        )
        rows = self.cur.fetchall()
        product_name = [row[0] for row in rows]
        product_quantity = [row[1] for row in rows]
        create_at = [f'{row[2].hour:02}:{row[2].minute:02}' for row in rows]
        product_id = [row[3] for row in rows]
        print(product_id)

        # Очистить старые виджеты из контейнера
        for i in reversed(range(self.order_layout.count())):
            widget_to_remove = self.order_layout.itemAt(i).widget()
            if widget_to_remove is not None:
                widget_to_remove.deleteLater()

        # Добавляем новые виджеты заказов
        for i in range(len(product_name)):
            widget = QtWidgets.QWidget()
            widget.setObjectName(f"order_widg_{i + 1}")
            form_layout = QtWidgets.QFormLayout(widget)
            form_layout.setObjectName(f"formLayout_{i + 1}")

            # Создание метки с информацией о заказе
            order_label = QtWidgets.QLabel(widget)
            order_label.setFont(set_font("Century Gothic", 15, False))
            order_label.setText(f"{product_name[i]} | {create_at[i]} | {product_quantity[i]}")
            order_label.setObjectName(f"order_lbl_{i + 1}")
            form_layout.setWidget(0, QtWidgets.QFormLayout.LabelRole, order_label)

            # Создание кнопки "Готов"
            push_button = QtWidgets.QPushButton(widget)
            push_button.setFont(set_font("Century Gothic", 12, False))
            push_button.setText("Готов")
            push_button.setFixedSize(200, 40)
            set_btn(push_button)
            push_button.setObjectName(f"order_btn_{i + 1}")
            push_button.clicked.connect(partial(self.on_btn_clicked, product_id[i]))
            form_layout.setWidget(0, QtWidgets.QFormLayout.FieldRole, push_button)
            form_layout.setAlignment(push_button, QtCore.Qt.AlignRight)

            # Добавляем созданный виджет в контейнер
            self.order_layout.addWidget(widget)

        # Обновление области прокрутки
        self.order_container.adjustSize()
        self.scrollArea.update()

def main():
    conn = pg.connect(
        host="localhost",
        port="5432",
        dbname="CKeeper",
        user="postgres",
        password="raiderfeed08032005"
    )

    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    MainWindow.resize(900, 600)
    ui = UI_MainWindow(conn)
    ui.setup_ui(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())
    
    # Закрываем соединение после завершения работы приложения
    conn.close()

if __name__ == "__main__":
    main()
