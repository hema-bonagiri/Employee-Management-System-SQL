-- Employee Management System
/*
Problem Statement:
The objective of this project is to design and implement an Employee Management System that efficiently stores and manages employee-related data within an organization. 
The system needs to track various aspects of employee information, including personal details, job roles, salary structures, qualifications, leave records, and payroll data. 
The system should ensure the integrity and consistency of data by using relational tables with appropriate foreign keys and cascading actions.
The system should allow for easy management and querying of employee data, providing insights such as payroll calculation, leave tracking, and department-specific job roles. 
The goal is to streamline HR operations, ensuring that all relevant employee data is accessible and accurately updated across different modules.

Table names and Description
1. JobDepartment
Stores job roles, departments, and related salary ranges
2. SalaryBonus	
Contains salary, bonus, and annual pay linked to specific job roles.
3. Employee
Maintains personal, contact, and login details of all employees.
4. Qualification	
stores Records qualifications and required skills for employee job positions.
5. Leaves	
Tracks employee leave records with reasons and dates.
6. Payroll	
It Combines employee, job, salary, and leave data to calculate net payments.
*/
-- Create Database
create database emp_mgmt_system;
use emp_mgmt_system;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from JobDepartment;
select * from salarybonus;
select * from employee;
select * from qualification;
select * from leaves;
select * from payroll;

-- Analysis Questions
-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
select  count(distinct emp_id) Total_Employees 
from employee;

-- Which departments have the highest number of employees?
select jd.jobdept Department,count(e.emp_id) Total_Employees
from jobdepartment jd
join employee e 
on jd.job_id = e.job_id
group by jd.jobdept
order by Total_Employees desc
limit 5;		-- top 5 departments, having highest number of employees

-- What is the average salary per department?
select jd.jobdept Department,round(avg(sb.amount),2) Average_Salary
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by Average_Salary desc;

-- Who are the top 5 highest-paid employees?
select concat(e.firstname,' ',e.lastname) Employee_name,jd.jobdept,sb.amount
from employee e
join jobdepartment jd
on e.job_id=jd.job_id
join salarybonus sb
on jd.job_id = sb.job_id
order by sb.amount desc
limit 5;

-- What is the total salary expenditure across the company?
select sum(sb.amount) total_salary_expenditure
from employee e
join salarybonus sb
on e.job_id=sb.job_id;


-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
select jobdept Department,count(distinct name) Total_Job_Roles
from jobdepartment 
group by jobdept
order by total_job_roles desc;

-- What is the average salary range per department?
select jd.jobdept,min(sb.amount) Min_Salary,max(sb.amount) Max_Salary
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by Min_Salary desc;

-- Which job roles offer the highest salary?
select jd.name Role_Name,sb.amount Salary
from jobdepartment jd
join salarybonus sb
on jd.job_id = sb.job_id
order by sb.amount desc
limit 10;

-- Which departments have the highest total salary allocation?
select jd.jobdept Department,sum(sb.amount) Total_Salary
from employee e 
join jobdepartment jd 
on e.job_id=jd.job_id
join salarybonus sb
on jd.job_id=sb.job_id
group by jd.jobdept
order by Total_Salary desc;


-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
select count(distinct emp_id) Qualified_Employees 
from qualification;

-- Which positions require the most qualifications?
select position,count(*) total_qualifications
from qualification
group by position
order by total_qualifications desc;

-- Which employees have the highest number of qualifications?
select concat(e.firstname,' ',e.lastname) Employee_Name,count(q.QualID) Qualification_Count
from employee e
join qualification q
on e.emp_id=q.emp_id
group by e.emp_id,e.firstname,e.lastname
order by Qualification_Count desc;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
select year(date) year ,count(distinct emp_id) Employees_on_Leave
from leaves
group by year(date)
order by Employees_on_Leave desc;

-- What is the average number of leave days taken by its employees per department?
select jd.jobdept,round(count(l.leave_id)/count(distinct e.emp_id),2) Avg_leaves
from employee e
join jobdepartment jd 
on e.job_id = jd.job_id
left join leaves l
on e.emp_id=l.emp_id
group by jd.jobdept;

-- Which employees have taken the most leaves?
select concat(e.firstname,' ',e.lastname) Employee_name,count(l.leave_id) leave_count
from employee e
join leaves l
on e.emp_id = l.emp_id 
group by e.emp_id,Employee_name
order by leave_count desc;

-- What is the total number of leave days taken company-wide?
select
count(*) AS Total_Leave_Days
from leaves;

-- How do leave days correlate with payroll amounts?
select concat(e.firstname,' ',e.lastname) Employee_name,count(l.leave_id) leave_count,p.total_amount 
from employee e
left join leaves l
on e.emp_id = l.emp_id
left join payroll p
on e.emp_id = p.emp_id
group by e.emp_id,e.firstname,e.lastname,p.total_amount
order by leave_count desc,p.total_amount;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
select date_format(date,'%Y-%m') Month,sum(total_amount) Monthly_payroll
from payroll
group by Month
order by Month;

-- What is the average bonus given per department?
select jd.jobdept,round(avg(sb.bonus),2) Average_Bonus
from salarybonus sb
join jobdepartment jd
on sb.job_id=jd.job_id
group by jd.jobdept
order by Average_Bonus desc;

-- Which department receives the highest total bonuses?
select jd.jobdept,sum(sb.bonus) Total_Bonus
from salarybonus sb
join jobdepartment jd
on sb.job_id=jd.job_id
group by jd.jobdept
order by Total_Bonus desc;

-- What is the average value of total_amount after considering leave deductions?
select round(avg(total_amount),2) Average_Total_Amount
from payroll;



