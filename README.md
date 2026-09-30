# Vault of Us

Aplicativo privado para guardar fotos e vídeos cifrados no próprio aparelho, com conversa de mídia temporária entre duas contas. O cofre local é uma PWA independente do protótipo Flutter para Windows.

## Rodar no computador

Requisitos: Node.js 20.19+ ou 22.12+.

```powershell
cd C:\Projetos\vault_of_us\pwa
npm install
npm run dev
```

Abra o endereço local que o Vite mostrar. Sem configurar Supabase, Cofre, Memórias, A dois e backup local já funcionam; o Chat mostra as regras e avisa que o serviço não foi configurado. O armazenamento fica no perfil do navegador deste computador.

Para gerar a versão de publicação:

```powershell
npm run build
npm run preview
```

## Como instalar nos iPhones

Publique `pwa/dist` em um endereço HTTPS. Em cada iPhone, abra o endereço pelo Safari, use **Compartilhar → Adicionar à Tela de Início** e abra pelo ícone instalado. Cada aparelho cria seu próprio cofre e sua própria senha; os arquivos importados não são enviados para servidor. Web Push no iPhone requer iOS/iPadOS 16.4 ou posterior, instalação na Tela de Início e configuração do serviço push abaixo.

Dados locais de sites podem ser apagados pelo usuário ou pelo sistema. Em Ajustes, peça persistência e exporte backups cifrados periodicamente. Guarde a senha exclusiva do backup separada do arquivo; sem ela, não é possível restaurá-lo. O limite desta versão para cada foto/vídeo importado é 200 MB.

## Configurar o chat e notificações

O chat usa Supabase apenas para autenticação e encaminhamento temporário de texto/mídia cifrada ponta a ponta no cliente. Mídias são limitadas a 50 MB, ficam no bucket privado `chat-temp`, e o banco define a expiração em uma hora. O receptor escolhe salvar no próprio cofre; o remetente não controla essa opção. O serviço precisa estar online para enviar/receber, mesmo que o cofre continue acessível offline. Configure um projeto Supabase próprio; não há chaves ou projeto vinculados a este repositório.

1. Crie um projeto Supabase e instale a CLI oficial (por exemplo, dentro de `pwa`: `npm install --save-dev supabase`). No PowerShell, execute `npx supabase login` e `npx supabase link --project-ref SEU_PROJECT_REF` dentro de `pwa`.
2. Revise as alterações pendentes com `npx supabase db push --dry-run`; confira se o projeto vinculado é o correto e aplique com `npx supabase db push`. As migrações em `supabase/migrations/` criam o chat, pareamento, RLS, bucket privado, validade de uma hora e a tabela de registros compartilhados cifrados (lembranças, comentários e itens de A dois). Configure cadastro/autenticação por e-mail no projeto Supabase.
3. Gere chaves VAPID com `npx web-push generate-vapid-keys`. Copie `.env.example` para `.env` e preencha URL do projeto, chave publicável/anon e chave pública VAPID. **Nunca use a service-role key no arquivo `.env` da PWA ou no frontend.**
4. Crie `supabase/secrets.env` dentro de `pwa` com as chaves privadas das funções (esse nome está no `.gitignore`):

   ```dotenv
   VAPID_PUBLIC_KEY=mesma_chave_publica_usada_no_frontend
   VAPID_PRIVATE_KEY=chave_privada_vapid
   VAPID_SUBJECT=mailto:seu-email@exemplo.com
   CRON_SHARED_SECRET=segredo_aleatorio_longo
   ```

   Gere `CRON_SHARED_SECRET` aleatoriamente; mantenha esse arquivo fora do Git. Publique as funções com `npx supabase functions deploy send-message-push` e `npx supabase functions deploy cleanup-expired-chat`; envie as variáveis privadas com `npx supabase secrets set --env-file supabase/secrets.env`.
