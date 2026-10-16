
<cfscript>
setting showdebugoutput=false;
cfcontent(type="application/json; charset=utf-8", reset=true);

result = {
    "application": "Employee Hub",
    "status": "ok",
    "database": "connected",
    "timestamp": dateTimeFormat(
        now(), "yyyy-mm-dd'T'HH:nn:ss"
    )
};

try {
    queryExecute(
        "SELECT 1 AS db_ok",
        [],
        { datasource: "employeesDB" }
    );
} catch (any e) {
    result.status = "degraded";
    result.database = "unavailable";

    writeLog(
        file="employeehub",
        type="error",
        text="Health check database failure: " & e.message
    );

    cfheader(statuscode=503, statustext="Service Unavailable");
}

writeOutput(serializeJSON(result));
</cfscript>
