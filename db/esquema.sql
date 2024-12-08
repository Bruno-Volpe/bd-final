CREATE TABLE IF NOT EXISTS usuario (
  email VARCHAR(255) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  senha VARCHAR(255) NOT NULL,
  data_nascimento DATE,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  url_foto_perfil TEXT,
  CONSTRAINT pk_usuario PRIMARY KEY (email)
);
CREATE TABLE IF NOT EXISTS grupo (
  codigo_acesso VARCHAR(255) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  email_admin VARCHAR(255) NOT NULL,
  CONSTRAINT pk_grupo PRIMARY KEY (codigo_acesso),
  CONSTRAINT fk_grupo_email_admin FOREIGN KEY (email_admin) REFERENCES usuario(email)
);
CREATE TABLE IF NOT EXISTS membro_do_grupo (
  id SERIAL,
  email VARCHAR(255) NOT NULL,
  codigo_acesso VARCHAR(255) NOT NULL,
  dias_ativos INTEGER DEFAULT 0,
  CONSTRAINT pk_membro_do_grupo PRIMARY KEY (id),
  CONSTRAINT fk_membro_email FOREIGN KEY (email) REFERENCES usuario(email),
  CONSTRAINT fk_membro_codigo_acesso FOREIGN KEY (codigo_acesso) REFERENCES grupo(codigo_acesso),
  CONSTRAINT unique_email_codigo_acesso UNIQUE (email, codigo_acesso)
);
CREATE TABLE IF NOT EXISTS treino (
  id SERIAL,
  membro INTEGER NOT NULL,
  nome VARCHAR(255) NOT NULL,
  dia DATE,
  CONSTRAINT pk_treino PRIMARY KEY (id),
  CONSTRAINT fk_treino_membro FOREIGN KEY (membro) REFERENCES membro_do_grupo(id),
  CONSTRAINT unique_membro_nome UNIQUE (membro, nome)
);
CREATE TABLE IF NOT EXISTS post (
  treino INTEGER NOT NULL,
  data TIMESTAMP NOT NULL,
  titulo VARCHAR(255) NOT NULL,
  url_imagem TEXT NOT NULL,
  CONSTRAINT pk_post PRIMARY KEY (treino, data),
  CONSTRAINT fk_post_treino FOREIGN KEY (treino) REFERENCES treino(id)
);
CREATE TABLE IF NOT EXISTS exercicio (
  nome VARCHAR(255),
  equipamento VARCHAR(255),
  tipo VARCHAR(255) NOT NULL,
  grupo_muscular VARCHAR(255),
  duracao INTERVAL,
  CONSTRAINT pk_exercicio PRIMARY KEY (nome)
);
CREATE TABLE IF NOT EXISTS series (
  exercicio VARCHAR(255) NOT NULL,
  ordem_do_treino INTEGER NOT NULL,
  numero_repeticoes INTEGER,
  carga NUMERIC(10, 2) NOT NULL,
  treino INTEGER NOT NULL,
  CONSTRAINT pk_series PRIMARY KEY (exercicio, ordem_do_treino),
  CONSTRAINT fk_series_exercicio FOREIGN KEY (exercicio) REFERENCES exercicio(nome),
  CONSTRAINT fk_series_treino FOREIGN KEY (treino) REFERENCES treino(id)
);