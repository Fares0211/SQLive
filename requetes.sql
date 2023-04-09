-- ORGANIZATION

-- Is no represntation of company overlap another one ?
CREATE OR REPLACE TRIGGER overlap
BEFORE INSERT OR UPDATE 
ON Presentation
FOR EACH ROW

DECLARE 
    nb_rows NUMBER;

BEGIN
    SELECT NVL(count(DISTINCT id_Theater),0) INTO nb_rows
    FROM Company c
    INNER JOIN Show s USING(id_company)
    INNER JOIN Presentation p USING (id_show)
    WHERE id_company = (SELECT id_Company FROM company c INNER JOIN Show s USING(id_Company) WHERE s.id_show = :new.id_Show) 
    AND p.date_ = :new.date_ 
    GROUP BY p.date_;
        
    IF nb_rows >= 1 THEN
        raise_application_error(-20001, 'this company already presents in a theater on this day');
    END IF;
    
EXCEPTION
    WHEN no_data_found THEN 
        null;
END;
/

-- What is the set of cities in which a company plays for a certain period ?
CREATE OR REPLACE PROCEDURE cities_period(id NUMBER, date_debut DATE, date_fin DATE) IS
    CURSOR cities IS
    SELECT DISTINCT t.city AS name
    FROM company c
    INNER JOIN show s ON s.id_company=c.id_company
    INNER JOIN Presentation p USING(id_show)
    INNER JOIN Theater t ON p.id_theater = t.id_theater
    WHERE c.id_company = id
    AND p.date_ BETWEEN date_debut AND date_fin;

BEGIN
    FOR city IN cities LOOP 
        dbms_output.put_line(city.name);
    END LOOP;
END;
/
BEGIN
    cities_period(1,'20-JAN-2022','12-FEB-2022');
END;
/

-- TICKETING

-- What are the ticket prices today ?
CREATE OR REPLACE PROCEDURE prices_today(today DATE) IS
    CURSOR prices IS
    SELECT id_Presentation, ticketReferencePrice
    FROM Presentation
    WHERE date_ = today;


BEGIN
    FOR price IN prices LOOP 
        dbms_output.put_line(to_char(price.id_Presentation)||' ' ||to_char(price.ticketReferencePrice));
    END LOOP;
END;
/
BEGIN
    prices_today('20-JAN-2022');
END;
/

-- For each representation, what is the distribution of tickets by price ?
CREATE OR REPLACE PROCEDURE tickets_procedure IS

    CURSOR distributions IS
    SELECT DISTINCT Id_presentation, Id_Promotion, p.ticketReferencePrice*(1-pr.discount) AS price
    FROM Presentation p
    INNER JOIN Sales s USING(id_Presentation)
    INNER JOIN Promotion pr USING(id_Promotion)
    ORDER BY Id_presentation, Id_Promotion;
BEGIN
    FOR d IN distributions LOOP
        dbms_output.put_line(to_char(d.id_Presentation)||' ' ||to_char(d.price)|| '€');
    END LOOP;
END;
/
BEGIN
    tickets_procedure;
END;
/

-- For each theater, what is the average load factor ?
CREATE OR REPLACE PROCEDURE avg_load_factor IS
    CURSOR factors IS
    SELECT t.id_theater, t.name, NVL(AVG(s.ticketsSold),0) AS ticketsSold
    FROM Theater t
    LEFT JOIN Presentation p ON p.id_Theater = t.id_Theater
    LEFT JOIN Sales s ON p.id_Presentation=s.id_Presentation
    GROUP BY t.id_Theater, t.name;

BEGIN
    FOR factor IN factors LOOP 
        dbms_output.put_line(factor.name||' ' ||to_char(factor.ticketsSold));
    END LOOP;
END;
/
BEGIN
    avg_load_factor();
END;
/

--ACCOUNTING
1-


-- revenu d'une entreprise sur une journée

CREATE OR REPLACE FUNCTION REVENUES(id_company_1 number, date_1 date, withTickets Boolean default true) RETURN NUMBER IS
    totalticketCost number := 0;
    totalsubsidiesCost number := 0;
    totalstagingCost number := 0;
    totaltravelCost number := 0;
