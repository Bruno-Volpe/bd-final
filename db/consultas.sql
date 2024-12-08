-- 1. Buscar todos os usuários ativos

SELECT *
FROM usuario;

-- 2. Buscar membros de um grupo específico

SELECT u.email,
       u.nome,
       m.dias_ativos
FROM membro_do_grupo m
INNER JOIN usuario u ON m.email = u.email
WHERE m.codigo_acesso = 'group1';

-- 3. Buscar exercícios de um treino

SELECT e.nome,
       e.grupo_muscular,
       s.numero_repeticoes,
       s.carga
FROM series s
INNER JOIN exercicio e ON s.exercicio = e.nome
WHERE s.treino = 1;

-- 4. Relatório de treinos e exercícios

SELECT t.nome AS treino,
       e.nome AS exercicio,
       s.numero_repeticoes,
       s.carga
FROM treino t
INNER JOIN series s ON t.id = s.treino
INNER JOIN exercicio e ON s.exercicio = e.nome;

-- 5. Consulta de divisão relacional

SELECT DISTINCT e.nome
FROM exercicio e
WHERE NOT EXISTS
    (SELECT 1
     FROM treino t
     WHERE NOT EXISTS
         (SELECT 1
          FROM series s
          WHERE s.exercicio = e.nome
            AND s.treino = t.id ) );

-- Consulta 6: Usuários com mais dias ativos em cada grupo
 -- Esta consulta retorna os usuários com mais dias ativos
-- em cada grupo, junto com o nome do grupo.

SELECT g.nome AS grupo_nome,
       u.email AS usuario_email,
       u.nome AS usuario_nome,
       m.dias_ativos
FROM membro_do_grupo m
JOIN usuario u ON m.email = u.email
JOIN grupo g ON m.codigo_acesso = g.codigo_acesso
WHERE m.dias_ativos =
    (SELECT MAX(mg.dias_ativos)
     FROM membro_do_grupo mg
     WHERE mg.codigo_acesso = m.codigo_acesso )
ORDER BY g.nome;

-- Consulta 7: Grupos sem membros
 -- Esta consulta retorna todos os grupos que ainda não têm
-- nenhum membro associado.

SELECT g.codigo_acesso,
       g.nome AS grupo_nome,
       g.email_admin
FROM grupo g
LEFT JOIN membro_do_grupo m ON g.codigo_acesso = m.codigo_acesso
WHERE m.codigo_acesso IS NULL;

-- Consulta 8: Grupos que têm todos os usuários como membros
 -- Esta consulta identifica os grupos que têm todos os usuários
-- cadastrados no sistema como membros.

SELECT g.nome AS grupo_nome,
       g.codigo_acesso
FROM grupo g
WHERE NOT EXISTS
    (SELECT u.email
     FROM usuario u
     WHERE NOT EXISTS
         (SELECT m.email
          FROM membro_do_grupo m
          WHERE m.email = u.email
            AND m.codigo_acesso = g.codigo_acesso ) );

-- Consulta 9: Relatório de treinos com o total de exercícios
-- e a carga média por grupo muscular
 -- Esta consulta fornece um relatório de treinos, listando
-- o total de exercícios realizados e a carga média agrupada
-- por grupo muscular.

SELECT t.nome AS treino_nome,
       e.grupo_muscular,
       COUNT(s.exercicio) AS total_exercicios,
       ROUND(AVG(s.carga), 2) AS carga_media
FROM treino t
JOIN series s ON t.id = s.treino
JOIN exercicio e ON s.exercicio = e.nome
GROUP BY t.nome,
         e.grupo_muscular
ORDER BY t.nome,
         e.grupo_muscular;