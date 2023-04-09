-- Company

Insert into company (id_Company, name, balance)
values (1, 'Lune', 0);
Insert into company (id_Company, name, balance)
values (2, 'Venus', 0);
Insert into company (id_Company, name, balance)
values (3, 'Mars', 0);
Insert into company (id_Company, name, balance)
values (4, 'Jupiter', 0);
Insert into company (id_Company, name, balance)
values (5, 'Soleil', 0) ;


-- Show

Insert into show (Id_Show, title, productionCosts, id_Company)
values (1, 'Attack on Titan', 1500, 1);
Insert into show (Id_Show, title, productionCosts, id_Company)
values (2, 'Hunter x Hunter', 2000, 1);
Insert into show (Id_Show, title, productionCosts, id_Company)
values (3, 'Naruto', 2500, 3);
Insert into show (Id_Show, title, productionCosts, id_Company)
values (4, 'Dragon Ball', 3000, 4);
Insert into show (Id_Show, title, productionCosts, id_Company)
values (5, 'One Piece', 4500, 5);


-- Agency

Insert into agency (id_agency, name)
values (1, 'Municipalite');
Insert into agency (id_agency, name)
values (2, 'Ministre de la Culture');
Insert into agency (id_agency, name)
values (3, 'Donateurs prives');


-- Promotion

Insert into promotion(id_promotion, name, discount)
values (1,'noProm',0);
Insert into promotion(id_promotion, name, discount)
values (2,'15dBeforeRepr',0.2);
Insert into promotion(id_promotion, name, discount)
values (3,'lt 50% filled',0.3);
Insert into promotion(id_promotion, name, discount)
values (4,'lt 30% filled',0.5);
Insert into promotion(id_promotion, name, discount)
values (5,'reducedRate',0.5);


-- AppDate

BEGIN
    for i in 0..364 loop
        insert into appdate values (to_date('01-01-2022','dd-mm-yyyy')+i);
    end loop;
END;
/

-- Theater

Insert into Theater (id_Theater, name, city, capacity, id_Company)
values (1, 't1','Dubai',60, 1);
Insert into Theater (id_Theater, name, city, capacity, id_Company)
values (2, 't2','Tokyo', 70, 2);
Insert into Theater (id_Theater, name, city, capacity, id_Company)
values (3, 't3','Londres', 80, 3);
Insert into Theater (id_Theater, name, city, capacity, id_Company)
values (4, 't4','New York', 90, 4);
Insert into Theater (id_Theater, name, city, capacity, id_Company)
values (5, 't5','Paris', 85, 5);



-- Presentation

Insert into presentation (Id_Presentation,stagingCosts, travelCosts, date_, Id_Show, id_Theater, tourNumber, comedianFees, ticketReferencePrice, arrivalDate)
values (1, 0, 0, to_date('20-01-2022','dd-mm-yyyy'), 1, 1, 1, 200, 16, to_date('15-01-2022','dd-mm-yyyy'));
Insert into presentation (Id_Presentation,stagingCosts, travelCosts, date_, Id_Show, id_Theater, tourNumber, comedianFees, ticketReferencePrice, arrivalDate)
values (2, 250, 130, to_date('10-02-2022','dd-mm-yyyy'), 2, 3, 2, 200, 16, to_date('07-02-2022','dd-mm-yyyy'));
Insert into presentation (Id_Presentation,stagingCosts, travelCosts, date_, Id_Show, id_Theater, tourNumber, comedianFees, ticketReferencePrice, arrivalDate)
values (3, 250, 130, to_date('12-02-2022','dd-mm-yyyy'), 2, 3, 2, 200, 16, to_date('07-02-2022','dd-mm-yyyy'));
Insert into presentation (Id_Presentation,stagingCosts, travelCosts, date_, Id_Show, id_Theater, tourNumber, comedianFees, ticketReferencePrice, arrivalDate)
values (4, 250, 130, to_date('13-02-2022','dd-mm-yyyy'), 2, 3, 2, 200, 16, to_date('07-02-2022','dd-mm-yyyy'));
Insert into presentation (Id_Presentation,stagingCosts, travelCosts, date_, Id_Show, id_Theater, tourNumber, comedianFees, ticketReferencePrice, arrivalDate)
values (5, 300, 150, to_date('22-01-2022','dd-mm-yyyy'), 3, 1, 3, 200, 16, to_date('15-01-2022','dd-mm-yyyy'));
Insert into presentation (Id_Presentation,stagingCosts, travelCosts, date_, Id_Show, id_Theater, tourNumber, comedianFees, ticketReferencePrice, arrivalDate)
values (6, 300, 150, to_date('24-01-2022','dd-mm-yyyy'), 4, 1, 4, 200, 16, to_date('15-01-2022','dd-mm-yyyy'));


-- Subsidize

Insert into subsidize (id_Theater, Id_Agency, date_, amount)
values (1, 1, to_date('21-01-2022','dd-mm-yyyy'), 1);
Insert into subsidize (id_Theater, Id_Agency, date_, amount)
values (2, 2, to_date('22-01-2022','dd-mm-yyyy'), 2);
Insert into subsidize (id_Theater, Id_Agency, date_, amount)
values (3, 3, to_date('12-01-2022','dd-mm-yyyy'), 3);
Insert into subsidize (id_Theater, Id_Agency, date_, amount)
values (4, 1, to_date('21-02-2022','dd-mm-yyyy'), 1);
Insert into subsidize (id_Theater, Id_Agency, date_, amount)
values (5, 1, to_date('21-03-2022','dd-mm-yyyy'), 1);
Insert into subsidize (id_Theater, Id_Agency, date_, amount)
values (6, 1, to_date('21-04-2022','dd-mm-yyyy'), 1);


-- sales

insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (1,2,to_date('01-01-2022','dd-mm-yyyy'),10);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (1,5,to_date('02-01-2022','dd-mm-yyyy'),4);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (1,1,to_date('12-01-2022','dd-mm-yyyy'),8);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (1,5,to_date('12-01-2022','dd-mm-yyyy'),11);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (1,1,to_date('13-01-2022','dd-mm-yyyy'),7);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (1,5,to_date('13-01-2022','dd-mm-yyyy'),4);

insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,2,to_date('01-01-2022','dd-mm-yyyy'),5);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,5,to_date('02-01-2022','dd-mm-yyyy'),2);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,2,to_date('06-01-2022','dd-mm-yyyy'),8);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,5,to_date('06-01-2022','dd-mm-yyyy'),11);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,1,to_date('13-01-2022','dd-mm-yyyy'),7);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,5,to_date('13-01-2022','dd-mm-yyyy'),4);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (5,4,to_date('22-01-2022','dd-mm-yyyy'),6);

insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (6,2,to_date('01-01-2022','dd-mm-yyyy'),10);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (6,5,to_date('02-01-2022','dd-mm-yyyy'),4);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (6,1,to_date('12-01-2022','dd-mm-yyyy'),8);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (6,5,to_date('12-01-2022','dd-mm-yyyy'),11);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (6,1,to_date('13-01-2022','dd-mm-yyyy'),7);
insert into sales (id_presentation, id_promotion, date_, ticketsSold)
values (6,5,to_date('13-01-2022','dd-mm-yyyy'),4);