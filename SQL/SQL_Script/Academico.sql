USE Universidade;

CREATE TABLE Aluno(
	RA int NOT NULL PRIMARY KEY,
	Nome Varchar(50) NOT NULL
);

INSERT INTO Aluno(RA,Nome)
VALUES(01,'Carlos'),
      (02,'Maria'),
	  (03,'Laura'),
	  (04,'Paulo'),
	  (05,'Aline'),
	  (06,'Natalia'),
	  (07,'João'),
	  (08,'Cesar'),
	  (09,'Julia'),
	  (10,'Ana');

	  
CREATE TABLE Disciplina(
	Sigla char(3)NOT NULL PRIMARY KEY,
	Nome varchar(40) NOT NULL,
	Carga_Horaria int NOT NULL
);

INSERT INTO Disciplina(Sigla,Nome,Carga_Horaria)
VALUES('CA','Calculo',80),
      ('TCC','Trabalho Conclusão',80),
	  ('PT','Portugues',80),
	  ('FS','FiSisca',80),
	  ('GM','Geometria',80),
	  ('PR','Probabilidade',80),
	  ('SO','Sistema Operacionais',80),
	  ('AR','Arquitetura PC',80),
	  ('SD','Sistemas Digitais',80),
	  ('CE','Circuito Eletrico',80),
	  ('ED','Estrutura de Dados',80);
	  

CREATE TABLE Matricula(
	RA int NOT NULL,
	Sigla char(3) NOT NULL,
	Data_Ano int NOT NULL ,
	Data_Semestre int NOT  NULL,
	Falta  int,
	Nota_N1  float, 
	Nota_N2 float,
	Nota_Sub float,
	Nota_Media float,
	Situacao varchar(15),

	FOREIGN KEY(RA) REFERENCES Aluno(RA),
	FOREIGN KEY (Sigla) REFERENCES Disciplina(Sigla),
);

INSERT INTO Matricula(RA,Sigla,Data_Ano,Data_Semestre)
VALUES(01,'CA',2021,1),
      (02,'TCC',2021,2),
	  (03,'TCC',2021,1),
	  (04,'PT',2021,2),
	  (05,'FS',2021,2),
	  (06,'PR',2021,1),
	  (07,'SO',2021,2),
	  (08,'AR',2021,1),
	  (09,'SD',2021,1),
	  (10,'CE',2021,2);

CREATE TRIGGER TRG_ReMatricula
On Matricula
AFTER INSERT,UPDATE
AS
BEGIN
	DECLARE
    @Data_Ano int,
	@RA int,
	@Sigla char(3),
	@Situacao varchar(12),
	@Data_Semestre int ;

	SELECT @Data_Ano = Data_Ano+1, @RA=RA, @Sigla=Sigla, @Data_Semestre=Data_Semestre, @Situacao=Situacao FROM INSERTED
	IF (@Situacao='Reprovado' )
		
	BEGIN 
		INSERT INTO Matricula(RA,Sigla,Data_Ano,Data_Semestre)VALUES(@RA,@Sigla,@Data_ANO,@Data_Semestre)
	END
End

 /*TRIGGER DE FREQUENCIA*/
CREATE TRIGGER TRG_Frequencia
On Matricula
AFTER UPDATE
AS
BEGIN
	DECLARE
	@Falta int,
	@Carga_Horaria int,
	@Ra int,
	@Sigla char(3);
	
	SELECT @RA =Ra,@Sigla=Sigla,@Falta=Falta FROM INSERTED;
	SELECT @Carga_Horaria = Carga_Horaria FROM Disciplina INSERTED;
	
	
	IF ( @Falta>(@Carga_Horaria*0.25))
	BEGIN
		UPDATE Matricula SET Situacao = 'REPROVADO' 
		WHERE RA = @Ra and Sigla = @Sigla;
	
	END
	IF  (@Falta<=(@Carga_Horaria*0.25))
	BEGIN
		UPDATE Matricula SET Situacao = 'APROVADO' 
		WHERE RA = @Ra and Sigla =@Sigla;
	END
