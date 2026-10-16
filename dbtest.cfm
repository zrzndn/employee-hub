
<cftry>
    <cfquery name="employeeQuery" datasource="employeesDB">
        SELECT id, name, email, department
        FROM employees
    </cfquery>

    <h1>Database Connection Successful!</h1>

    <cfoutput query="employeeQuery">
        <p>#name# — #email# — #department#</p>
    </cfoutput>

    <cfcatch>
        <h1>Database connection failed</h1>
        <cfdump var="#cfcatch.message#">
    </cfcatch>
</cftry>
