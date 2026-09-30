# Vault of Us: próximos passos

Este guia leva do projeto no computador até uma primeira validação nos dois iPhones. Você precisará configurar o Supabase e publicar a PWA no Render ou Vercel. **Não envie senhas, chaves, tokens, arquivos `.env` ou links privados de convite para ninguém.**

## 1. Criar o backend no Supabase

1. Crie um projeto no [Supabase](https://supabase.com/) e guarde o **Project Reference** e a **Project URL**. Em **Project Settings → API**, copie a chave publicável (ou `anon`). Não use a `service_role` na PWA.
2. Abra o PowerShell e entre na pasta:

   ```powershell
   cd C:\Projetos\vault_of_us\pwa
   npm install
   npm install --save-dev supabase
   npx supabase login
   npx supabase link --project-ref SEU_PROJECT_REF
   npx supabase db push --dry-run
   ```

   Confira se o projeto mostrado é o seu. Se estiver correto, aplique as migrações:

   ```powershell
   npx supabase db push
   ```

3. No Supabase, habilite cadastro por e-mail em **Authentication**. Depois da publicação, inclua a URL do app nas URLs permitidas de redirecionamento.

## 2. Configurar e publicar as funções do chat

1. Gere as chaves VAPID:

   ```powershell
   npx web-push generate-vapid-keys
   ```

   Mantenha a chave privada VAPID somente nos secrets do Supabase.

2. Copie e edite o arquivo de configuração pública da PWA:

   ```powershell
   Copy-Item .env.example .env
   notepad .env
   ```

   Preencha `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` e `VITE_WEB_PUSH_PUBLIC_KEY` com a URL, a chave publicável e a chave **pública** VAPID.

3. Crie `supabase/secrets.env` e preencha com a chave pública e privada VAPID, o assunto e um segredo aleatório longo:

   ```dotenv
   VAPID_PUBLIC_KEY=mesma_chave_publica_do_arquivo_env
   VAPID_PRIVATE_KEY=chave_privada_vapid
   VAPID_SUBJECT=mailto:seu-email@exemplo.com
   CRON_SHARED_SECRET=segredo_aleatorio_longo
   ```

   Envie os secrets e publique as duas funções:

   ```powershell
   npx supabase secrets set --env-file supabase/secrets.env
   npx supabase functions deploy send-message-push
   npx supabase functions deploy cleanup-expired-chat
   ```

4. No **SQL Editor** do Supabase, crie os dois secrets do Vault. Substitua `SEU_PROJECT_REF` pelo identificador que aparece na URL do projeto e o texto de exemplo pelo valor original de `CRON_SHARED_SECRET` em `pwa/supabase/secrets.env`:

   ```sql
   select vault.create_secret(
     'https://SEU_PROJECT_REF.supabase.co/functions/v1/cleanup-expired-chat',
     'vault-of-us-cleanup-url'
   );

   select vault.create_secret(
     'COLE_AQUI_O_VALOR_DE_CRON_SHARED_SECRET',
     'vault-of-us-cleanup-secret'
   );
   ```

   Se já criou `vault-of-us-cleanup-secret` com valor errado, atualize-o em vez de executar `create_secret` de novo:

   ```sql
   select vault.update_secret(
     (select id from vault.secrets where name = 'vault-of-us-cleanup-secret'),
     'COLE_AQUI_O_VALOR_DE_CRON_SHARED_SECRET'
   );
   ```

   Não salve uma consulta que contenha o valor secreto. Depois abra [`pwa/supabase/schedule-cleanup.example.sql`](pwa/supabase/schedule-cleanup.example.sql), copie todo o conteúdo para uma **nova consulta** no SQL Editor e clique em **Run**. Isso agenda a remoção física das mensagens e mídias vencidas. O banco bloqueia a leitura após uma hora mesmo antes dessa limpeza.

## 3. Publicar a PWA

Vercel e Render também hospedam esta PWA estática por HTTPS. Escolha **uma** opção:

### Vercel

1. Coloque o projeto em um repositório Git e importe-o no [Vercel](https://vercel.com/).
2. Defina **Root Directory** como `pwa`, **Build Command** como `npm run build` e **Output Directory** como `dist`.
3. Em **Environment Variables**, cadastre `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` e `VITE_WEB_PUSH_PUBLIC_KEY` para produção e faça o deploy.

No plano Hobby, o uso deve ser pessoal e não comercial; veja as [condições do plano](https://vercel.com/docs/plans/hobby). O Vercel não aplica o arquivo `_headers` do Cloudflare. Configure nele os cabeçalhos de segurança equivalentes descritos abaixo; eles são necessários para manter a política de conteúdo e permitir conexão segura com Supabase.

### Render

1. Coloque o projeto em um repositório Git e crie no [Render](https://render.com/) um **Static Site** ligado a esse repositório.
2. Defina **Root Directory** como `pwa`, **Build Command** como `npm ci && npm run build` e **Publish Directory** como `dist`.
3. Cadastre as mesmas três variáveis `VITE_*` nas variáveis de ambiente do site e faça o deploy.
4. Em **Custom Headers**, configure para `/*` os mesmos cabeçalhos de segurança listados abaixo. O Render permite defini-los no painel; o arquivo `_headers` do Cloudflare não é aplicado automaticamente.

Os dois serviços fornecem HTTPS para a PWA. No Render, sites estáticos podem usar o plano gratuito, sujeito aos limites mensais de banda e build; confira o painel e os [limites atuais](https://render.com/docs/free).

### Cabeçalhos de segurança

Para Vercel ou Render, configure estes cabeçalhos HTTP para `/*` (no Vercel via `vercel.json`; no Render via **Custom Headers**):

| Cabeçalho | Valor |
|---|---|
| `Content-Security-Policy` | `default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'; form-action 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' blob: data:; media-src 'self' blob:; font-src 'self' data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co; worker-src 'self' blob:; manifest-src 'self'` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | `camera=(), microphone=(self), geolocation=()` |
| `X-Frame-Options` | `DENY` |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` |

Após o deploy, copie o endereço HTTPS fornecido pelo host e cadastre-o nas URLs permitidas do Supabase Auth. As variáveis `VITE_*` são públicas no bundle do frontend; nunca coloque uma chave privada ou `service_role` nelas.

## 4. Instalar e validar nos iPhones

Em cada iPhone, abra o endereço publicado no **Safari**, escolha **Compartilhar → Adicionar à Tela de Início** e abra pelo ícone novo. Crie um cofre local com senha própria. Importe uma foto de teste; a cópia deve aparecer no cofre, e o original continuará no app Fotos.

Depois valide, com fotos sem importância:

- Cadastrem uma conta de chat em cada aparelho e pareiem pelo convite privado.
- Enviem uma foto. No iPhone que recebe, confirmem que é possível visualizá-la e escolher **Salvar no meu cofre**.
- Enviem outra foto e não a salvem. Após uma hora, confirmem que não abre mais.
- Ativem **Ativar avisos** nos dois aparelhos e enviem uma mensagem com um deles em segundo plano. O aviso deve ser genérico, sem conteúdo da mensagem.
- Criem uma lembrança e um item em **A dois**; confirmem que aparecem no outro aparelho após sincronizar.

Push no iPhone requer iOS/iPadOS 16.4 ou posterior, PWA instalada pela Tela de Início e permissão de notificação concedida. A PWA não impede capturas de tela e não consegue apagar uma cópia salva ou capturada antes do vencimento.

## Se algo falhar

Anote o número do passo, a mensagem de erro e o modelo/versão do iOS. Envie essas informações sem incluir senhas, tokens, chaves, conteúdo de fotos ou arquivos `.env`; eu continuo a partir do ponto que falhou. Não é preciso repetir os passos que já deram certo.

O plano gratuito do Supabase pode pausar projetos inativos; consulte [preços e limites atuais](https://supabase.com/pricing). Mais detalhes da arquitetura e das limitações estão no [README](README.md).
