
<!--- Only accept deletion requests submitted using POST. --->
<cfif CGI.REQUEST_METHOD NEQ "POST">
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<cfparam name="form.employeeId" default="0">
<cfset employeeId = val(form.employeeId)>

<!--- Validate the employee ID. --->
<cfif employeeId LTE 0>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<!--- Delete only the selected employee. --->
<cfquery datasource="employeesDB">
    DELETE FROM employees
    WHERE id = <cfqueryparam
        value="#employeeId#"
        cfsqltype="cf_sql_integer">
</cfquery>

<!--- Return to the directory with a success message. --->
<cflocation url="index.cfm?deleted=1" addtoken="false">