END

/*Inserir Faltas*/
UPDATE Matricula Set Falta = 25 where RA=01;
UPDATE Matricula Set Falta = 9 where RA=02;
UPDATE Matricula Set Falta = 7 where RA=03;
UPDATE Matricula Set Falta = 23 where RA=04;
UPDATE Matricula Set Falta = 28 where RA=05;
UPDATE Matricula Set Falta = 18 where RA=06;
UPDATE Matricula Set Falta = 9 where RA=07;
UPDATE Matricula Set Falta = 12 where RA=08;
UPDATE Matricula Set Falta = 3 where RA=09;
UPDATE Matricula Set Falta = 2 where RA=10;

DROP TRIGGER TRG_Frequencia; 
DROP TRIGGER TRG_ReMatricula;

/*Trigger de MEDIA*/
CREATE TRIGGER TRG_Calculo__Media
ON Matricula
AFTER update
AS
BEGIN
    DECLARE
	@NOTA1 DECIMAL(10,2),
	@NOTA2 DECIMAL(10,2),
	@Media DECIMAL(10,2),
	@SUB DECIMAL (10,2),
	@RA int,
	@SIGLA char(3);
    SELECT @RA = RA, @SIGLA = Sigla, @NOTA1 = Nota_n1, @NOTA2 = Nota_n2, @SUB=Nota_SUB FROM INSERTED;
	
	IF(@SUB is null or @SUB <@NOTA1 and @SUB<@NOTA2 )
	BEGIN
	  UPDATE Matricula SET Nota_Media = (@NOTA1 + @NOTA2)/2
      WHERE @RA = RA and @SIGLA = Sigla;
	END
    
	ELSE IF(@SUB>@NOTA1 and @NOTA1<@NOTA2)
 	  BEGIN
	    UPDATE Matricula SET Nota_Media = (@SUB + @NOTA2)/2
        WHERE @RA = RA and @SIGLA = Sigla;
	  END
	
	ELSE 
	  BEGIN
	    UPDATE Matricula SET Nota_Media = (@SUB + @NOTA1)/2
         WHERE @RA = RA and @SIGLA = Sigla;
	 END

	SELECT @Media=Nota_Media FROM inserted
	IF EXISTS(SELECT * FROM Matricula WHERE Nota_Media<5 and @SIGLA = Sigla)
	BEGIN
		UPDATE Matricula SET Situacao = 'REPROVADO NOTA' 
		WHERE RA = @Ra and Sigla =@Sigla;
	
	END
    
	IF EXISTS(SELECT * FROM Matricula WHERE Nota_Media>=5 and @SIGLA = Sigla)
	BEGIN
		UPDATE Matricula SET Situacao = 'APROVADO NOTA' 
		WHERE RA = @Ra and Sigla =@Sigla;
	END
END

/*Altera As Notas 1*/
UPDATE Matricula set Nota_N1 = 7 where RA =01;
UPDATE Matricula set Nota_N1 = 5 Where RA =02;
UPDATE Matricula set Nota_N1 = 3 Where RA =03;
UPDATE Matricula set Nota_N1 = 6 Where RA =04;
UPDATE Matricula set Nota_N1 = 2 Where RA =05;
UPDATE Matricula set Nota_N1 = 3 Where RA =06;
UPDATE Matricula set Nota_N1 = 4 Where RA =07;
UPDATE Matricula set Nota_N1 = 6 Where RA =08;
UPDATE Matricula set Nota_N1 = 5 Where RA =09;
UPDATE Matricula set Nota_N1 = 8 Where RA =10;

 /*Altera As Notas 2*/
