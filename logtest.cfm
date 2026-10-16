
<cfscript>
setting showdebugoutput=false;
cfcontent(type="application/json; charset=utf-8", reset=true);

event = {
    "application": "Employee Hub",
    "event": "health_check",
    "status": "success",
    "timestamp": dateTimeFormat(
        now(), "yyyy-mm-dd'T'HH:nn:ss"
    )
};

writeLog(
    file="employeehub",
    type="information",
    text=serializeJSON(event)
);

writeOutput(serializeJSON({
    "message": "Event logged successfully",
    "event": event.event
}));
</cfscript>
