import psycopg2
from datetime import datetime

# Configuração da conexão com o banco
DB_CONFIG = {
    "host": "localhost",
    "database": "mydb",
    "user": "user",
    "password": "password",
    "port": 5433
}

# Exibição do banner ASCII ao iniciar o programa
print("""                                
 _____       _   _         
| __  |___ _| |_| |_ _ ___ 
| __ -| . | . | . | | |_ -|
|_____|___|___|___|_  |___|
                  |___|     
""")

def connect_to_db():
    """
    Conecta ao banco de dados usando as configurações definidas em DB_CONFIG.
    Retorna uma conexão ativa ou None caso haja falha.
    """
    try:
        return psycopg2.connect(**DB_CONFIG)
    except psycopg2.Error as e:
        print("Erro ao conectar ao banco de dados:", e)
        return None

# --- Validações de Entrada ---
def validar_email(email):
    """
    Verifica se o formato do email é válido.
    Retorna True se válido, senão retorna False.
    """
    if "@" not in email or "." not in email.split("@")[-1]:
        print("Erro: O email informado não é válido.")
        return False
    return True

def validar_data(data):
    """
    Valida se a data fornecida está no formato YYYY-MM-DD.
    Retorna True se válido, senão retorna False.
    """
    try:
        datetime.strptime(data, "%Y-%m-%d")
        return True
    except ValueError:
        print("Erro: A data informada não é válida. Use o formato YYYY-MM-DD.")
        return False

def validar_campo_vazio(valor, nome_campo):
    """
    Verifica se o valor de um campo obrigatório está vazio.
    Retorna True se preenchido, senão retorna False.
    """
    if not valor.strip():
        print(f"Erro: O campo '{nome_campo}' não pode estar vazio.")
        return False
    return True

# --- Funções de Usuário ---
def cadastrar_usuario():
    """
    Cadastra um novo usuário no sistema.
    Solicita informações básicas do usuário e realiza validações antes de inserir no banco.
    """
    email = input("Digite o email: ")
    if not validar_email(email):
        return

    nome = input("Digite o nome: ")
    if not validar_campo_vazio(nome, "nome"):
        return

    senha = input("Digite a senha: ")
    if not validar_campo_vazio(senha, "senha"):
        return

    data_nascimento = input("Digite a data de nascimento (YYYY-MM-DD): ")
    if not validar_data(data_nascimento):
        return

    url_foto_perfil = input("Digite a URL da foto de perfil (opcional): ")

    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = """
        INSERT INTO usuario (email, nome, senha, data_nascimento, url_foto_perfil)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING email;
        """
        cursor.execute(query, (email, nome, senha, data_nascimento, url_foto_perfil or None))
        conn.commit()
        print(f"Usuário {cursor.fetchone()[0]} cadastrado com sucesso!")
    except psycopg2.errors.UniqueViolation:
        print(f"Erro: O email '{email}' já está cadastrado no sistema.")
        conn.rollback()
    except psycopg2.Error as e:
        print("Erro ao cadastrar usuário:", e)
        conn.rollback()
    finally:
        if conn:
            cursor.close()
            conn.close()

def pesquisar_todos_usuarios():
    """
    Lista todos os usuários cadastrados no sistema.
    Exibe email e nome dos usuários.
    """
    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = "SELECT email, nome FROM usuario;"
        cursor.execute(query)
        results = cursor.fetchall()

        print("\nUsuários cadastrados:")
        for row in results:
            print(f"Email: {row[0]}, Nome: {row[1]}")
    except psycopg2.Error as e:
        print("Erro ao pesquisar usuários:", e)
    finally:
        if conn:
            cursor.close()
            conn.close()

# --- Funções de Grupo ---
def criar_grupo():
    """
    Cria um novo grupo no sistema.
    Solicita informações básicas como código, nome e email do administrador.
    """
    codigo_acesso = input("Digite o código de acesso do grupo: ")
    if not validar_campo_vazio(codigo_acesso, "código de acesso"):
        return

    nome = input("Digite o nome do grupo: ")
    if not validar_campo_vazio(nome, "nome do grupo"):
        return

    email_admin = input("Digite o email do administrador do grupo: ")
    if not validar_email(email_admin):
        return

    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = """
        INSERT INTO grupo (codigo_acesso, nome, criado_em, email_admin)
        VALUES (%s, %s, CURRENT_TIMESTAMP, %s)
        RETURNING codigo_acesso;
        """
        cursor.execute(query, (codigo_acesso, nome, email_admin))
        conn.commit()
        print(f"Grupo '{codigo_acesso}' criado com sucesso!")
    except psycopg2.errors.ForeignKeyViolation:
        print(f"Erro: O administrador '{email_admin}' não existe.")
        conn.rollback()
    except psycopg2.errors.UniqueViolation:
        print(f"Erro: O código de acesso '{codigo_acesso}' já está em uso.")
        conn.rollback()
    except psycopg2.Error as e:
        print("Erro ao criar grupo:", e)
        conn.rollback()
    finally:
        if conn:
            cursor.close()
            conn.close()

