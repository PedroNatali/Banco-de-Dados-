/* Esquema GameXP Art Street */


-- Gupo Artístico que possui Nome Artistico como chave e existe um check para que a quantidade 
-- de artistas mínima seja 1 no Grupo
CREATE TABLE GRUPO_ARTISTICO (
    NOME_ARTISTICO VARCHAR(30) NOT NULL,
    BREVE_DESCRICAO VARCHAR(200) NOT NULL,
    FACEBOOK VARCHAR(150),
    INSTAGRAM VARCHAR(150),
    TWITTER VARCHAR(150),
    EMAIL VARCHAR(30) NOT NULL,
    QUANTIDADE_ARTISTA INT NOT NULL,
    FOTO VARCHAR(150) NOT NULL, /* Como foi nao possível realizar o upload de imagens 
    pelo localhost, optamos por representar a imagem como uma string, o mesmo se repete 
    para demais objetos que poderiam ser bytea (nota fiscal, melhor obra, arte)*/
    CONSTRAINT PK_GRUPO PRIMARY KEY(NOME_ARTISTICO),
    CONSTRAINT CK_QTD CHECK(QUANTIDADE_ARTISTA >= 1) /* Prever a criação de grupos artístiscos vazios
    -- Será necessário em aplicação checar  a quantidade de artistas do grupo está consistente?? */
);

CREATE TABLE ARTISTA (
    CPF CHAR(14) NOT NULL,
    NOME VARCHAR(40) NOT NULL,
    GRUPO_ARTISTICO VARCHAR(20) NOT NULL,
    CONSTRAINT PK_ARTISTA PRIMARY KEY (CPF),
    CONSTRAINT FK_ARTISTA FOREIGN KEY (GRUPO_ARTISTICO) 
        REFERENCES GRUPO_ARTISTICO(NOME_ARTISTICO) ON DELETE CASCADE ON UPDATE CASCADE
);

-- A tabela Tipo_Profissao registra, para cada artista, o nome da sua melhor obra. Tendo como chave Artista
-- Além disso, ele tem uma FK para a tabela artista, puxando o CPF 
CREATE TABLE TIPO_PROFISSAO (
    ARTISTA CHAR(14) NOT NULL,
    MELHOR_OBRA VARCHAR(50), /* Pode-se usar BYTEA, para conter um arquivo
        binário que poderia ser a ilustração, o projeto ou o best-seller  */
    CONSTRAINT PK_TIPO_PROFISSAO PRIMARY KEY (ARTISTA),
    CONSTRAINT FK_TIPO_PROFISSAO FOREIGN KEY (ARTISTA)
        REFERENCES ARTISTA(CPF) ON DELETE CASCADE ON UPDATE CASCADE
);

