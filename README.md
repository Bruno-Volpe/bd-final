```markdown
# Documentação e Justificativa das Consultas SQL

Este documento descreve e justifica o propósito de cada uma das consultas apresentadas.  
As consultas são baseadas em um modelo de banco de dados que envolve usuários, grupos, exercícios, treinos e séries associadas.

## Consulta 5: Divisão Relacional

**Consulta:**
```sql
SELECT DISTINCT e.nome
FROM exercicio e
WHERE NOT EXISTS (
    SELECT 1
    FROM treino t
    WHERE NOT EXISTS (
        SELECT 1
        FROM series s
        WHERE s.exercicio = e.nome
          AND s.treino = t.id
    )
);
```

**O que faz:**  
Esta consulta utiliza o operador "divisão relacional" por meio de subconsultas aninhadas. A ideia é encontrar todos os exercícios (`exercicio`) que aparecem em *todos* os treinos (`treino`) existentes. Ou seja, a consulta retorna apenas o nome dos exercícios que foram incluídos em todos os treinos do sistema.

**Justificativa:**  
A consulta é útil quando se deseja identificar exercícios onipresentes, usados em qualquer treino do conjunto completo de treinos. Isso pode ajudar na análise de exercícios fundamentais no planejamento de condicionamento físico.

---

## Consulta 6: Usuários com Mais Dias Ativos em Cada Grupo

**Consulta:**
```sql
SELECT g.nome AS grupo_nome,
       u.email AS usuario_email,
       u.nome AS usuario_nome,
       m.dias_ativos
FROM membro_do_grupo m
JOIN usuario u ON m.email = u.email
JOIN grupo g ON m.codigo_acesso = g.codigo_acesso
WHERE m.dias_ativos = (
    SELECT MAX(mg.dias_ativos)
    FROM membro_do_grupo mg
    WHERE mg.codigo_acesso = m.codigo_acesso
)
ORDER BY g.nome;
```

**O que faz:**  
Esta consulta retorna, para cada grupo, o(s) usuário(s) que possui(em) o maior número de dias ativos. Caso haja mais de um usuário empatado no primeiro lugar, todos serão listados.

**Justificativa:**  
A consulta é valiosa para entender o engajamento de membros em grupos. Administradores podem identificar quem são os usuários mais participativos, auxiliando no reconhecimento de membros ativos ou no planejamento de atividades específicas para estimular o envolvimento.

---

## Consulta 7: Grupos sem Membros

**Consulta:**
```sql
SELECT g.codigo_acesso,
       g.nome AS grupo_nome,
       g.email_admin
FROM grupo g
LEFT JOIN membro_do_grupo m ON g.codigo_acesso = m.codigo_acesso
WHERE m.codigo_acesso IS NULL;
```

**O que faz:**  
Esta consulta encontra todos os grupos que não possuem nenhum membro associado. Isso é feito por meio de um `LEFT JOIN` entre `grupo` e `membro_do_grupo`. Ao verificar as tuplas nulas em `m.codigo_acesso`, garantimos que não haja membros naquele grupo.

**Justificativa:**  
Fornece um relatório de grupos inativos ou recém-criados sem participantes. Isso ajuda administradores a identificar grupos que possam necessitar de divulgação, exclusão ou reconfiguração.

---

## Consulta 8: Grupos que Têm Todos os Usuários como Membros

**Consulta:**
```sql
SELECT g.nome AS grupo_nome,
       g.codigo_acesso
FROM grupo g
WHERE NOT EXISTS (
    SELECT u.email
    FROM usuario u
    WHERE NOT EXISTS (
        SELECT m.email
        FROM membro_do_grupo m
        WHERE m.email = u.email
          AND m.codigo_acesso = g.codigo_acesso
    )
);
```

**O que faz:**  
Esta consulta identifica grupos que incluem todos os usuários do sistema. Primeiro, selecionamos todos os usuários, e então, por meio da negação com `NOT EXISTS`, filtramos apenas os grupos nos quais não exista ao menos um usuário que não seja membro. Em outras palavras, se um grupo contém todos os usuários cadastrados, ele é retornado.

**Justificativa:**  
Útil para detectar grupos “globais” ou “gerais”, garantindo que todo o conjunto de usuários faça parte daquela comunidade. Pode servir para grupos padrão, obrigatórios ou de comunicação geral da plataforma.

---

## Consulta 9: Relatório de Treinos com o Total de Exercícios e Carga Média por Grupo Muscular

**Consulta:**
```sql
SELECT t.nome AS treino_nome,
       e.grupo_muscular,
       COUNT(s.exercicio) AS total_exercicios,
       ROUND(AVG(s.carga), 2) AS carga_media
FROM treino t
JOIN series s ON t.id = s.treino
JOIN exercicio e ON s.exercicio = e.nome
GROUP BY t.nome, e.grupo_muscular
ORDER BY t.nome, e.grupo_muscular;
```

**O que faz:**  
Esta consulta gera um relatório detalhado por treino, mostrando para cada treino (`treino`), separado por grupo muscular (`exercicio.grupo_muscular`), quantos exercícios foram realizados e a carga média utilizada. A função `COUNT` conta a quantidade de exercícios, enquanto `AVG` calcula a carga média, e `ROUND` formata o resultado para duas casas decimais.

**Justificativa:**  
Fornece métricas importantes de desempenho e planejamento do treino. Com este relatório é possível analisar a intensidade média (carga) e a variedade (quantidade) de exercícios por grupo muscular em cada treino, auxiliando treinadores e alunos a entenderem o equilíbrio e a eficiência do programa de exercícios.

---

**Conclusão:**  
As consultas apresentadas têm diferentes propósitos, desde a identificação de padrões em exercícios e treinos, até a análise do engajamento de membros em grupos e a verificação de completude de participação. Cada consulta traz insights específicos que podem auxiliar administradores, usuários e gestores de conteúdo a tomar decisões informadas sobre ajustes, melhorias ou monitoramento do sistema.
```