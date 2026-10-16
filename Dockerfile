FROM lucee/lucee:6.2

RUN mkdir -p /var/www/employees
COPY index.cfm /var/www/employees/index.cfm
COPY Application.cfc /var/www/employees/Application.cfc
COPY dbtest.cfm /var/www/employees/dbtest.cfm
COPY add.cfm /var/www/employees/add.cfm
COPY edit.cfm /var/www/employees/edit.cfm
COPY delete.cfm /var/www/employees/delete.cfm