5. No Supabase Vault, grave `https://SEU_PROJECT_REF.supabase.co/functions/v1/cleanup-expired-chat` como `vault-of-us-cleanup-url` e o mesmo `CRON_SHARED_SECRET` como `vault-of-us-cleanup-secret`. Rode `supabase/schedule-cleanup.example.sql` uma vez no SQL Editor. O agendamento chama a função a cada minuto. Mensagens expiradas deixam de ser visíveis por RLS imediatamente; a rotina apaga a linha e o objeto do Storage.
6. Publique a PWA como site estático HTTPS no Render ou Vercel. O guia [`PROXIMOS_PASSOS.md`](PROXIMOS_PASSOS.md) traz os comandos/configurações de build, variáveis públicas e cabeçalhos de segurança para cada serviço. Cadastre a URL HTTPS publicada nas URLs permitidas de Auth do Supabase. Nunca envie `.env` nem `supabase/secrets.env` ao repositório.
7. Em cada iPhone, abra a URL publicada no Safari e escolha **Compartilhar → Adicionar à Tela de Início**. Abra pelo novo ícone, crie um cofre local, cadastre/entre na conta de chat e pareie. Para aceitar o convite, a pessoa que recebe deve entrar pelo ícone instalado, fazer login e colar o link em **Já recebeu um convite?**. O WebKit pode isolar o armazenamento da PWA e da aba Safari. Em cada aparelho, ative notificações dentro da conversa.

### Conferência após publicar

Faça a primeira validação com fotos sem importância e sem depender de backups únicos:

1. Instale a PWA pelo Safari nos dois iPhones. Em cada um, crie uma senha de cofre diferente e importe uma foto de teste. Confirme que a cópia aparece no cofre do app; o original continua na biblioteca Fotos, pois a PWA não pode apagá-lo.
2. Com os dois aparelhos online, crie duas contas de chat e pareie pelo convite privado. Em **A dois**, crie uma lista e confira que ela chega ao outro aparelho depois de sincronizar.
3. Ative as notificações em cada instalação. Com um aparelho em segundo plano, envie uma mensagem do outro. A notificação deve dizer apenas que chegou uma mensagem, sem texto, imagem nem nome de quem enviou.
4. Envie uma foto e confirme que o destinatário consegue visualizá-la e escolher **Salvar no meu cofre**. Salve em um dos aparelhos e confira que a cópia aparece no cofre local desse aparelho. Repita sem salvar e deixe a mensagem vencer.
5. Após uma hora do envio, confirme que a mensagem vencida não pode mais ser aberta. A limpeza do banco e do Storage roda a cada minuto; a leitura já deve estar bloqueada no horário de expiração, mesmo antes da limpeza física.
6. Crie um backup cifrado de teste e restaure-o em um aparelho de teste ou depois de exportar um backup atual do destino. A restauração substitui o armazenamento local escolhido e exige tanto a senha exclusiva do arquivo quanto a senha original do cofre.
7. Depois de visitar o app uma vez enquanto online, ative o modo avião e abra novamente o ícone instalado. Confirme que o cofre e as memórias locais continuam disponíveis. O chat e os registros compartilhados precisam de rede para sincronizar.

Se uma etapa falhar, consulte os logs da função no Supabase e os limites do projeto antes de repetir envios de arquivos. Push no iPhone depende de versão compatível do iOS, instalação pela Tela de Início, permissão concedida e chaves VAPID correspondentes entre frontend e função.

