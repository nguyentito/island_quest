(*
** This file has been generated, if you wish to
** modify it in a permanent way, please refer
** to the script file : gen/generator_caml.rb
*)

(*
** Taille du terrain (longueur et largeur)
*)
let taille_terrain = 32

(*
** Nombre de tours par partie
*)
let fin_partie = 200

(*
** Nombre maximum de joueurs dans la partie
*)
let max_joueurs = 2

(*
** Revenu en or par île à chaque tour
*)
let revenu_ile = 5

(*
** Revenu en or par volcan à chaque tour
*)
let revenu_volcan = 10

(*
** Or initialement possédé par chaque joueur
*)
let or_initial = 20

(*
** Coût de construction d'une Caravelle
*)
let caravelle_cout = 15

(*
** Coût de construction d'un Galion
*)
let galion_cout = 4

(*
** Déplacement de la Caravelle
*)
let caravelle_deplacement = 4

(*
** Déplacement du Galion
*)
let galion_deplacement = 6

(*
** Limite du nombre de bateaux pour chaque joueur
*)
let limite_bateaux = 500

(*
** Type de bateau
*)
type bateau_type =
| Bateau_caravelle (* <- Caravelle *)
| Bateau_galion (* <- Galion *)
| Bateau_erreur (* <- Bateau inexistant *)


(*
** Type de terrain
*)
type terrain =
| Terrain_ile (* <- Île *)
| Terrain_volcan (* <- Volcan *)
| Terrain_mer (* <- Mer *)
| Terrain_erreur (* <- Erreur, case impossible *)


(*
** Erreurs possibles
*)
type erreur =
| Ok (* <- L'action a été exécutée avec succès *)
| Or_insuffisant (* <- Vous ne possédez pas assez d'or pour cette action *)
| Ile_invalide (* <- La position spécifiée n'est pas une île *)
| Position_invalide (* <- La position spécifiée n'est pas valide *)
| Trop_loin (* <- La destination est trop éloignée *)
| Ile_colonisee (* <- L'île est déjà colonisée *)
| Ile_ennemie (* <- L'île ne vous appartient pas *)
| Bateau_ennemi (* <- Le bateau ne vous appartient pas *)
| Id_invalide (* <- L'ID spécifiée n'est pas valide *)
| Non_deplacable (* <- Le bateau n'est pas déplaçable *)
| Aucune_caravelle (* <- Il n'y a aucune caravelle susceptible de coloniser l'île *)
| Limite_atteinte (* <- La limite de bateaux est atteinte *)


(*
** Représente la position sur la carte
*)
type position = (int * int)

(*
** Représente un bateau
*)
type bateau = {
  id : int ; (* <- Identifiant unique du bateau *)
  pos : position ; (* <- Position *)
  joueur : int ; (* <- Joueur *)
  btype : bateau_type ; (* <- Type *)
  nb_or : int ; (* <- Or contenu dans le bateau *)
  deplacable : bool ; (* <- Le bateau n'a pas encore été déplacé ce tour-ci *)
}

(*
** Retourne la nature du terrain désigné par ``pos``.
*)
external info_terrain : position -> terrain = "ml_info_terrain"
(*
** Retourne le joueur qui possède l'île à l'emplacement ``pos``. Retourne -1 si l'île est libre ou si la position indiquée n'est pas une île
*)
external info_ile_joueur : position -> int = "ml_info_ile_joueur"
(*
** Retourne l'or contenu sur l'île à l'emplacement ``pos``. Retourne -1 si la case spécifiée n'est pas une île.
*)
external info_ile_or : position -> int = "ml_info_ile_or"
(*
** Retourne le bateau ayant pour identifiant ``id``
*)
external info_bateau : int -> bateau = "ml_info_bateau"
(*
** Retourne vrai si le bateau ayant pour identifiant ``id`` existe et est encore à flots
*)
external bateau_existe : int -> bool = "ml_bateau_existe"
(*
** Retourne la liste de bateaux à la position ``pos``
*)
external liste_bateaux_position : position -> bateau array = "ml_liste_bateaux_position"
(*
** Retourne la liste des ID des bateaux à la position ``pos``
*)
external liste_id_bateaux_position : position -> int array = "ml_liste_id_bateaux_position"
(*
** Retourne la liste des positions des îles de la carte
*)
external liste_iles : unit -> position array = "ml_liste_iles"
(*
** Retourne la liste des positions des îles qui vous appartiennent
*)
external mes_iles : unit -> position array = "ml_mes_iles"
(*
** Retourne l'ID du dernier bateau construit. Son comportement n'est pas défini si vous n'avez pas encore créé de bateau à ce tour-ci.
*)
external id_dernier_bateau_construit : unit -> int = "ml_id_dernier_bateau_construit"
(*
** Retourne la distance entre deux positions
*)
external distance : position -> position -> int = "ml_distance"
(*
** Construire un bateau de type ``btype`` sur l'île à la position ``pos``
*)
external construire : bateau_type -> position -> erreur = "ml_construire"
(*
** Déplace le bateau représenté par l'identifiant ``id`` jusqu'à la position `pos`` (si elle est dans la portée du bateau)
*)
external deplacer : int -> position -> erreur = "ml_deplacer"
(*
** Colonise l'île à la position ``pos``
*)
external coloniser : position -> erreur = "ml_coloniser"
(*
** Charge la caravelle identifiée par ``id`` de ``nb_or`` d'or.
*)
external charger : int -> int -> erreur = "ml_charger"
(*
** Décharge la caravelle identifiée par ``id`` de ``nb_or`` d'or.
*)
external decharger : int -> int -> erreur = "ml_decharger"
(*
** Transfère ``montant`` or de la caravelle ``id_source`` à la caravelle ``id_dest``
*)
external transferer : int -> int -> int -> erreur = "ml_transferer"
(*
** Retourne le numéro de votre joueur
*)
external mon_joueur : unit -> int = "ml_mon_joueur"
(*
** Retourne le numéro de votre adversaire
*)
external adversaire : unit -> int = "ml_adversaire"
(*
** Retourne les scores du joueur désigné par l'identifiant ``id``
*)
external score : int -> int = "ml_score"
(*
** Retourne le numéro du tour actuel
*)
external tour_actuel : unit -> int = "ml_tour_actuel"
(*
** Retourne le nombre de bateaux que possède le joueur désigné par l'identifiant ``id``
*)
external nombre_bateaux : int -> int = "ml_nombre_bateaux"
(*
** Affiche le contenu d'une valeur de type bateau_type
*)
external afficher_bateau_type : bateau_type -> unit = "ml_afficher_bateau_type"
(*
** Affiche le contenu d'une valeur de type terrain
*)
external afficher_terrain : terrain -> unit = "ml_afficher_terrain"
(*
** Affiche le contenu d'une valeur de type erreur
*)
external afficher_erreur : erreur -> unit = "ml_afficher_erreur"
(*
** Affiche le contenu d'une valeur de type position
*)
external afficher_position : position -> unit = "ml_afficher_position"
(*
** Affiche le contenu d'une valeur de type bateau
*)
external afficher_bateau : bateau -> unit = "ml_afficher_bateau"