def entrar_no_grupo():
    """
    Adiciona um usuário a um grupo existente.
    Solicita o email do usuário e o código do grupo.
    """
    email = input("Digite o email do usuário: ")
    if not validar_email(email):
        return

    codigo_acesso = input("Digite o código de acesso do grupo: ")
    if not validar_campo_vazio(codigo_acesso, "código de acesso"):
        return

    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = """
        INSERT INTO membro_do_grupo (email, codigo_acesso)
        VALUES (%s, %s)
        RETURNING id;
        """
        cursor.execute(query, (email, codigo_acesso))
        conn.commit()
        print(f"Usuário {email} entrou no grupo {codigo_acesso} com sucesso!")
    except psycopg2.errors.ForeignKeyViolation:
        print(f"Erro: O email '{email}' ou o grupo '{codigo_acesso}' não existem.")
        conn.rollback()
    except psycopg2.errors.UniqueViolation:
        print(f"Erro: O usuário '{email}' já é membro do grupo '{codigo_acesso}'.")
        conn.rollback()
    except psycopg2.Error as e:
        print("Erro ao adicionar usuário ao grupo:", e)
        conn.rollback()
    finally:
        if conn:
            cursor.close()
            conn.close()

def pesquisar_todos_grupos():
    """
    Lista todos os grupos cadastrados.
    Exibe o código de acesso e o nome do grupo.
    """
    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = "SELECT codigo_acesso, nome FROM grupo;"
        cursor.execute(query)
        results = cursor.fetchall()

        print("\nGrupos cadastrados:")
        for row in results:
            print(f"Código de Acesso: {row[0]}, Nome: {row[1]}")
    except psycopg2.Error as e:
        print("Erro ao pesquisar grupos:", e)
    finally:
        if conn:
            cursor.close()
            conn.close()

def pesquisar_usuario_por_grupo():
    """
    Lista todos os usuários de um grupo, buscando pelo nome do grupo.
    """
    nome_grupo = input("Digite o nome do grupo: ")
    if not validar_campo_vazio(nome_grupo, "nome do grupo"):
        return

    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = """
        SELECT u.email, u.nome, m.dias_ativos
        FROM membro_do_grupo m
        INNER JOIN usuario u ON m.email = u.email
        INNER JOIN grupo g ON m.codigo_acesso = g.codigo_acesso
        WHERE g.nome = %s;
        """
        cursor.execute(query, (nome_grupo,))
        results = cursor.fetchall()

        if results:
            print(f"\nMembros do grupo '{nome_grupo}':")
            for row in results:
                print(f"Email: {row[0]}, Nome: {row[1]}, Dias Ativos: {row[2]}")
        else:
            print(f"Nenhum membro encontrado no grupo '{nome_grupo}'.")
    except psycopg2.Error as e:
        print("Erro ao pesquisar usuários por grupo:", e)
    finally:
        if conn:
            cursor.close()
            conn.close()

def usuarios_mais_ativos_por_grupo():
    """
    Exibe os usuários com mais dias ativos em cada grupo.
    """
    try:
        conn = connect_to_db()
        if not conn:
            return
        cursor = conn.cursor()

        query = """
        SELECT 
            g.nome AS grupo_nome,
            u.email AS usuario_email,
            u.nome AS usuario_nome,
            m.dias_ativos
        FROM 
            membro_do_grupo m
        JOIN 
            usuario u ON m.email = u.email
        JOIN 
            grupo g ON m.codigo_acesso = g.codigo_acesso
        WHERE 
            m.dias_ativos = (
                SELECT MAX(mg.dias_ativos)
                FROM membro_do_grupo mg
                WHERE mg.codigo_acesso = m.codigo_acesso
            )
        ORDER BY g.nome;
        """
        cursor.execute(query)
        results = cursor.fetchall()

        if results:
            print("\nUsuários com mais dias ativos por grupo:")
            for row in results:
                print(f"Grupo: {row[0]}, Email: {row[1]}, Nome: {row[2]}, Dias Ativos: {row[3]}")
        else:
            print("Nenhum dado encontrado.")
    except psycopg2.Error as e:
        print("Erro ao buscar usuários mais ativos por grupo:", e)
    finally:
        if conn:
            cursor.close()
            conn.close()

# --- Menu Principal ---
def menu():
    """
    Menu principal do sistema.
    Exibe as opções e chama as funções correspondentes.
    """
    while True:
        print("\nMenu do Sistema:")
        print("1. Cadastrar usuário")
        print("2. Pesquisar todos os usuários")
        print("3. Criar grupo")
        print("4. Entrar no grupo")
        print("5. Pesquisar todos os grupos")
        print("6. Pesquisar usuários por grupo")
        print('7. Usuários mais ativos por grupo')
        print("\n8. Sair")

        escolha = input("\nEscolha uma opção: ")

        if escolha == "1":
            cadastrar_usuario()
        elif escolha == "2":
            pesquisar_todos_usuarios()
        elif escolha == "3":
            criar_grupo()
        elif escolha == "4":
            entrar_no_grupo()
        elif escolha == "5":
            pesquisar_todos_grupos()
        elif escolha == "6":
            pesquisar_usuario_por_grupo()
        elif escolha == "7":
            usuarios_mais_ativos_por_grupo()
        elif escolha == "8":
            print("Saindo do sistema...")
            break
        else:
            print("Opção inválida. Tente novamente.")

if __name__ == "__main__":
    print("Bem-vindo ao Sistema de Gestão de Usuários e Grupos!")
    menu()
