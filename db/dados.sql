INSERT INTO usuario (
    email,
    nome,
    senha,
    data_nascimento,
    url_foto_perfil
  )
VALUES (
    'john.doe@example.com',
    'John Doe',
    '123456',
    '1990-01-01',
    'https://example.com/john.jpg'
  ),
  (
    'jane.doe@example.com',
    'Jane Doe',
    'abcdef',
    '1992-05-10',
    'https://example.com/jane.jpg'
  ) ON CONFLICT DO NOTHING;
INSERT INTO grupo (codigo_acesso, nome, criado_em, email_admin)
VALUES (
    'group1',
    'Grupo A',
    CURRENT_TIMESTAMP,
    'john.doe@example.com'
  ),
  (
    'group2',
    'Grupo B',
    CURRENT_TIMESTAMP,
    'jane.doe@example.com'
  ) ON CONFLICT DO NOTHING;
INSERT INTO membro_do_grupo (email, codigo_acesso, dias_ativos)
VALUES ('john.doe@example.com', 'group1', 10),
  ('jane.doe@example.com', 'group2', 15) ON CONFLICT DO NOTHING;
INSERT INTO treino (membro, nome, dia)
VALUES (1, 'Treino A', '2024-12-01'),
  (2, 'Treino B', '2024-12-02') ON CONFLICT DO NOTHING;
INSERT INTO post (treino, data, titulo, url_imagem)
VALUES (
    1,
    '2024-12-01 08:00:00',
    'Post do Treino A',
    'https://example.com/treino_a.jpg'
  ),
  (
    2,
    '2024-12-02 10:00:00',
    'Post do Treino B',
    'https://example.com/treino_b.jpg'
  ) ON CONFLICT DO NOTHING;
INSERT INTO exercicio (nome, equipamento, tipo, grupo_muscular, duracao)
VALUES (
    'Supino',
    'Halteres',
    'Força',
    'Peitoral',
    '00:30:00'
  ),
  (
    'Agachamento',
    'Barra',
    'Força',
    'Pernas',
    '00:45:00'
  ) ON CONFLICT DO NOTHING;
INSERT INTO series (
    exercicio,
    ordem_do_treino,
    numero_repeticoes,
    carga,
    treino
  )
VALUES ('Supino', 1, 10, 20.0, 1),
  ('Agachamento', 1, 12, 50.0, 2) ON CONFLICT DO NOTHING;