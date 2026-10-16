
<cfscript>
setting showdebugoutput=false;
cfcontent(type="application/json; charset=utf-8", reset=true);
cfheader(name="Cache-Control", value="no-store");



httpMethod = uCase(cgi.request_method);

if (httpMethod == "GET") {
    keyPath = "/opt/employeehub-secrets/read-key.txt";
} else if (httpMethod == "POST") {
    keyPath = "/opt/employeehub-secrets/write-key.txt";
} else {
    cfheader(statuscode=405, statustext="Method Not Allowed");
    cfheader(name="Allow", value="GET, POST");
    writeOutput(serializeJSON({
        "status": "error",
        "message": "Only GET and POST are supported."
    }));
    abort;
}

if (!fileExists(keyPath)) {
    cfheader(statuscode=500, statustext="Server Configuration Error");
    writeOutput(serializeJSON({
        "status": "error",
        "message": "API authentication is not configured."
    }));
    abort;
}

expectedKey = trim(fileRead(keyPath));

requestInfo = getHttpRequestData();
requestHeaders = requestInfo.headers;
providedKey = "";

for (headerName in requestHeaders) {
    if (compareNoCase(headerName, "X-API-Key") == 0) {
        providedKey = trim(toString(requestHeaders[headerName]));
        break;
    }
}

if (
    !len(expectedKey)
    || !len(providedKey)
    || compare(providedKey, expectedKey) != 0
) {
    cfheader(statuscode=401, statustext="Unauthorized");
    writeOutput(serializeJSON({
        "status": "error",
        "message": "Valid API key required."
    }));
    abort;
}


expectedKey = trim(fileRead(keyPath));
requestInfo = getHttpRequestData();
requestHeaders = requestInfo.headers;
providedKey = "";

for (headerName in requestHeaders) {
    if (compareNoCase(headerName, "X-API-Key") == 0) {
        providedKey = trim(toString(requestHeaders[headerName]));
        break;
    }
}

if (
    !len(expectedKey)
    || !len(providedKey)
    || compare(providedKey, expectedKey) != 0
) {
    cfheader(statuscode=401, statustext="Unauthorized");
    writeOutput(serializeJSON({
        "status": "error",
        "message": "Valid API key required."
    }));
    abort;
}


responseStatus = 200;
responseStatusText = "OK";
response = {};