BEGIN

    IF withTickets THEN
        select nvl(sum(d.ticketsSold*c.ticketReferencePrice*(1-e.discount)),0) as total into totalticketCost
        from company a inner join theater b using(id_company)
            inner join presentation c using(id_theater)
            inner join sales d using(id_presentation)
            inner join promotion e using(id_promotion)
        where d.date_=date_1 and id_company = id_company_1;
    END IF;

    
        
    select nvl(sum(a.amount),0) as total into totalsubsidiesCost
    from subsidize a inner join theater b using(id_theater)
                    inner join company c using(id_company)
    where id_company = id_company_1 and a.date_=date_1;
        
        
    select nvl(sum(c.stagingCosts),0) as total into totalstagingCost
    from company a inner join show b using(id_company)
                inner join presentation c using(id_show)
    where id_company = id_company_1
        and c.id_theater <> (select b.id_theater from company a inner join theater b using(id_company) where id_company=id_company_1) 
        and c.date_ = (select min(date_) from presentation where tourNumber=c.tourNumber)
        and c.date_ = date_1; 
        
        
    select nvl(sum(sum(c.travelCosts)),0) as total into totaltravelCost
    from company a inner join theater b using(id_company)
                inner join presentation c using(id_theater)
    where id_company = id_company_1
        and c.id_show not in (select b.id_show from company a inner join show b using(id_company) where id_company = id_company_1)
        and c.arrivalDate = date_1
    group by tourNumber; 
    
    RETURN totalticketCost + totalsubsidiesCost + totalstagingCost + totaltravelCost;
END;
/


-- dépenses d'une entreprise sur une journée

CREATE OR REPLACE FUNCTION EXPENDITURES(id_company_1 number, date_1 date) RETURN NUMBER IS
    totalsalariesCost number := 0;
    totalstagingCost number := 0;
    totaltravelCost number := 0;
BEGIN
    select nvl(sum(c.comedianFees),0) as total into totalsalariesCost
    from company a inner join show b using(id_company)
                inner join presentation c using(id_show)
    where id_company = id_company_1 and c.date_ = date_1;
        
        
    select nvl(sum(c.stagingCosts),0) as total into totalstagingCost
    from company a inner join theater b using(id_company)
                inner join presentation c using(id_theater)
    where id_company = id_company_1
        and c.id_show not in (select b.id_show from company a inner join show b using(id_company) where id_company = id_company_1)
        and c.date_ = (select min(date_) from presentation where tourNumber=c.tourNumber)
        and c.date_ = date_1; 
        
        
    select nvl(sum(sum(c.travelCosts)),0) as total into totaltravelCost
    from company a inner join show b using(id_company)
                inner join presentation c using(id_show)
    where id_company = id_company_1
        and c.id_theater <> (select b.id_theater from company a inner join theater b using(id_company) where id_company=id_company_1) 
        and c.arrivalDate = date_1    
    group by tourNumber;
            
        
    RETURN totalsalariesCost + totalstagingCost + totaltravelCost;
END;
/
    
-- bénéfice d'une entreprise sur une journée
   
CREATE OR REPLACE PROCEDURE dailyBalance(date_1 DATE) IS

    final_amount NUMBER;
    CURSOR ids IS SELECT id_company AS id FROM company;
    
    -- calcul du bénéfice de la journée
    PROCEDURE dailyBalancePerCompany(id_comp NUMBER, date_1 DATE) IS
        final_amount NUMBER;
        rev NUMBER := REVENUES(id_comp,date_1,false);
        exp NUMBER := EXPENDITURES(id_comp,date_1);
    BEGIN
        SELECT NVL(amount,0)+rev-exp INTO final_amount
        FROM Balance
        WHERE id_Company = id_comp
        AND date_ = date_1-1;
        
        INSERT INTO Balance(id_Company, date_, amount)
        VALUES(id_comp,date_1,final_amount);
    
    EXCEPTION
        WHEN no_data_found THEN
            INSERT INTO Balance(id_Company, date_, amount)
            VALUES(id_comp,date_1,rev-exp);
    END; 
    
BEGIN
    FOR i in ids LOOP
        dailyBalancePerCompany(i.id,date_1);
    END LOOP;
END;
/

-- insertion des bénéfices journaliers des entreprises dans la table balance
DECLARE
    mydate DATE := '01-JAN-2022';