-- A tabela Profissão registra quais as profissoes que o Artista possui, tendo como chave (artista, profissao)
-- Além disso, ele possui uma FK para artista, onde ele copia o atributo CPF 
CREATE TABLE PROFISSAO (
    ARTISTA CHAR(14) NOT NULL,
    PROFISSAO VARCHAR(20) NOT NULL,
    CONSTRAINT PK_PROFISSAO PRIMARY KEY (ARTISTA,PROFISSAO),
    CONSTRAINT FK_PROFISSAO FOREIGN KEY (ARTISTA)
        REFERENCES ARTISTA(CPF) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE INFRAESTRUTURA (
    NUMERO INT NOT NULL,
    GRUPO_ARTISTICO VARCHAR(30) NOT NULL,
    TIPO VARCHAR(20) NOT NULL,
    DATA DATE NOT NULL,
    CONSTRAINT PK_INFRA PRIMARY KEY (NUMERO),
    CONSTRAINT FK_INFRA FOREIGN KEY (GRUPO_ARTISTICO)
        REFERENCES GRUPO_ARTISTICO (NOME_ARTISTICO) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE MESA (
    NUMERO INT NOT NULL,
    SETOR  INT NOT NULL,
    CONSTRAINT PK_NUMERO PRIMARY KEY (NUMERO)
);

CREATE TABLE ESTANDE (
    MESA INT NOT NULL,
    DATA DATE NOT NULL,
    GRUPO_ARTISTICO VARCHAR(30) NOT NULL,
    CONSTRAINT PK_ESTANDE PRIMARY KEY (MESA,DATA,GRUPO_ARTISTICO),
    CONSTRAINT FK_ESTANDE_1 FOREIGN KEY (MESA) 
        REFERENCES MESA(NUMERO) ON DELETE CASCADE,
    CONSTRAINT FK_ESTANDE_2 FOREIGN KEY (GRUPO_ARTISTICO)
        REFERENCES GRUPO_ARTISTICO(NOME_ARTISTICO) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PORTFOLIO (
    NOME_ARTISTICO VARCHAR(30) NOT NULL,
    ARTE VARCHAR(50) NOT NULL,/* VISTO QUE É IMAGEM */
    CONSTRAINT PK_PORTFOLIO PRIMARY KEY (NOME_ARTISTICO, ARTE),
    CONSTRAINT FK_PORTFOLIO FOREIGN KEY (NOME_ARTISTICO)
        REFERENCES GRUPO_ARTISTICO(NOME_ARTISTICO) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE PRODUTO (
    NOME_ARTISTICO VARCHAR(30) NOT NULL,
    TIPO VARCHAR(20) NOT NULL,
    NOME VARCHAR(30) NOT NULL,
    PRECO DECIMAL (4, 2) NOT NULL,
    QUANTIDADE INT,
    TAMANHO VARCHAR(2),
    ANO_CIRCULACAO DATE, /* tem como pegarmos apenas o ano? */
    CONSTRAINT PK_PROD PRIMARY KEY (NOME_ARTISTICO, TIPO),
    CONSTRAINT FK_PROD FOREIGN KEY (NOME_ARTISTICO)
        REFERENCES GRUPO_ARTISTICO(NOME_ARTISTICO) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE VISITANTE (
    QR_CODE VARCHAR(15), /* String visto que é um código de barras */
    NOME  VARCHAR(40) NOT NULL,
    EMAIL VARCHAR(30),
    CPF CHAR (14) NOT NULL,
    CONSTRAINT PK_VISIT PRIMARY KEY (QR_CODE)
);

CREATE TABLE INTERACAO (
    ID INT NOT NULL,
    NOME_ARTISTICO VARCHAR(30) NOT NULL,
    VISITANTE VARCHAR(15) NOT NULL,
    DATA  DATE NOT NULL,
    HORA  TIME NOT NULL,
    CONSTRAINT PK_INT PRIMARY KEY (ID),
    CONSTRAINT SK_INT UNIQUE (NOME_ARTISTICO, VISITANTE, DATA, HORA),
    CONSTRAINT FK_INT FOREIGN KEY (VISITANTE)
        REFERENCES VISITANTE(QR_CODE) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE VENDA (
    INTERACAO INT NOT NULL,
    NOME_ARTISTICO VARCHAR(30) NOT NULL,
    TIPO VARCHAR(20) NOT NULL,
    NOTA_FISCAL VARCHAR(50) NOT NULL,
    CONSTRAINT PK_VENDA PRIMARY KEY (INTERACAO, NOME_ARTISTICO, TIPO),
    CONSTRAINT FK_VENDA_1 FOREIGN KEY (INTERACAO)
        REFERENCES INTERACAO(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_VENDA_2 FOREIGN KEY (NOME_ARTISTICO, TIPO)
        REFERENCES PRODUTO(NOME_ARTISTICO, TIPO) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE EVENTO (
    DIA DATE NOT NULL,
    HORA TIME NOT NULL,
    LOCAL VARCHAR(15) NOT NULL,
    TITULO VARCHAR(15) NOT NULL,
    TIPO VARCHAR(30),
    CONSTRAINT PK_EVENTO PRIMARY KEY (DIA, HORA, LOCAL)
);

CREATE TABLE REALIZA (
    ARTISTA CHAR(14) NOT NULL,
    DIA DATE NOT NULL,
    HORA TIME NOT NULL,
    LOCAL VARCHAR(15) NOT NULL,
    CONSTRAINT PK_REALIZA PRIMARY KEY (ARTISTA, DIA, HORA, LOCAL),
    CONSTRAINT FK_REALIZA_1 FOREIGN KEY (ARTISTA)
        REFERENCES ARTISTA(CPF) ON DELETE CASCADE,
    CONSTRAINT FK_REALIZA_2 FOREIGN KEY (DIA,HORA, LOCAL)
        REFERENCES EVENTO(DIA, HORA, LOCAL) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE OFICINA (
    DIA DATE NOT NULL,
    HORA TIME NOT NULL,
    LOCAL VARCHAR(15) NOT NULL,
    NOME VARCHAR(30) NOT NULL,
    CONSTRAINT PK_OFICINA PRIMARY KEY (DIA, HORA, LOCAL),
    CONSTRAINT FK_OFICINA FOREIGN KEY (DIA, HORA, LOCAL)
        REFERENCES EVENTO (DIA, HORA, LOCAL) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TURMA (
    DIA DATE NOT NULL, 
    HORA TIME NOT NULL,
    LOCAL VARCHAR(15) NOT NULL,
    CODIGO CHAR(5) NOT NULL,
    CONSTRAINT PK_TURMA PRIMARY KEY (DIA, HORA, LOCAL, CODIGO),
    CONSTRAINT FK_TURMA FOREIGN KEY (DIA, HORA, LOCAL)
        REFERENCES OFICINA (DIA,HORA, LOCAL) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE MATRICULA (
    VISITANTE VARCHAR(15) NOT NULL,
    DIA DATE NOT NULL,
    HORA TIME NOT NULL,
    LOCAL VARCHAR(15) NOT NULL,
    CODIGO CHAR(5),
    CONSTRAINT PK_MATRICULA PRIMARY KEY (VISITANTE, DIA, HORA, LOCAL, CODIGO),
    CONSTRAINT FK_MATRICULA_1 FOREIGN KEY (VISITANTE)
        REFERENCES VISITANTE(QR_CODE) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_MATRICULA_2 FOREIGN KEY (DIA, HORA, LOCAL, CODIGO)
        REFERENCES TURMA (DIA, HORA, LOCAL, CODIGO) ON DELETE CASCADE ON UPDATE CASCADE
);

