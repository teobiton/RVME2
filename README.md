# RVME2

Refonte du module ME2.
Ce répertoire traite de l'adaptation du modèle de processeur initial en un nouveau modèle de processeur simple suivant l'architecture RISC-V.

## Organisation

Le modèle en développement `src/riscvproc.v` est le modèle simulable qui sera donné initialement.
Lorsque ce premier modèle sera validé, un deuxième modèle "final", avec entrées/sorties et interfacé avec les mémoires RAMs décrites en VHDL sera développé et testé.
Une ébauche de ce fichier est définie `src/riscvproc_final.v`

Les tests seront décrits dans le dossier `test`.
L'environnement de test utilise Cocotb et Verilator.
Pour plus d'information, voir `test/README.md`.

Dans le répertoire `doc`, les documents initiaux du module ME2 et les anciens modèles de processeur.