BEGIN
    FOR i IN 0..30 LOOP
        dailyBalance(mydate+i);
    END LOOP;
END;
/

-- balance promptly red

CREATE OR REPLACE PROCEDURE BALANCE_PROMPTLY_RED(id_company_1 number) IS
    first_date DATE := null;
    last_date DATE := null;
    
    CURSOR dates IS
    SELECT *
    FROM balance 
    WHERE id_company = id_company_1;
    
BEGIN
    
    FOR c in dates LOOP
        IF c.amount < 0 THEN
            IF first_date is null THEN
                first_date := c.date_;
            END IF;
        
        ELSE
            IF first_date is not null THEN
                last_date := c.date_-1;
            END IF;
        END IF;
        
        EXIT WHEN last_date is not null;
        
    END LOOP;
    
    IF last_date is not null and first_date is not null THEN
        dbms_output.put_line('First date: '||to_char(first_date));
        dbms_output.put_line('Balance moves promptly to the red from '||to_char(first_date)||' to '||to_char(last_date));
    ELSE
        dbms_output.put_line('Balance never move promptly to the red');
    END IF;

END;
/


-- balance permanently red

CREATE OR REPLACE PROCEDURE BALANCE_PERMANENTLY_RED(id_company_1 number) IS
    first_date DATE := null;
    last_date DATE := null;
    
    CURSOR dates IS
    SELECT *
    FROM balance 
    WHERE id_company = id_company_1;
    
BEGIN
    
    FOR c in dates LOOP
        IF c.amount < 0 THEN
            IF first_date is null THEN
                first_date := c.date_;
            END IF;
        
        ELSE
            IF first_date is not null THEN
                last_date := c.date_-1;
            END IF;
        END IF;
        
        EXIT WHEN last_date is not null;
        
    END LOOP;
    
    IF last_date is null and first_date is not null THEN
        dbms_output.put_line('First date: '||to_char(first_date));
        dbms_output.put_line('Balance moves permanently to the red from '|| to_char(first_date));
    ELSE
        dbms_output.put_line('Balance never move permanently to the red');
    END IF;
END;
/



4-
CREATE OR REPLACE PROCEDURE COST_EFFECTIVE(id_pres number) IS
    totalticketCost number := 0;
    totalstagingCost number := 0;
    totaltravelCost number := 0;
    totalsalariesCost number := 0;
    
    receiver_company number;
    owner_company number;
    

BEGIN
    select t.id_company into receiver_company
    from presentation p 
    inner join theater t using(id_theater)
    where p.id_presentation = id_pres;
    
    select s.id_company into owner_company
    from presentation p 
    inner join show s using(id_show)
    where p.id_presentation = id_pres;


    IF owner_company = receiver_company THEN
        
        select nvl(sum(d.ticketsSold*c.ticketReferencePrice*(1-e.discount)),0) as total into totalticketCost
        from presentation c
            inner join sales d using(id_presentation)
            inner join promotion e using(id_promotion)
        where id_presentation = id_pres;
        
        select nvl(comedianFees,0) as total into totalsalariesCost
        from presentation
        where id_presentation = id_pres;
        
    ELSE
    
        select nvl(stagingCosts,0) as total into totalstagingCost
        from presentation
        where id_presentation = id_pres; 
            
            
        select nvl(comedianFees,0) as total into totalsalariesCost
        from presentation
        where id_presentation = id_pres;
            
            
        select nvl(travelCosts,0) as total into totaltravelCost
        from presentation
        where id_presentation = id_pres;
    
    END IF; 
    
    dbms_output.put_line('Revenues: '||to_char(totalticketCost + totalstagingCost)||' €');
    dbms_output.put_line('Expenditures: '||to_char(totaltravelCost + totalsalariesCost)||' €');
    dbms_output.put_line('Balance: '||to_char(totalticketCost + totalstagingCost - totaltravelCost - totalsalariesCost)||' €');
END;
/











--NETWORK

1-
CREATE OR REPLACE PROCEDURE NEVER_PLAY_IN_OUR_THEATER IS
    cursor companies is
    select id_company, name
    from (select t as id_company, name,
            sum(case when id_theater <> (select b.id_theater from company a inner join theater b using(id_company) where id_company=t) then 1 else 0 end) as presentation_ext,
            sum(case when id_theater is not null then 1 else 0 end) as presentation_tot
    from (select id_company as t, a.name, c.id_theater 
        from company a left join show b using(id_company)
                left join presentation c using(id_show))
    group by t,name)
    where presentation_ext = presentation_tot;
