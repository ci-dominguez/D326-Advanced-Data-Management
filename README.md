# D326-Adv-Data-Management

Project is using the [<u style="color:skyblue">PostgreSQL Sample DB</u>](https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/)

### A. Summarize one real-world written business report that can be created from the DVD Dataset from the “Labs on Demand Assessment Environment and DVD Database” attachment.

The DVD rental store wants to identify which films hold the highest rentals in order to optimize their inventory management and selection based on the customer demand.

### A1. Identify the specific fields that will be included in the detailed table and the summary table of the report.

<span style="color:lightgreen">Detailed Table: **rental_duration_tracker**<span>

| Column          |  Data Type   |
| :-------------- | :----------: |
| rental_id\*     |     Int      |
| film_id         |     Int      |
| film_title      | Varchar(255) |
| rental_duration |    Float     |
| rental_date     |  Timestamp   |
| return_date     |  Timestamp   |

<br/>

<span style="color:lightgreen">Summary Table: **rental_duration_trends**<span>

| Column              |  Data Type   |
| :------------------ | :----------: |
| film_id\*           |     Int      |
| film_title          | Varchar(255) |
| avg_rental_duration |   VARCHAR    |
| total_rentals       |     Int      |

<br/>

### A2. Describe the types of data fields used for the report.

- INTEGER: rental_id, film_id, total_rentals
- TIMESTAMP: rental_date, return_date
- VARCHAR: film_title, avg_rental_duration
- FLOAT: rental_duration

<br/>

### A3. Identify at least two specific tables from the given dataset that will provide the data necessary for the detailed table section and the summary table section of the report.

- **Rental Table**: This contains transaction details including inventory IDs as well as rental and return dates.

- **Inventory Table**: Contains the details such as what amount of inventory correlates to each film ID.

- **Film Table**: We can find the ID and title of the films rented.

<br/>

### A4. Identify at least one field in the detailed table section that will require a custom transformation with a user-defined function and explain why it should be transformed (e.g., you might translate a field with a value of N to No and Y to Yes).

The rental duration in the detailed table will require a custom transformation. The field represents the duration of each rental transaction which is calculated as the difference between the return and rental dates. We’d get a numeric value from that calculation, so for readability we would transform a calculation of 3.5 to 3 hours and 30 minutes

<br/>

### A5. Explain the different business uses of the detailed table section and the summary table section of the report.

The detailed table would assist in analyzing and identifying trends in rental behavior. The summary table would provide an overview of those average trends per film. Both tables would work together in directing inventory management decisions.

<br/>

### A6. Explain how frequently your report should be refreshed to remain relevant to stakeholders.

The report has flexibility to be on a weekly or monthly schedule. A weekly refresh would provide insight into the day-to-day habits of their customers. And a monthly overview would assist in the decisions to increase or decrease inventory of their film selection. This would ensure that any stakeholder will have access to the up to date data on rental trends.

<br/>

### B. Provide original code for function(s) in text format that perform the transformation(s) you identified in part A4.

<span style="color:lime">In proj.sql</span>

<br/>

### C. Provide original SQL code in a text format that creates the detailed and summary tables to hold your report table sections.

<span style="color:lime">In proj.sql</span>

<br/>

### D. Provide an original SQL query in a text format that will extract the raw data needed for the detailed section of your report from the source database.

<span style="color:lime">In proj.sql</span>

<br/>

### E. Provide original SQL code in a text format that creates a trigger on the detailed table of the report that will continually update the summary table as data is added to the detailed table.

<span style="color:lime">In proj.sql</span>

<br/>

### F. Provide an original stored procedure in a text format that can be used to refresh the data in both the detailed table and summary table. The procedure should clear the contents of the detailed table and summary table and perform the raw data extraction from part D.

<span style="color:lime">In proj.sql</span>

<br/>

### F1. Identify a relevant job scheduling tool that can be used to automate the stored procedure.

Through my research I found pgAgent. Which is built by EDB, the same people who work on pgAdmin. Although it’s a separate application, pgAgent still functions as a scheduling tool for Postgres databases. Being in the same ecosystem of EDB products, there is a seamless integration between both pgAdmin and pgAgent.
