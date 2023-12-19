CREATE TABLE employees (
  employee_id NUMBER(6) NOT NULL,
  last_name VARCHAR2(255) NOT NULL,
  first_name VARCHAR2(255) NOT NULL,
  birth_date DATE NOT NULL,
  gender CHAR(1) NOT NULL,
  department_id NUMBER(6) NOT NULL,
  job_id VARCHAR2(255) NOT NULL,
  salary NUMBER(8,2) NOT NULL,
  hire_date DATE NOT NULL,
  last_day DATE,
  PRIMARY KEY (employee_id)
);
CREATE TABLE departments (
  department_id NUMBER(6) NOT NULL,
  department_name VARCHAR2(255) NOT NULL,
  manager_id NUMBER(6) NOT NULL,
  location VARCHAR2(255) NOT NULL,
  PRIMARY KEY (department_id)
);

create user ADMIN;
grant DBA to admin;

drop role hr_manager;
drop role department_manager;
INSERT INTO employees (employee_id, last_name, first_name, birth_date, gender, department_id, job_id, salary, hire_date, last_day)
VALUES (8000, 'Nguyen', 'Van', '2000-01-02', 'M', 30, 'SALESMAN', 1500, '2000-01-20', NULL);
INSERT INTO departments (department_id, department_name, manager_id, location)
VALUES (40, 'IT', 7839, 'Redwood Shores');

create role HR_MANAGER;
grant select on EMPLOYEES to hr_manager;
grant select on departments to hr_manager;
grant hr_manager to A;

CREATE ROLE department_manager;
grant select on hr.employees to hr_manager
GRANT SELECT, UPDATE ON DEPARTMENTS TO hr_manager;
GRANT hr_manager TO B;

revoke hr_manager from B;

select * from hr.employees;