Veja o [guia de instalação da CLI do Supabase](https://supabase.com/docs/guides/local-development/cli/getting-started), [deploy de funções](https://supabase.com/docs/guides/functions/deploy) e [secrets das funções](https://supabase.com/docs/guides/functions/secrets). As contas externas e o projeto Supabase são configurados pelo proprietário.

### Custo e disponibilidade

Na tabela atual, Supabase Free custa US$ 0 e inclui 1 GB de arquivos, limites mensais de uso e até dois projetos ativos; projetos gratuitos podem ser pausados após uma semana sem atividade. Como as mídias do chat expiram em uma hora, o uso de armazenamento deve permanecer baixo, mas o chat depende de o projeto estar ativo e dentro das cotas. Confira os [limites e preços atuais do Supabase](https://supabase.com/pricing) antes de escolher um plano; não é necessário contratar plano pago para iniciar, mas este modo gratuito não garante disponibilidade contínua.

Push é genérico por privacidade (não inclui texto, fotos nem remetente). Sem a limpeza agendada, a política do banco ainda bloqueia leitura de mensagens vencidas, mas arquivos e registros podem continuar ocupando espaço no projeto. Supabase é armazenamento remoto de **ciphertext temporário do chat** e de **ciphertext persistente de notas/listas/metas/datas compartilhadas**; ele não guarda cópias do cofre local. Registros compartilhados sincronizam ao abrir Memórias/A dois ou ao tocar em **Sincronizar**; alterações feitas sem rede ficam locais e serão conciliadas quando o serviço voltar. Os textos permanecem cifrados de ponta a ponta, enquanto o servidor vê o vínculo do casal, IDs e horários de atualização.

## Arquitetura e limites conhecidos

- **Cofre:** IndexedDB com AES-256-GCM; chave aleatória cifrada por senha com PBKDF2-SHA-256 (600.000 iterações). Nome, data, dimensões, hash, álbuns e metadados de mídia também ficam cifrados. Importações idênticas são reconhecidas por SHA-256; JPEG pode fornecer `DateTimeOriginal` para a linha do tempo. Álbuns, favoritos, lixeira e cópias salvas são locais a cada aparelho. Notas de Memórias/Journal, comentários e listas, metas, datas e cápsulas são locais cifradas primeiro e, depois do pareamento, sincronizadas cifradas entre as duas contas. As mídias do cofre continuam locais. O Journal Anual pode compilar uma retrospectiva cifrada com até oito lembranças e oito mídias do ano, atualizada no mesmo registro ao refazer.
- **Visualização:** miniaturas cifradas, tela ampliada com zoom, dimensões, tipo, tamanho e data de captura. No momento, a data EXIF é lida de JPEG; vídeo e outros campos EXIF não são decodificados. Safari 17/iOS 17 adicionou suporte a imagens HEIC/HEIF; versões anteriores podem pedir que a foto seja exportada como JPEG.
- **Chat:** texto, foto, vídeo e áudio são cifrados no cliente; áudio também pode ser gravado pelo microfone após ação/permissão da pessoa. Há recibo de leitura, convite de 24h por link e QR gerado localmente, push genérico e retenção de 1h. A opção de salvar aparece para quem recebe; se o mesmo arquivo já estiver no cofre, a importação é deduplicada. Ao vencer, o servidor bloqueia imediatamente novas leituras e a PWA remove a mensagem aberta quando detecta o prazo; a limpeza física do Storage roda a cada minuto. A expiração não desfaz uma captura de tela, gravação ou cópia feita antes do prazo, nem apaga uma cópia que o destinatário tenha salvo no cofre.
- **Bloqueio:** imediato por padrão, configurável para 30 segundos, 1 minuto ou 5 minutos em segundo plano. O navegador pode suspender temporizadores; o app confere o prazo ao voltar.
- **Modo Secreto:** PIN secundário (mínimo de 8 caracteres) libera uma área escondida das telas normais do Cofre, Favoritos, Lixeira e Memórias. Mídias marcadas como secretas continuam cifradas pela chave principal e entram no backup. Se esquecer o PIN secundário, use Ajustes → “Esqueci o PIN” e confirme a senha principal para revelar os itens. O PIN secundário controla a interface; não é uma chave de criptografia independente nem proteção contra inspeção do armazenamento pelo navegador já desbloqueado.
- Backup: arquivo `.voub` cifrado com chave aleatória e uma segunda senha derivada com PBKDF2. A restauração substitui o banco local depois de validar o arquivo e a senha. Teste a recuperação antes de confiar no backup como única cópia.
- **Limites inevitáveis da PWA:** ela não usa Keychain/Secure Enclave, Face ID/Touch ID como mecanismo de desbloqueio, `NSFileProtection` nem bloqueio nativo de captura de tela/App Switcher. Os bytes importados ficam cifrados no IndexedDB privado do site e não aparecem como arquivos na Galeria/Arquivos; a PWA não apaga o original da biblioteca Fotos. O código não envia o cofre ao Supabase, mas não consegue definir as regras de backup do iOS/iCloud para dados do navegador. Mesmo com pedido de persistência, apagar dados do site ou remover a PWA pode perder o cofre. A senha e os backups cifrados são essenciais.
- **O que o serviço remoto vê:** e-mails das contas, pareamento, IDs, remetente/destinatário, horários/expiração, tamanho aproximado das mídias, horário de atualização de registros compartilhados, endpoints de push e ciphertext. Ele não recebe a senha local do cofre nem o texto/foto/áudio em claro. Os arquivos do cofre e as mídias que o destinatário salva não são sincronizados entre aparelhos; somente registros de texto de Memórias/A dois e conteúdo enviado pelo chat atravessam o serviço.
- O serviço Supabase, hospedagem HTTPS e nomes de domínio/contas são configuração de implantação. Não foram criados recursos em contas externas.
- `flutter run -d windows` executa o protótipo Flutter apenas se houver toolchain C++ do Visual Studio. A PWA é o caminho para usar nos iPhones sem Mac.