UPDATE Matricula set Nota_N2 = 5 where RA =01;
UPDATE Matricula set Nota_N2 = 2 Where RA =02;
UPDATE Matricula set Nota_N2 = 3 Where RA =03;
UPDATE Matricula set Nota_N2 = 2 Where RA =04;
UPDATE Matricula set Nota_N2 = 4 Where RA =05;
UPDATE Matricula set Nota_N2 = 7 Where RA =06;
UPDATE Matricula set Nota_N2 = 8 Where RA =07;
UPDATE Matricula set Nota_N2 = 6 Where RA =08;
UPDATE Matricula set Nota_N2 = 5 Where RA =09;
UPDATE Matricula set Nota_N2 = 3 Where RA =10;



/*TRIGGER DE RE_MATRICULA*/
CREATE TRIGGER TRG_ReMatricula
On Matricula
AFTER INSERT,UPDATE
AS
BEGIN
	DECLARE
    @Data_Ano int,
	@RA int,
	@Sigla char(3),
	@Situacao varchar(12),
	@Data_Semestre int ;

	SELECT @Data_Ano = Data_Ano+1, @RA=RA, @Sigla=Sigla, @Data_Semestre=Data_Semestre, @Situacao=Situacao FROM INSERTED
	IF (@Situacao='Reprovado' )
	
	BEGIN 
		INSERT INTO Matricula(RA,Sigla,Data_Ano,Data_Semestre)VALUES(@RA,@Sigla,@Data_ANO,@Data_Semestre)
	END
End

/*Notas Substitutas para Aluno Reprovados*/
UPDATE Matricula set Nota_Sub = 5 where RA =01 and Sigla ='CA'  and  Data_Semestre =1;

UPDATE Matricula set Nota_Sub = 3 Where RA =02 and Sigla ='TCC' and  Data_Semestre =2;
UPDATE Matricula set Nota_Sub = 2 Where RA =03 and Sigla ='TCC' and  Data_Semestre =1;

UPDATE Matricula set Nota_Sub = 1 Where RA =04 and Sigla ='PT'  and  Data_Semestre =2; 
UPDATE Matricula set Nota_Sub = 3 Where RA =05 and Sigla ='FS'  and  Data_Semestre =2;

UPDATE Matricula set Nota_Sub = 7 Where RA =06 and Sigla ='PR'  and  Data_Semestre =1;
UPDATE Matricula set Nota_Sub = 8 Where RA =07 and Sigla ='SO'  and  Data_Semestre =2;
UPDATE Matricula set Nota_Sub = 6 Where RA =08 and Sigla ='AR'  and  Data_Semestre =1;
UPDATE Matricula set Nota_Sub = 5 Where RA =09 and Sigla ='SD'  and  Data_Semestre =1;
UPDATE Matricula set Nota_Sub = 3 Where RA =10 and Sigla ='CE'  and  Data_Semestre =2;


DROP  TRIGGER TRG_Calculo__Media; 
DROP TRIGGER TRG_ReMatricula;


SELECT Aluno.Nome,Matricula.RA,Sigla,Data_ANO,Data_Semestre,Nota_N1,Nota_N2,Nota_Sub,Nota_Media,Falta,Situacao 
FROM Matricula,Aluno WHERE Data_Ano=2021 and Sigla='TCC' and Matricula.RA= Aluno.RA

SELECT Aluno.Nome,Matricula.RA,Sigla,Data_ANO,Data_Semestre,Nota_N1,Nota_N2,Nota_Sub,Falta,Nota_Media,Situacao 
FROM Matricula,Aluno WHERE Aluno.Nome='Carlos' and ALuno.RA=Matricula.RA and Data_Ano=2021 and Data_Semestre=2

SELECT Aluno.Nome,Matricula.RA,Sigla,Data_ANO,Nota_N1,Nota_N2,Nota_Sub,Nota_Media,Situacao 
FROM Matricula,Aluno WHERE Nota_Media < 5 and Matricula.RA= Aluno.RA and Data_Ano=2021 

Select * from Matricula;