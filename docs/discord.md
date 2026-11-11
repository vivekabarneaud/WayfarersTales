# Discord — Wayfarer's Tales

How the server is set up, and the messages to paste. Invite: https://discord.gg/5bgAnccyHj

## 1. Setup (once)

1. **The invite is permanent** (never expires, no use limit): https://discord.gg/5bgAnccyHj. If it ever changes, tell Claude (it's in the addon and on the CurseForge page).
2. **Channels:**
   - `#bienvenue` (welcome): read-only, the welcome message below.
   - `#annonces` (announcements): read-only, new versions.
   - `#rapports` (reports): a **Forum** channel, one post per report.
   - `#idées` (ideas): a **Forum** channel too, so each idea has its own thread and people can react to it.
   - `#discussion`: chatting.
3. **Read-only channels** (`#bienvenue`, `#annonces`): channel settings > *Permissions* > `@everyone` > turn off *Send Messages* (and *Create Posts*).
4. **Forum tags** (channel settings > *Tags*):
   - `#rapports`: `Ligne bizarre`, `Bug`, `Erreur`, `Traité` (done).
   - `#idées`: `Nouvelle ligne`, `Fonctionnalité`, `Accepté`, `Plus tard`.
5. **A role for testers:** *Server Settings* > *Roles* > create `Testeur` (any color). Give it to people who send reports, as a thank-you.
6. **Pin** the guide messages below in each channel (hover the message > *...* > *Pin*). In a forum, use the channel's *Post Guidelines* instead.

That's all you need. No bots for now.

## 2. Messages to paste

English first, French second.

### `#bienvenue`

**Welcome to the Wayfarer's Tales Discord!**

Wayfarer's Tales adds little lines of story to your WoW adventures: the smell of an inn, the sound of the rain, the cold in your fingers, and a real bond with your hunter pet.

- 📣 **#annonces**: new versions
- 🐞 **#rapports**: a line felt wrong, or something doesn't work
- 💡 **#idées**: your ideas for lines and features
- 💬 **#discussion**: to chat

**A few simple rules**: be kind, no spoilers without a warning, no ads. Write in English or French, as you prefer.

**Bienvenue sur le Discord de Wayfarer's Tales !**

Wayfarer's Tales ajoute de petites lignes d'histoire à vos aventures dans WoW : l'odeur d'une auberge, le bruit de la pluie, le froid au bout des doigts, et un vrai lien avec votre familier de chasseur.

- 📣 **#annonces** : les nouvelles versions
- 🐞 **#rapports** : une ligne vous a semblé fausse, ou quelque chose ne marche pas
- 💡 **#idées** : vos idées de lignes et de fonctionnalités
- 💬 **#discussion** : pour papoter

**Quelques règles simples** : soyez bienveillant·e·s, pas de spoil sans prévenir, pas de pub. Écrivez en français ou en anglais, comme vous préférez.

### `#rapports` (Post Guidelines)

**How to send a report**

1. In game, type **/wt tester** (once) to switch on tester mode.
2. An odd line? Click the **!** next to it in the Journal tab, and tell us what's wrong.
3. Whenever you like, click **Send the report** (Journal tab), then Ctrl+A, Ctrl+C.
4. Create a post here and paste the report. A long report comes in numbered parts (buttons 1, 2, 3...): paste part 1 in the post, then each next part as a reply. A screenshot always helps!

**Tip:** type **/wt homework** for a small window that reminds you what's worth noting while you play (an NPC with a personality, a quest, a special place, a moonwell, a roof...), with one click to note it and a box for your own comments. All of it goes into your report.

**Comment envoyer un rapport**

1. En jeu, tapez **/wt tester** (une seule fois) pour passer en mode testeur.
2. Une ligne bizarre ? Cliquez sur le **!** à côté d'elle dans l'onglet Journal, et dites-nous ce qui ne va pas.
3. Quand vous voulez, cliquez sur **Envoyer le rapport** (onglet Journal), puis Ctrl+A, Ctrl+C.
4. Créez un post ici et collez le rapport. Un long rapport arrive en plusieurs parties numérotées (boutons 1, 2, 3...) : collez la partie 1 dans le post, puis chaque partie suivante en réponse. Une capture d'écran aide toujours !

**Astuce :** tapez **/wt devoirs** (ou /wt homework) pour une petite fenêtre qui vous rappelle ce qui vaut la peine d'être noté en jouant (un PNJ avec du caractère, une quête, un lieu particulier, un puits de lune, un toit...), avec un clic pour le noter et une case pour vos propres commentaires. Tout part dans votre rapport.

### `#idées` (Post Guidelines)

**Share an idea**

One post per idea, with a clear title. For a new line, tell us **where** (zone, place, coordinates if you can), **when** (day, night, weather) and **what your character feels** (a smell, a sound, an emotion). React with 👍 to the ideas you like!

**Proposer une idée**

Un post par idée, avec un titre clair. Pour une idée de ligne, dites-nous **où** (zone, lieu, coordonnées si possible), **quand** (jour, nuit, météo) et **ce que votre personnage ressent** (une odeur, un bruit, une émotion). Réagissez avec 👍 aux idées que vous aimez !

### `#annonces`: first announcement (on release day)

**Wayfarer's Tales 0.60.0, the first public beta, is out on CurseForge!** 🎉

[CurseForge link]

What's in this first version: (paste the English part of CHANGELOG.md)

Thanks to everyone who tested! Reports go in #rapports, ideas in #idées.

**Wayfarer's Tales 0.60.0, la première bêta publique, est disponible sur CurseForge !** 🎉

Ce que contient cette première version : (collez la partie française de CHANGELOG.md)

Merci à tous ceux qui ont testé ! Vos rapports vont dans #rapports, vos idées dans #idées.

## 3. Day to day

- **New report:** paste it to Claude in a session. Once it's handled, add the `Traité` tag to the post and a short reply ("Corrigé dans la prochaine version, merci !").
- **New idea:** tag it `Accepté` or `Plus tard`; Claude adds accepted ones to the TODO.
- **New version:** Claude writes the changelog; paste it in `#annonces`.
