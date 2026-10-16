
component {
    this.name = "EmployeesApp";

    this.datasources["employeesDB"] = {
        class: "com.mysql.cj.jdbc.Driver",
        connectionString:
            "jdbc:mysql://host.docker.internal:3307/employees_db",
        username: "employees_app",
        password: server.system.environment.DB_PASSWORD
    };

    this.datasource = "employeesDB";
}
