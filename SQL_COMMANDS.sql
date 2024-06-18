use Parks_and_Recreation;
select * from employee_demographics;
select * from employee_salary;
select gender, avg(age) from employee_demographics group by gender having avg(age)>40;
select dept_id,avg(salary) from employee_salary group by dept_id having avg(salary)>50000;
select occupation, avg(salary) from employee_salary where occupation like '%Director%'group by occupation having avg(salary)>30000;
select * from employee_demographics order by gender,age  ;
select * from employee_salary order by salary desc limit 5,5 ;

-- JOINS
select  d.employee_id,d.first_name,age from employee_demographics as d join employee_salary as s on d.employee_id = s.employee_id;
select  * from employee_demographics as d left join employee_salary as s on d.employee_id = s.employee_id;
select  * from employee_demographics as d right join employee_salary as s on d.employee_id = s.employee_id;
select  * from employee_salary as t1 join employee_salary as t2 on t1.employee_id+1 = t2.employee_id;
select  * from employee_demographics as d inner join employee_salary as s on d.employee_id = s.employee_id inner join parks_departments
 as pd on pd.department_id = s.dept_id;
 
 -- union
select first_name,last_name, 'OLD' as label  from employee_demographics where age>50 union select first_name,last_name,'HIGHLY PAID'
 as label from employee_salary where salary>50000;
select first_name, substring(first_name,3,2),birth_date,substring(birth_date,6,2) as birth_month from employee_demographics;
select first_name, lower(first_name) as lfname, replace(first_name,'a','*') from employee_demographics;
select first_name, locate('is',first_name) from employee_demographics;
select first_name, last_name, concat(first_name,' ', last_name) as Full_name from employee_demographics;

-- case 
select first_name, last_name, case when age<30   then 'You are Young' when age>30 then 'you are old' end as 'Age Bracket' from employee_demographics;

select first_name, last_name, salary,dept_id, case when dept_id = 6 then ((salary*0.10) + salary) 
 when salary > 50000 then ((salary*0.05) + salary) 
  when salary < 50000 then ((salary*0.07) + salary)    
  else 'No bonous'end as 'Bonous' 
  from employee_salary;

-- sub querry
select * 
from employee_demographics where employee_id IN 
(select employee_id from employee_salary where dept_id = 1)
;

select first_name, last_name,salary, avg(salary) as Average from employee_salary group by first_name, last_name, salary;

-- window function
select gender, avg(salary) from employee_demographics as d 
								 join employee_salary as s 
                                 on d.employee_id = s.employee_id 
                                 group by gender;
								
                                 
select d.first_name, d.Last_name,gender, avg(salary) over(partition by gender) from employee_demographics as d 
								 join employee_salary as s 
                                 on d.employee_id = s.employee_id ;           
-- ROLLING TOTAL                                 
select d.first_name, d.Last_name,gender,salary, sum(salary) over(partition by gender order by d.employee_id) as 'Rolling Total' from employee_demographics as d 
								 join employee_salary as s 
                                 on d.employee_id = s.employee_id ; 
-- CTE'S COMMON TABLE EXPRESSIONS -> THIS IS BASICALLY LIKE CREATING A LOCAL TABLE FROM ORIGINAL TABLE WITH COLUMNS THAT WE LIKE AND WE CAN PERFORM ALL THE OPERATION WITH THAT
with cte_example as
(
select gender, avg(salary) avg_sal, max(salary) max_sal, min(salary) min_sal,count(salary) count 
              from employee_demographics as d join  employee_salary as s 
              on d.employee_id = s.employee_id 
              group by gender
) select * from cte_example;        


with
 cte_ex1 as(
select first_name,last_name, gender, birth_date,employee_id  from employee_demographics where birth_date > '1980-01-01'
),
cte_ex2 as(
select salary, employee_id from employee_salary where salary > '50000'
)
select * from cte_ex1 join cte_ex2 on cte_ex1.employee_id = cte_ex2.employee_id; 

    
-- TEMPORARY TABLE                
create table temp_table
( first_name varchar(50),
last_name varchar(50),
favourite_food varchar(50)
)
;
insert into temp_table values('Jayasurya','Rathinagiri', 'Kothu parota');
select * from temp_table;

-- CREATING A TEMPORARY TABLE CALLED salaryover50k AND PUTTING VALUES FROM ALREADY EXISTING TABLE employee_salary AND DISPLAYING THE TEMPORARY TABLE
create table salaryover50k
select * from employee_salary where salary>='50000';
select * from salaryover50k;

-- STORED PROCEDURES SO THIS IS LIKE STORING A COMPLEX QUERY INTO A VARIABLE SO THAT WE CAN REUSE MULTIPLE TIME => MORE LIKE A FUNCTION
create procedure salarymorethan50k()
select * from employee_salary where salary > '50000';
CALL salarymorethan50k();

delimiter $$
create procedure large_salaries()
begin 
     select * from employee_salary where salary > '50000';
     select * from employee_salary where salary > '10000';
end $$
delimiter ;

-- PAASING ID AS A PARAMETER
delimiter $$
create procedure large_salaries3(id_of_employee int)
begin 
     select first_name,last_name,salary from employee_salary where employee_id = id_of_employee;
   
end $$
delimiter ;

call large_salaries3(1);

-- TRIGGERS   -> TRIGGERS AN EVENT AUTOMATICALLY

delimiter $$
create trigger employee_insert
		after insert on employee_salary
        for each row 
begin
			insert into employee_demographics(first_name, last_name, employee_id)
            values(new.first_name, new.last_name, new.employee_id);
end $$
delimiter ;
            
select * from employee_salary;
insert into employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
	   value(13,'Jayasurya', 'Rathinagiri', 'Software', '80000', 1);
	
select * from employee_demographics;

-- EVENTS -> THIS HAPPENS WHEN IT IS SCHEDULED 

delimiter $$
create event deletereteries
		on schedule every 30 second
        do 
begin
		delete 
        from employee_demographics 
        where age >= '60';
end $$
delimiter ;
show variables like 'event%';

