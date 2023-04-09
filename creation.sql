DROP TABLE sales;
DROP TABLE subsidize;
DROP TABLE Presentation;
DROP TABLE Theater;
DROP TABLE AppDate;
DROP TABLE promotion;
DROP TABLE agency;
DROP TABLE show;
DROP TABLE company;
DROP TABLE balance;


CREATE TABLE Company(
   Id_Company NUMBER,
   name VARCHAR(50),
   balance NUMBER,
   CONSTRAINT pk_company PRIMARY KEY(Id_Company)
);

CREATE TABLE Show(
   Id_Show NUMBER,
   title VARCHAR(50),
   productionCosts NUMBER,
   Id_Company INT NOT NULL,
   CONSTRAINT pk_show PRIMARY KEY(Id_Show),
   CONSTRAINT fk_company_show FOREIGN KEY(Id_Company) REFERENCES Company(Id_Company)
);

CREATE TABLE Agency(
   Id_Agency NUMBER,
   name VARCHAR(50),
   CONSTRAINT pk_agency PRIMARY KEY(Id_Agency)
);

CREATE TABLE Promotion(
   Id_Promotion NUMBER,
   name VARCHAR(50),
   discount VARCHAR(50),
   CONSTRAINT pk_promotion PRIMARY KEY(Id_Promotion)
);

CREATE TABLE AppDate(
   date_ DATE,
   CONSTRAINT pk_appdate PRIMARY KEY(date_)
);

CREATE TABLE Theater(
   Id_Theater NUMBER,
   capacity INT,
   city VARCHAR(50),
   name VARCHAR(50),
   Id_Company INT NOT NULL,
   CONSTRAINT pk_theater PRIMARY KEY(Id_Theater),
   CONSTRAINT fk_company_theater FOREIGN KEY(Id_Company) REFERENCES Company(Id_Company)
);

CREATE TABLE Presentation(
   Id_Presentation NUMBER,
   tourNumber INT,
   stagingCosts NUMBER,
   travelCosts NUMBER,
   comedianFees NUMBER,
   ticketReferencePrice NUMBER,
   arrivalDate DATE,
   date_ DATE NOT NULL,
   Id_Show INT NOT NULL,
   Id_Theater INT NOT NULL,
   CONSTRAINT pk_presentation PRIMARY KEY(Id_Presentation),
   CONSTRAINT fk_appdate_presentation FOREIGN KEY(date_) REFERENCES AppDate(date_),
   CONSTRAINT fk_show_presentation FOREIGN KEY(Id_Show) REFERENCES Show(Id_Show),
   CONSTRAINT fk_theater_presentation FOREIGN KEY(Id_Theater) REFERENCES Theater(Id_Theater)
);

CREATE TABLE subsidize(
   Id_Theater INT,
   Id_Agency INT,
   date_ DATE,
   amount NUMBER,
   CONSTRAINT pk_subsidize PRIMARY KEY(Id_Theater, Id_Agency, date_),
   CONSTRAINT fk_theater_subsidize FOREIGN KEY(Id_Theater) REFERENCES Theater(Id_Theater),
   CONSTRAINT fk_agency_subsidize FOREIGN KEY(Id_Agency) REFERENCES Agency(Id_Agency),
   CONSTRAINT fk_date_subsidize FOREIGN KEY(date_) REFERENCES AppDate(date_)
);

CREATE TABLE sales(
   Id_Presentation INT,
   Id_Promotion INT,
   date_ DATE,
   ticketsSold INT,
   CONSTRAINT pk_sales PRIMARY KEY(Id_Presentation, Id_Promotion, date_),
   CONSTRAINT fk_presentation_sales FOREIGN KEY(Id_Presentation) REFERENCES Presentation(Id_Presentation),
   CONSTRAINT fk_promotion_sales FOREIGN KEY(Id_Promotion) REFERENCES Promotion(Id_Promotion),
   CONSTRAINT fk_date_sales FOREIGN KEY(date_) REFERENCES AppDate(date_)
);

CREATE TABLE balance(
   Id_Company NUMBER,
   date_ DATE,
   amount NUMBER,
   CONSTRAINT pk_balance PRIMARY KEY(Id_Company, date_),
   CONSTRAINT fk_balance_company FOREIGN KEY(Id_Company) REFERENCES Company(Id_Company),
   CONSTRAINT fk_balance_appdate FOREIGN KEY(date_) REFERENCES AppDate(date_)
);