import sys
import os
from PyQt5 import QtWidgets
from _contructors.kit_build import create_ui

def main():
    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    MainWindow.resize(800, 600)
    create_ui(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()