try {
    method = uCase(cgi.request_method);

    if (method == "POST") {
        // Read and parse the incoming JSON body.
        parseOK = true;
        payload = {};

        try {
            requestData = getHttpRequestData();
            payload = deserializeJSON(
                toString(requestData.content)
            );
        } catch (any jsonError) {
            parseOK = false;
        }

        if (!parseOK) {
            responseStatus = 400;
            responseStatusText = "Bad Request";
            response = {
                "status": "error",
                "message": "Request body must contain valid JSON."
            };

        } else if (!isStruct(payload)) {
            responseStatus = 400;
            responseStatusText = "Bad Request";
            response = {
                "status": "error",
                "message": "JSON body must be an object."
            };

        } else if (
            !structKeyExists(payload, "name")
            || !structKeyExists(payload, "email")
            || !structKeyExists(payload, "department")
        ) {
            responseStatus = 400;
            responseStatusText = "Bad Request";
            response = {
                "status": "error",
                "message": "name, email and department are required."
            };

        } else if (
            !isSimpleValue(payload.name)
            || !isSimpleValue(payload.email)
            || !isSimpleValue(payload.department)
        ) {
            responseStatus = 400;
            responseStatusText = "Bad Request";
            response = {
                "status": "error",
                "message": "Fields must contain simple values."
            };

        } else {
            employeeName = trim(toString(payload.name));
            employeeEmail = trim(toString(payload.email));
            employeeDepartment = trim(toString(payload.department));

            if (
                !len(employeeName)
                || !len(employeeEmail)
                || !len(employeeDepartment)
            ) {
                responseStatus = 400;
                responseStatusText = "Bad Request";
                response = {
                    "status": "error",
                    "message": "Fields cannot be empty."
                };

            } else if (!isValid("email", employeeEmail)) {
                responseStatus = 400;
                responseStatusText = "Bad Request";
                response = {
                    "status": "error",
                    "message": "Provide a valid email address."
                };

            } else {
                insertMeta = {};

                queryExecute(
                    "INSERT INTO employees
                     (name, email, department)
                     VALUES
                     (:name, :email, :department)",
                    {
                        name: {
                            value: employeeName,
                            cfsqltype: "cf_sql_varchar"
                        },
                        email: {
                            value: employeeEmail,
                            cfsqltype: "cf_sql_varchar"
                        },
                        department: {
                            value: employeeDepartment,
                            cfsqltype: "cf_sql_varchar"
                        }
                    },
                    {
                        datasource: "employeesDB",
                        result: "insertMeta"
                    }
                );

                newEmployee = {
                    "name": employeeName,
                    "email": employeeEmail,
                    "department": employeeDepartment
                };

                if (
                    isStruct(insertMeta)
                    && structKeyExists(insertMeta, "generatedKey")
                ) {
                    newEmployee.id = insertMeta.generatedKey;
                }

                responseStatus = 201;
                responseStatusText = "Created";
                response = {
                    "status": "success",
                    "message": "Employee created.",
                    "data": newEmployee
                };
            }
        }

    } else if (method == "GET") {

        if (structKeyExists(url, "id")) {
            idValue = trim(url.id);

            if (
                !reFind("^[1-9][0-9]*$", idValue)
                || len(idValue) > 10
                || val(idValue) > 2147483647
            ) {
                responseStatus = 400;
                responseStatusText = "Bad Request";
                response = {
                    "status": "error",
                    "message": "ID must be a positive integer."
                };

            } else {
                result = queryExecute(
                    "SELECT id, name, email, department, created_at
                     FROM employees
                     WHERE id = :id",
                    {
                        id: {
                            value: val(idValue),
                            cfsqltype: "cf_sql_integer"
                        }
                    },
                    { datasource: "employeesDB" }
                );

                if (result.recordCount == 0) {
                    responseStatus = 404;
                    responseStatusText = "Not Found";
                    response = {
                        "status": "error",
                        "message": "Employee not found."
                    };
                } else {
                    response = {
                        "status": "success",
                        "data": {
                            "id": result.id[1],
                            "name": result.name[1],
                            "email": result.email[1],
                            "department": result.department[1],
                            "created_at": dateTimeFormat(
                                result.created_at[1],
                                "yyyy-mm-dd'T'HH:nn:ss"
                            )
                        }
                    };
                }
            }

        } else {
            sql = "
                SELECT id, name, email, department, created_at
                FROM employees
            ";
            params = {};

            if (
                structKeyExists(url, "department")
                && len(trim(url.department))
            ) {
                sql &= " WHERE department = :department";
                params.department = {
                    value: trim(url.department),
                    cfsqltype: "cf_sql_varchar"
                };
            }

            sql &= " ORDER BY id DESC";

            result = queryExecute(
                sql,
                params,
                { datasource: "employeesDB" }
            );

            employeeList = [];

            for (i = 1; i <= result.recordCount; i++) {
                arrayAppend(employeeList, {
                    "id": result.id[i],
                    "name": result.name[i],
                    "email": result.email[i],
                    "department": result.department[i],
                    "created_at": dateTimeFormat(
                        result.created_at[i],
                        "yyyy-mm-dd'T'HH:nn:ss"
                    )
                });
            }

            response = {
                "status": "success",
                "count": arrayLen(employeeList),
                "data": employeeList
            };
        }

    } else {
        responseStatus = 405;
        responseStatusText = "Method Not Allowed";
        response = {
            "status": "error",
            "message": "Only GET and POST are supported."
        };
    }

} catch (any e) {
    writeLog(
        file="employeehub",
        type="error",
        text="Employee API failed: " & e.type &
             " | " & e.message
    );

    responseStatus = 500;
    responseStatusText = "Internal Server Error";
    response = {
        "status": "error",
        "message": "Unable to process the request."
    };
}

cfheader(
    statuscode=responseStatus,
    statustext=responseStatusText
);

if (responseStatus == 405) {
    cfheader(name="Allow", value="GET, POST");
}

writeOutput(serializeJSON(response));
</cfscript>