BEGIN
    dbms_output.put_line('Companies that will never play in their theater');
    for company in companies loop
        dbms_output.put_line(to_char(company.id_company)||' '||company.name);
    end loop;
END;
/

2-
a)
CREATE OR REPLACE PROCEDURE FIRST_SHOW_AT_HOME IS
    cursor companies is
    select t as id_company,name from
        (select min(rownum)  as ct
        from (select id_company as t,name, id_theater, rownum
            from company a inner join show b using(id_company)
                    inner join presentation c using(id_show)
        order by id_company, c.date_) group by t,name)
    inner join
        (select id_company as t,name, id_theater, rownum as ct
        from company a inner join show b using(id_company)
                    inner join presentation c using(id_show)
        order by id_company, c.date_) 
    using(ct)
    where id_theater = (select b.id_theater from company a inner join theater b using(id_company) where id_company=t);
BEGIN
    dbms_output.put_line('Companies that make their first show at home');
    for company in companies loop
        dbms_output.put_line(to_char(company.id_company)||' '||company.name);
    end loop;
END;
/

b)
CREATE OR REPLACE PROCEDURE FIRST_SHOW_OUTSIDE IS
    cursor companies is
    select t as id_company,name from
        (select min(rownum)  as ct
        from (select id_company as t,name, id_theater, rownum
            from company a inner join show b using(id_company)
                    inner join presentation c using(id_show)
        order by id_company, c.date_) group by t,name)
    inner join
        (select id_company as t,name, id_theater, rownum as ct
        from company a inner join show b using(id_company)
                    inner join presentation c using(id_show)
        order by id_company, c.date_) 
    using(ct)
    where id_theater <> (select b.id_theater from company a inner join theater b using(id_company) where id_company=t);
BEGIN
    dbms_output.put_line('Companies that make their first show outside');
    for company in companies loop
        dbms_output.put_line(to_char(company.id_company)||' '||company.name);
    end loop;
END;
/

3-
a)
CREATE OR REPLACE PROCEDURE MOST_POPULAR_SHOW_BYNUMREPR(date_deb date, date_fin date) IS
    cursor shows is
    select * 
    from (select id_show,title, count(*) as nb
    from show a inner join presentation b using(id_show)
    where date_ between date_deb and date_fin
    group by id_show,title
    order by count(*) desc)
    where rownum <= 5;
BEGIN
    dbms_output.put_line('Most popular shows by number of representation');
    for show in shows loop
        dbms_output.put_line(to_char(show.id_show)||' '||show.title||' '||to_char(show.nb));
    end loop;
END;
/

b)
CREATE OR REPLACE PROCEDURE MOST_POPULAR_SHOW_BYPOTVIEWER(date_deb date, date_fin date) IS
    cursor shows is
    select * 
    from (select id_show,a.title, sum(c.capacity) as nb
    from show a inner join presentation b using(id_show)
                inner join theater c using(id_theater)
    where b.date_ between SYSDATE and SYSDATE+60
    group by id_show,title
    order by sum(c.capacity) desc)
    where rownum <= 5;
BEGIN
    dbms_output.put_line('Most popular shows by number of potential viewers');
    for show in shows loop
        dbms_output.put_line(to_char(show.id_show)||' '||show.title||' '||to_char(show.nb));
    end loop;
END;
/

c)
CREATE OR REPLACE PROCEDURE MOST_POPULAR_SHOW_BYSEATSOLD(date_deb date, date_fin date) IS
    cursor shows is
    select * 
    from (select id_show,a.title, sum(c.ticketsSold) as nb
    from show a inner join presentation b using(id_show)
                inner join sales c using(id_presentation)
    where c.date_ between SYSDATE and SYSDATE+60
    group by id_show,title
    order by sum(c.ticketsSold) desc)
    where rownum <= 5;
BEGIN
    dbms_output.put_line('Most popular shows by number of seats sold');
    for show in shows loop
        dbms_output.put_line(to_char(show.id_show)||' '||show.title||' '||to_char(show.nb));
    end loop;
