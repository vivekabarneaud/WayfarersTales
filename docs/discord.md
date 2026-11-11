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

### `#bienvenue`

**Bienvenue sur le Discord de Wayfarer's Tales !** / **Welcome!**

Wayfarer's Tales ajoute de petites lignes d'histoire à vos aventures dans WoW : le monde décrit autour de vous, un corps qui ressent le froid et la pluie, et un vrai lien avec votre familier de chasseur.

- 📣 **#annonces** : les nouvelles versions
- 🐞 **#rapports** : une ligne vous a semblé fausse, ou quelque chose ne marche pas
- 💡 **#idées** : vos idées de lignes et de fonctionnalités
- 💬 **#discussion** : pour papoter

**Quelques règles simples** : soyez bienveillant·e·s, pas de spoil sans prévenir, pas de pub.

*Wayfarer's Tales adds little lines of story to your WoW adventures. English speakers are very welcome too: write in English or French, as you prefer.*

### `#rapports` (Post Guidelines)

**Comment envoyer un rapport** / **How to send a report**

1. En jeu, tapez **/wt tester** (une seule fois) pour passer en mode testeur.
2. Une ligne bizarre ? Cliquez sur le **!** à côté d'elle dans l'onglet Journal, et dites-nous ce qui ne va pas.
3. Quand vous voulez, cliquez sur **Envoyer le rapport** (onglet Journal), puis Ctrl+A, Ctrl+C.
4. Créez un post ici et collez le rapport. Une capture d'écran aide toujours !

*In game, type /wt tester once. Flag odd lines with the ! button in the Journal tab, then click "Send the report", copy it all and paste it in a new post here.*

### `#idées` (Post Guidelines)

**Proposer une idée** / **Share an idea**

Un post par idée, avec un titre clair. Pour une idée de ligne : dites-nous **où** (zone, lieu, coordonnées si possible), **quand** (jour, nuit, météo) et **ce que votre personnage ressent** (une odeur, un bruit, une émotion). Réagissez avec 👍 aux idées que vous aimez !

*One post per idea. For a new line: where, when, and what your character feels. React with 👍 to the ideas you like!*

### `#annonces`: first announcement (on release day)

**Wayfarer's Tales 0.60.0, la première bêta publique, est disponible sur CurseForge !** 🎉

[CurseForge link]

Ce que contient cette première version : (paste the French part of CHANGELOG.md)

Merci à tous ceux qui ont testé ! Vos rapports vont dans #rapports, vos idées dans #idées.

*Wayfarer's Tales 0.60.0, the first public beta, is out on CurseForge! (paste the English part of CHANGELOG.md)*

## 3. Day to day

- **New report:** paste it to Claude in a session. Once it's handled, add the `Traité` tag to the post and a short reply ("Corrigé dans la prochaine version, merci !").
- **New idea:** tag it `Accepté` or `Plus tard`; Claude adds accepted ones to the TODO.
- **New version:** Claude writes the changelog; paste it in `#annonces`.
