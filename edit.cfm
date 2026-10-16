
<cfparam name="url.id" default="0">
<cfset employeeId = val(url.id)>
<cfset message = "">
<cfset messageType = "">

<cfif employeeId LTE 0>
    <h1>Invalid employee ID</h1>
    <p><a href="index.cfm">Back to directory</a></p>
    <cfabort>
</cfif>

<cfquery name="employeeQuery" datasource="employeesDB">
    SELECT id, name, email, COALESCE(department, '') AS department
    FROM employees
    WHERE id = <cfqueryparam value="#employeeId#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif employeeQuery.recordCount EQ 0>
    <h1>Employee not found</h1>
    <p><a href="index.cfm">Back to directory</a></p>
    <cfabort>
</cfif>

<cfparam name="form.name" default="#employeeQuery.name#">
<cfparam name="form.email" default="#employeeQuery.email#">
<cfparam name="form.department" default="#employeeQuery.department#">

<cfif structKeyExists(form, "saveEmployee")>
    <cfset employeeName = trim(form.name)>
    <cfset employeeEmail = trim(form.email)>
    <cfset employeeDepartment = trim(form.department)>

    <cfif NOT len(employeeName) OR NOT len(employeeEmail)>
        <cfset message = "Please enter the employee's name and email address.">
        <cfset messageType = "error">

    <cfelseif len(employeeName) GT 100
        OR len(employeeEmail) GT 150
        OR len(employeeDepartment) GT 100>
        <cfset message = "One or more fields exceed the allowed length.">
        <cfset messageType = "error">

    <cfelseif NOT isValid("email", employeeEmail)>
        <cfset message = "Please enter a valid email address.">
        <cfset messageType = "error">

    <cfelse>
        <cftry>
            <cfquery datasource="employeesDB">
                UPDATE employees
                SET
                    name = <cfqueryparam value="#employeeName#" cfsqltype="cf_sql_varchar" maxlength="100">,
                    email = <cfqueryparam value="#employeeEmail#" cfsqltype="cf_sql_varchar" maxlength="150">,
                    department = <cfqueryparam value="#employeeDepartment#" cfsqltype="cf_sql_varchar" maxlength="100">
                WHERE id = <cfqueryparam value="#employeeId#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset message = "Employee details updated successfully!">
            <cfset messageType = "success">

            <cfcatch type="any">
                <cfset message = "Unable to update this employee. Please check the application logs.">
                <cfset messageType = "error">
            </cfcatch>
        </cftry>
    </cfif>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Employee | Employee Hub</title>

    <style>
        * { box-sizing: border-box; }

        :root {
            --navy: #15243a;
            --blue: #4169e1;
            --background: #f5f7fb;
            --text: #172338;
            --muted: #778198;
            --border: #e6ebf3;
            --white: #ffffff;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: var(--background);
            color: var(--text);
        }

        .layout { min-height: 100vh; display: flex; }

        .sidebar {
            width: 235px;
            flex-shrink: 0;
            background: var(--navy);
            color: white;
            padding: 30px 18px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 11px;
            padding: 0 10px 38px;
            font-size: 19px;
            font-weight: 700;
        }

        .brand-icon {
            display: grid;
            place-items: center;
            width: 36px;
            height: 36px;
            border-radius: 11px;
            background: var(--blue);
        }

        .nav-label {
            color: #98a7bf;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 1.5px;
            padding: 0 12px;
            margin-bottom: 12px;
        }

        .nav-link {
            display: block;
            color: #cbd4e3;
            text-decoration: none;
            padding: 12px;
            margin-bottom: 7px;
            border-radius: 9px;
            font-size: 14px;
        }

        .nav-link.active, .nav-link:hover {
            background: #293d5d;
            color: white;
        }

        .sidebar-note {
            margin: 40px 8px 0;
            padding: 14px;
            border: 1px solid #34445d;
            border-radius: 10px;
            color: #b9c5d7;
            font-size: 12px;
            line-height: 1.7;
        }

        .main {
            flex: 1;
            min-width: 0;
            padding: 32px 40px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 35px;
        }

        .eyebrow {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: var(--muted);
            margin-bottom: 7px;
        }

        h1 {
            font-size: 29px;
            letter-spacing: -1px;
            margin: 0;
        }

        .profile {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            color: #566176;
        }

        .avatar {
            display: grid;
            place-items: center;
            width: 39px;
            height: 39px;
            border-radius: 50%;
            background: #dfe7ff;
            color: #3557c7;
            font-weight: 700;
        }

        .intro { margin-bottom: 24px; }

        .intro h2 {
            font-size: 20px;
            margin: 0 0 8px;
        }

        .intro p {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.6;
            margin: 0;
        }

        .form-card {
            max-width: 850px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 15px;
            overflow: hidden;
        }

        .card-header {
            padding: 23px 27px;
            border-bottom: 1px solid var(--border);
        }

        .card-header h3 {
            margin: 0 0 6px;
            font-size: 16px;
        }

        .card-header p {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
        }

        .form-body { padding: 27px; }

        .notice {
            padding: 13px 15px;
            border-radius: 8px;
            margin-bottom: 22px;
            font-size: 13px;
            line-height: 1.5;
        }

        .notice.success {
            color: #176b43;
            background: #eaf8f0;
            border: 1px solid #c7ecd6;
        }

        .notice.error {
            color: #a33131;
            background: #fff0f0;
            border: 1px solid #f5d0d0;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
        }

        .field { min-width: 0; }
        .field.full { grid-column: 1 / -1; }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 12px;
            font-weight: 650;
            color: #344158;
        }

        .required { color: #d04444; }

        input {
            width: 100%;
            padding: 12px 13px;
            color: var(--text);
            border: 1px solid #dce2ec;
            border-radius: 8px;
            font: inherit;
            font-size: 13px;
            background: white;
            outline: none;
        }

        input:focus {
            border-color: var(--blue);
            box-shadow: 0 0 0 3px #4169e11c;
        }

        input::placeholder { color: #a2aabc; }

        .help {
            margin-top: 7px;
            color: var(--muted);
            font-size: 11px;
        }

        .form-actions {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-top: 30px;
            padding-top: 23px;
            border-top: 1px solid var(--border);
        }

        .back-link {
            text-decoration: none;
            color: #647087;
            font-size: 12px;
            font-weight: 600;
        }

        .back-link:hover { color: var(--blue); }

        .btn {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            gap: 7px;
            padding: 12px 17px;
            border: 0;
            border-radius: 8px;
            background: var(--blue);
            color: white;
            text-decoration: none;
            cursor: pointer;
            font-size: 12px;
            font-weight: 650;
        }

        .btn:hover { background: #3156cc; }

        .footer {
            max-width: 850px;
            text-align: center;
            padding: 25px 10px;
            color: #939db0;
            font-size: 11px;
        }

        @media (max-width: 800px) {
            .sidebar { width: 190px; }
            .main { padding: 25px 22px; }
        }

        @media (max-width: 600px) {
            .layout { display: block; }
            .sidebar { width: 100%; padding: 15px; }
            .brand { padding: 0 5px 14px; }
            .nav-label, .sidebar-note { display: none; }

            .nav-link {
                display: inline-block;
                margin: 0 5px 0 0;
                padding: 9px 12px;
            }

            .main { padding: 22px 14px; }
            h1 { font-size: 24px; }
            .profile span { display: none; }

            .form-grid { grid-template-columns: 1fr; gap: 19px; }
            .field.full { grid-column: auto; }
            .form-body { padding: 20px; }
            .card-header { padding: 20px; }

            .form-actions {
                align-items: stretch;
                flex-direction: column-reverse;
            }

            .btn { width: 100%; }
            .back-link { text-align: center; padding: 8px; }
        }
    </style>
</head>

<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-icon">EH</div>
            <span>Employee Hub</span>
        </div>

        <div class="nav-label">WORKSPACE</div>
        <a class="nav-link" href="index.cfm">▦ &nbsp; Employee Directory</a>
        <a class="nav-link" href="add.cfm">＋ &nbsp; Add Employee</a>

        <div class="sidebar-note">
            <strong>Employee Hub</strong><br>
            Manage your employee records in one place.
        </div>
    </aside>

    <main class="main">
        <header class="topbar">
            <div>
                <div class="eyebrow">Workspace / People / Edit record</div>
                <h1>Edit Employee</h1>
            </div>

            <div class="profile">
                <div class="avatar">EH</div>
                <span>Administration</span>
            </div>
        </header>

        <section class="intro">
            <h2>Update employee information</h2>
            <p>Make changes to this employee's details, then save your updates.</p>
        </section>

        <section class="form-card">
            <div class="card-header">
                <h3>Employee information</h3>
                <cfoutput>
                    <p>Employee ID: #employeeId#</p>
                </cfoutput>
            </div>

            <div class="form-body">
                <cfif len(message)>
                    <cfoutput>
                        <div class="notice #messageType#">
                            #encodeForHTML(message)#
                            <cfif messageType EQ "success">
                                <a href="index.cfm"
                                   style="color:inherit;font-weight:700;margin-left:6px;">
                                    View directory
                                </a>
                            </cfif>
                        </div>
                    </cfoutput>
                </cfif>

                <form method="post" action="edit.cfm?id=<cfoutput>#employeeId#</cfoutput>">
                    <div class="form-grid">
                        <div class="field">
                            <label for="name">
                                Full name <span class="required">*</span>
                            </label>
                            <cfoutput>
                                <input
                                    type="text"
                                    id="name"
                                    name="name"
                                    maxlength="100"
                                    value="#encodeForHTMLAttribute(form.name)#"
                                    autocomplete="name"
                                    required>
                            </cfoutput>
                        </div>

                        <div class="field">
                            <label for="email">
                                Email address <span class="required">*</span>
                            </label>
                            <cfoutput>
                                <input
                                    type="email"
                                    id="email"
                                    name="email"
                                    maxlength="150"
                                    value="#encodeForHTMLAttribute(form.email)#"
                                    autocomplete="email"
                                    required>
                            </cfoutput>
                        </div>

                        <div class="field full">
                            <label for="department">Department</label>
                            <cfoutput>
                                <input
                                    type="text"
                                    id="department"
                                    name="department"
                                    maxlength="100"
                                    value="#encodeForHTMLAttribute(form.department)#">
                            </cfoutput>
                            <div class="help">Optional — you can leave this blank.</div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a class="back-link" href="index.cfm">← Back to directory</a>
                        <button class="btn" type="submit" name="saveEmployee" value="1">
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </section>

        <footer class="footer">
            Employee Hub &middot; Powered by CFML, Lucee, Docker and MySQL
        </footer>
    </main>
</div>
</body>
</html>