END;
/

/** test **/
BEGIN
    never_play_in_our_theater();
    first_show_at_home();
    first_show_outside();
    most_popular_show_bynumrepr(SYSDATE,sysdate+60);
    most_popular_show_bypotviewer(SYSDATE,sysdate+60);
    most_popular_show_byseatsold(SYSDATE,sysdate+60);
END;
/








-- Promotions

-- 20%
CREATE OR REPLACE TRIGGER fifteenDays
BEFORE INSERT ON Sales
FOR EACH ROW

DECLARE 
    date1 DATE;

BEGIN
    SELECT date_ INTO date1 
    FROM presentation WHERE id_presentation = :new.id_presentation;

    IF date1 - :new.date_ < 15 AND :new.id_Promotion = 2 THEN
       raise_application_error(-20002,'this promotion is no longer available for this presentation');
    END IF;
END;
/

--30%
CREATE OR REPLACE TRIGGER capacityLessFifty
BEFORE INSERT ON Sales
FOR EACH ROW

DECLARE 
    date1 DATE;
    capacity NUMBER;
    tickets NUMBER;

BEGIN
    SELECT date_ INTO date1 
    FROM presentation WHERE id_presentation = :new.id_presentation;
    
    SELECT t.capacity INTO capacity
    FROM Presentation p
    INNER JOIN Theater t USING (id_Theater)
    WHERE p.id_Presentation = :new.id_Presentation;
    
    SELECT sum(TicketsSold) INTO tickets 
    FROM sales WHERE id_presentation = :new.id_presentation
    GROUP BY id_Presentation;
    
    IF :new.id_Promotion = 3 THEN
        IF date1 = :new.date_ AND tickets < 0.5*capacity AND :new.id_Promotion = 3 THEN 
           NULL;
        ELSE
           raise_application_error(-20004,'this promotion is no longer available for this presentation');
        END IF;
    END IF;
END;
/

--50%
CREATE OR REPLACE TRIGGER capacityLessThirty
BEFORE INSERT ON Sales
FOR EACH ROW

DECLARE 
    date1 DATE;
    capacity NUMBER;
    tickets NUMBER;

BEGIN
    SELECT date_ INTO date1 
    FROM presentation WHERE id_presentation = :new.id_presentation;
    
    SELECT t.capacity INTO capacity
    FROM Presentation p
    INNER JOIN Theater t USING (id_Theater)
    WHERE p.id_Presentation = :new.id_Presentation;
    
    SELECT sum(TicketsSold) INTO tickets 
    FROM sales WHERE id_presentation = :new.id_presentation
    GROUP BY id_Presentation;
    
    IF :new.id_Promotion = 4 THEN
        IF date1 = :new.date_ AND tickets < 0.3*capacity AND :new.id_Promotion = 4 THEN 
           NULL;
        ELSE
           raise_application_error(-20005,'this promotion is no longer available for this presentation');
        END IF;
    END IF;
END;
/

-- Capacity rule
CREATE OR REPLACE TRIGGER noSizeExceed
BEFORE INSERT OR UPDATE ON Sales
FOR EACH ROW

DECLARE 
    capacity NUMBER;
    tickets NUMBER;

BEGIN
    SELECT sum(TicketsSold) + :new.ticketsSold INTO tickets 
    FROM sales WHERE id_presentation = :new.id_presentation
    GROUP BY id_Presentation;
    
    SELECT t.capacity INTO capacity
    FROM Presentation p
    INNER JOIN Theater t USING (id_Theater)
    WHERE p.id_Presentation = :new.id_Presentation;
    
    IF tickets > capacity THEN
       raise_application_error(-20003,'the number of tickets for this presentation will exceed the theater capacity');
    END IF;
    
END;
/

-- Time rule
CREATE OR REPLACE TRIGGER datePassed
BEFORE INSERT OR UPDATE ON Sales
FOR EACH ROW

DECLARE 
    date1 DATE;

BEGIN
    SELECT date_ INTO date1 
    FROM presentation WHERE id_presentation = :new.id_presentation;
    
    IF :new.date_ > date1 THEN
       raise_application_error(-20006,'a ticket purchase cannot be recorded after the presentation date');
    END IF;
    
END;
/
