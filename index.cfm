
<cfquery name="employeeQuery" datasource="employeesDB">
    SELECT id, name, email, COALESCE(department, '') AS department, created_at
    FROM employees
    ORDER BY id DESC
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Hub</title>

    <style>
        * {
            box-sizing: border-box;
        }

        :root {
            --navy: #15243a;
            --blue: #4169e1;
            --blue-light: #edf2ff;
            --background: #f5f7fb;
            --text: #172338;
            --muted: #778198;
            --border: #e8ecf3;
            --white: #ffffff;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: var(--background);
            color: var(--text);
        }

        .layout {
            min-height: 100vh;
            display: flex;
        }

        /* Sidebar */

        .sidebar {
            width: 235px;
            background: var(--navy);
            color: white;
            padding: 30px 18px;
            flex-shrink: 0;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 11px;
            padding: 0 10px 38px;
            font-size: 19px;
            font-weight: 700;
            letter-spacing: -0.4px;
        }

        .brand-icon {
            display: grid;
            place-items: center;
            width: 36px;
            height: 36px;
            border-radius: 11px;
            background: var(--blue);
            font-size: 16px;
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

        .nav-link.active {
            background: #293d5d;
            color: white;
        }

        .nav-link:hover {
            background: #243754;
            color: white;
        }

        .sidebar-note {
            margin: 40px 8px 0;
            padding: 14px;
            border: 1px solid #34445d;
            border-radius: 10px;
            color: #b9c5d7;
            font-size: 12px;
            line-height: 1.6;
        }

        /* Main layout */

        .main {
            flex: 1;
            min-width: 0;
            padding: 32px 40px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            margin-bottom: 38px;
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

        /* Welcome banner */

        .welcome {
            background: linear-gradient(115deg, #243d72, #4169e1);
            color: white;
            border-radius: 17px;
            padding: 27px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 24px;
            box-shadow: 0 10px 28px rgba(43, 75, 155, 0.12);
        }

        .welcome h2 {
            font-size: 21px;
            margin: 0 0 8px;
        }

        .welcome p {
            font-size: 13px;
            color: #e0e8ff;
            margin: 0;
            line-height: 1.6;
        }

        .welcome-mark {
            font-size: 52px;
            opacity: 0.85;
            padding: 0 14px;
        }

        /* Statistics */

        .stats {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 27px;
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 13px;
            padding: 21px;
        }

        .stat-label {
            color: var(--muted);
            font-size: 12px;
            font-weight: 600;
        }

        .stat-value {
            margin-top: 12px;
            font-size: 29px;
            font-weight: 700;
            letter-spacing: -1px;
        }

        .stat-foot {
            color: var(--muted);
            font-size: 11px;
            margin-top: 6px;
        }

        /* Employee table card */

        .content-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 14px;
            overflow: hidden;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 23px 24px;
            border-bottom: 1px solid var(--border);
        }

        .card-header h2 {
            font-size: 17px;
            margin: 0 0 5px;
        }

        .card-header p {
            font-size: 12px;
            color: var(--muted);
            margin: 0;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .search {
            width: 220px;
            max-width: 100%;
            padding: 10px 12px;
            border: 1px solid #dce2ec;
            border-radius: 8px;
            font-size: 12px;
            outline: none;
        }

        .search:focus {
            border-color: var(--blue);
            box-shadow: 0 0 0 3px #4169e11c;
        }

        .btn {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
            background: var(--blue);
            color: white;
            text-decoration: none;
            padding: 11px 15px;
            border: 0;
            border-radius: 8px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
        }

        .btn:hover {
            background: #3156cc;
        }

        /* Table */

        .table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            white-space: nowrap;
        }

        th {
            background: #fafbfe;
            color: #7a859a;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            padding: 15px 22px;
        }

        td {
            padding: 17px 22px;
            border-top: 1px solid #edf0f5;
            font-size: 12px;
            color: #566176;
        }

        tbody tr:hover {
            background: #fafbff;
        }

        .employee-cell {
            display: flex;
            align-items: center;
            gap: 11px;
        }

        .employee-avatar {
            width: 35px;
            height: 35px;
            flex-shrink: 0;
            display: grid;
            place-items: center;
            border-radius: 10px;
            background: var(--blue-light);
            color: #3455c4;
            font-size: 12px;
            font-weight: 700;
        }

        .employee-name {
            color: var(--text);
            font-weight: 650;
            font-size: 12px;
        }

        .employee-id {
            color: #909aae;
            font-size: 10px;
            margin-top: 4px;
        }

        .department {
            display: inline-block;
            background: #f0f3f8;
            color: #566176;
            border-radius: 6px;
            padding: 6px 9px;
            font-size: 11px;
        }

        /* Edit and Delete actions */

        .actions {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .edit-link {
            color: var(--blue);
            text-decoration: none;
            font-weight: 650;
            font-size: 12px;
        }

        .edit-link:hover {
            text-decoration: underline;
        }

        .delete-form {
            margin: 0;
        }

        .delete-btn {
            background: #fff0f0;
            color: #bd3636;
            border: 1px solid #f3d0d0;
            border-radius: 7px;
            padding: 7px 10px;
            font: inherit;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
        }

        .delete-btn:hover {
            background: #ffe0e0;
        }

        .delete-btn:focus-visible,
        .edit-link:focus-visible,
        .btn:focus-visible {
            outline: 3px solid #93aaff;
            outline-offset: 3px;
        }

        /* Success message */

        .flash-success {
            margin-bottom: 18px;
            padding: 13px 15px;
            border: 1px solid #c7ecd6;
            border-radius: 8px;
            color: #176b43;
            background: #eaf8f0;
            font-size: 13px;
        }

        /* Empty state */

        .empty-state {
            text-align: center;
            padding: 50px 20px;
        }

        .empty-icon {
            font-size: 32px;
            margin-bottom: 13px;
        }

        .empty-state h3 {
            font-size: 16px;
            margin: 0 0 8px;
        }

        .empty-state p {
            font-size: 12px;
            color: var(--muted);
            margin: 0 0 20px;
        }

        .footer {
            text-align: center;
            padding: 25px 10px 0;
            color: #939db0;
            font-size: 11px;
        }

        /* Responsive layout */

        @media (max-width: 1100px) {
            .main {
                padding: 25px 22px;
            }

            .sidebar {
                width: 205px;
            }

            .card-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .header-actions {
                width: 100%;
            }

            .search {
                flex: 1;
            }
        }

        @media (max-width: 900px) {
            .stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 620px) {
            .layout {
                display: block;
            }

            .sidebar {
                width: 100%;
                padding: 15px;
            }

            .brand {
                padding: 0 5px 14px;
            }

            .nav-label,
            .sidebar-note {
                display: none;
            }

            .nav-link {
                display: inline-block;
                margin: 0 5px 0 0;
                padding: 9px 12px;
            }

            .main {
                padding: 22px 14px;
            }

            .topbar {
                margin-bottom: 24px;
            }

            h1 {
                font-size: 24px;
            }

            .profile span {
                display: none;
            }

            .welcome {
                padding: 23px 20px;
            }

            .welcome-mark {
                display: none;
            }

            .stats {
                grid-template-columns: 1fr;
                gap: 10px;
            }

            .header-actions {
                align-items: stretch;
                flex-direction: column;
            }

            .search,
            .header-actions .btn {
                width: 100%;
            }

            .actions {
                gap: 10px;
            }
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

        <a class="nav-link active" href="index.cfm">
            ▦ &nbsp; Employee Directory
        </a>

        <a class="nav-link" href="add.cfm">
            ＋ &nbsp; Add Employee
        </a>

        <div class="sidebar-note">
            <strong>Employee Hub</strong><br>
            A simple workspace for managing your employee records.
        </div>
    </aside>

    <main class="main">

        <header class="topbar">
            <div>
                <div class="eyebrow">Workspace / People</div>
                <h1>Employee Directory</h1>
            </div>

            <div class="profile">
                <div class="avatar">EH</div>
                <span>Administration</span>
            </div>
        </header>

        <section class="welcome">
            <div>
                <h2>People make the business.</h2>
                <p>
                    View your team, manage employee details,
                    and keep your directory up to date.
                </p>
            </div>
            <div class="welcome-mark">✳</div>
        </section>

        <section class="stats">
            <div class="stat-card">
                <div class="stat-label">TOTAL EMPLOYEES</div>
                <div class="stat-value">
                    <cfoutput>#employeeQuery.recordCount#</cfoutput>
                </div>
                <div class="stat-foot">Records in your directory</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">DATA SOURCE</div>
                <div class="stat-value" style="font-size:22px;">MySQL</div>
                <div class="stat-foot">Connected through Lucee</div>
            </div>

            <div class="stat-card">
                <div class="stat-label">APPLICATION</div>
                <div class="stat-value" style="font-size:22px;">Online</div>
                <div class="stat-foot">Employee Hub workspace</div>
            </div>
        </section>W
        <!-- Show a message after a successful deletion -->
        <cfif structKeyExists(url, "deleted") AND url.deleted EQ "1">
            <div class="flash-success">
                Employee deleted successfully.
            </div>
        </cfif>

        <section class="content-card">

            <div class="card-header">
                <div>
                    <h2>All Employees</h2>
                    <p>Manage and review your employee records.</p>
                </div>

                <div class="header-actions">
                    <input
                        id="employeeSearch"
                        class="search"
                        type="search"
                        placeholder="Search employees..."
                        aria-label="Search employees">

                    <a class="btn" href="add.cfm">＋ Add Employee</a>
                </div>
            </div>

            <cfif employeeQuery.recordCount EQ 0>

                <div class="empty-state">
                    <div class="empty-icon">♙</div>
                    <h3>Your directory is waiting</h3>
                    <p>Add your first employee to get started.</p>
                    <a class="btn" href="add.cfm">
                        ＋ Add your first employee
                    </a>
                </div>

            <cfelse>

                <div class="table-wrap">
                    <table id="employeeTable">

                        <thead>
                            <tr>
                                <th>Employee</th>
                                <th>Email</th>
                                <th>Department</th>
                                <th>Date Added</th>
                                <th>Actions</th>
                            </tr>
                        </thead>

                        <tbody>
                            <cfoutput query="employeeQuery">
                                <tr data-employee-row>
                                    <td>
                                        <div class="employee-cell">
                                            <div class="employee-avatar">#encodeForHTML(left(trim(name), 1))#</div>

                                            <div>
                                                <div class="employee-name">
                                                    #encodeForHTML(name)#
                                                </div>

                                                <div class="employee-id">
                                                    ID: #id#
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>#encodeForHTML(email)#</td>

                                    <td>
                                        <span class="department">
                                            <cfif len(trim(department))>
                                                #encodeForHTML(department)#
                                            <cfelse>
                                                Not assigned
                                            </cfif>
                                        </span>
                                    </td>

                                    <td>
                                        #dateTimeFormat(created_at, "dd mmm yyyy")#
                                    </td>

                                    <td>
                                        <div class="actions">

                                            <a
                                                class="edit-link"
                                                href="edit.cfm?id=#id#">
                                                Edit ↗
                                            </a>

                                            <form
                                                class="delete-form"
                                                method="post"
                                                action="delete.cfm"
                                                onsubmit="return confirm('Are you sure you want to permanently delete this employee?');">

                                                <input
                                                    type="hidden"
                                                    name="employeeId"
                                                    value="#id#">

                                                <button
                                                    class="delete-btn"
                                                    type="submit">
                                                    Delete
                                                </button>
                                            </form>

                                        </div>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </table>
                </div>

                <div
                    id="noSearchResults"
                    style="display:none; padding:30px; text-align:center; color:#778198; font-size:13px;">
                    No matching employees found.
                </div>

            </cfif>

        </section>

        <footer class="footer">
            Employee Hub &middot; Powered by CFML, Lucee, Docker and MySQL
        </footer>

    </main>
</div>

<script>
    const searchInput = document.getElementById("employeeSearch");
    const employeeRows = document.querySelectorAll("[data-employee-row]");
    const noResults = document.getElementById("noSearchResults");

    if (searchInput) {
        searchInput.addEventListener("input", function () {
            const term = this.value.trim().toLowerCase();
            let visibleCount = 0;

            employeeRows.forEach(function (row) {
                const matches = row.textContent.toLowerCase().includes(term);

                row.style.display = matches ? "" : "none";

                if (matches) {
                    visibleCount++;
                }
            });

            if (noResults) {
                noResults.style.display =
                    visibleCount === 0 ? "block" : "none";
            }
        });
    }
</script>

</body>
</html>
