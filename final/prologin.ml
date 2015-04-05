(******* README ********

  Tout le code de l'IA (à part l'API) tient dans ce fichier.

  Structure du code :
  - fonctions utilitaires simples
  - variables globales et fonctions auxiliaires pour le code
  - dans partie_init et partie_fin il n'y a quasiment rien
    (juste le seed du random gen)
  - la majeure partie du code se trouve dans jouer_tour
    en effet à chaque tour on recalcule un certain nombre de trucs
    qui sont utiles pour toutes les phases, et on veut les partager
    les fonctions imbriquées capable de faire référence aux variables de
    leur environnement permettent de minimiser le spaghetti code
  
  Phases d'un tour :
  1. initialisation et création du scout : seulement au tour 1
  2. attaques sur des cibles
  3. positionnement
  4. recrutement de galions
  5. colonisations d'îles libres

  Vous aurez remarqué qu'il y a une seule caravelle qui sert à coloniser.
  De plus on ne la respawne pas quand elle meurt. C'est une ouverture
  simple qui n'est pas trop désavantageuse (on peut créer un galion au 1er
  tour). L'éclaireur évite les zones ennemies en utilisant du pathfinding.

  Recrutement : très simple, on convertit autant que possible l'or en gallions.

  Déroulement des phases 2 et 3 :
  d'abord on calcule les zones "critiques" définies comme zones attaquables
  par les galions ennemis + cases des cibles (iles et caravelles)
  les troupes à l'arrière s'approchent de la zone critique
  la zone critique sert à évaluer les positions
  cf. code pour plus de détails

*)



(*
** This file has been generated, if you wish to
** modify it in a permanent way, please refer
** to the script file : gen/generator_caml.rb
*)

open Api

module A = Array
module H = Hashtbl
module L = List


(* utilitaires *)

let nonzero_int_sign n = n / abs n

let flush_outputs () =
  flush stderr; flush stdout (* Pour que vos sorties s'affichent *)

let foldl = L.fold_left
let foldr = L.fold_right
let foldl1 f (x::xs) = foldl f x xs

let rec take n l = match (n,l) with
  | 0, _ -> []
  | n, x::xs -> x :: take (n-1) xs
  | _, [] -> []

let rec last = function
  | [x] -> x
  | x::x'::xs -> last (x'::xs)
  | [] -> assert false

let nonempty_list_to_array ((x::_) as l) =
  let t = A.make (L.length l) x in
  let rec loop i = function
    | [] -> ()
    | y::ys -> t.(i) <- y; loop (i+1) ys in
  loop 0 l;
  t

let in_place_shuffle t =
  let n = A.length t in
  let swap j k = let tmp = t.(j) in
                 t.(j) <- t.(k); t.(k) <- tmp in
  for i = 0 to n-1 do
    swap i (i + Random.int (n-i))
  done;
  t

let shuffle_list l =
  if l = [] then [] else
    A.to_list (in_place_shuffle (nonempty_list_to_array l))

let error_message = function
  | Ok -> "L'action a été exécutée avec succès"
  | Or_insuffisant -> "Vous ne possédez pas assez d'or pour cette action"
  | Ile_invalide -> "La position spécifiée n'est pas une île"
  | Position_invalide -> "La position spécifiée n'est pas valide"
  | Trop_loin -> "La destination est trop éloignée"
  | Ile_colonisee -> "L'île est déjà colonisée"
  | Ile_ennemie -> "L'île ne vous appartient pas"
  | Bateau_ennemi -> "Le bateau ne vous appartient pas"
  | Id_invalide -> "L'ID spécifiée n'est pas valide"
  | Non_deplacable -> "Le bateau n'est pas déplaçable"
  | Aucune_caravelle -> "Il n'y a aucune caravelle susceptible de coloniser l'île"
  | Limite_atteinte -> "La limite de bateaux est atteinte"

let log_error label err =
  if err <> Ok then (
    print_string (label ^ ": ");
    print_endline (error_message err)
  )

exception Free_island_found of int * int


(* globales et fcts auxiliaires simples *)

let ile_depart = ref (0,0)
let scout = ref (-1)
let mon_id = ref 0 and adversaire_id = ref 0


let portee = function
  | Bateau_caravelle -> caravelle_deplacement
  | Bateau_galion -> galion_deplacement
  | Bateau_erreur -> assert false

let for_pos_in_terrain f = 
  for x = 0 to taille_terrain - 1 do
    for y = 0 to taille_terrain - 1 do
      f x y
    done
  done

let norm_1_ball (x,y) =
  let r = portee Bateau_galion and l = ref [] in
  for i = max (x-r) 0 to min (x+r) (taille_terrain-1) do
    for j = max (y-r) 0 to min (y+r) (taille_terrain-1) do
      if distance (x,y) (i,j) <= r
      then l := (i,j) :: !l
    done
  done;
  shuffle_list !l

let for_pos_in_range center f =
  L.iter (fun (i,j) -> f i j) (norm_1_ball center)

let force_frappe player (x,y) =
  let acc = ref [] in
  for_pos_in_range (x,y) (fun i j ->
    let is_threat ship = ship.joueur = player
                       && ship.btype = Bateau_galion
                         && ( (i,j) = (x,y) || ship.deplacable ) in
    acc := L.filter is_threat
                    (A.to_list (liste_bateaux_position (i,j)))
           @ !acc
  );
  !acc



(*
** Fonction appelée au début de la partie
*)
let partie_init () =

  Random.self_init ();

  flush_outputs ()


(*
** Fonction appelée à chaque tour
*)
let jouer_tour () = 
  
  (*** ouverture à 5 galions (low rush distance) ou 1 caravelle (normal) ***)

  if tour_actuel () = 1 then (

    (* initialisation *)
    ile_depart := (mes_iles ()).(0);
    mon_id := mon_joueur ();
    adversaire_id := adversaire ();

    let ile_adversaire =
      L.hd (L.filter (fun ile -> info_ile_joueur ile = !adversaire_id)
                     (A.to_list (liste_iles ()))) in
    if distance !ile_depart ile_adversaire > 10
    then ( let err = construire Bateau_caravelle !ile_depart in
           log_error "scout initial" err;
           scout := id_dernier_bateau_construit () )
  );

  (*** attaques/déplacements ***)

  (* enemy presence on the map *)
  let enemy_galleons = A.make_matrix taille_terrain taille_terrain 0
  and enemy_caravelles = A.make_matrix taille_terrain taille_terrain 0 in
  for_pos_in_terrain (fun i j ->
      A.iter (fun b -> match b.btype with
               | Bateau_galion ->
                   enemy_galleons.(i).(j) <- enemy_galleons.(i).(j)
                                + (if b.joueur = !adversaire_id then 1 else 0)
               | Bateau_caravelle ->
                   enemy_caravelles.(i).(j) <- enemy_caravelles.(i).(j)
                                + (if b.joueur = !adversaire_id then 1 else 0)
               | Bateau_erreur -> assert false )
             (liste_bateaux_position (i,j))
  );


  let num_force_frappe_adv (x,y) =
    let acc = ref 0 in
    for_pos_in_range (x,y) (fun i j ->
      acc := !acc + enemy_galleons.(i).(j)
    );
    !acc
  in

  let force_frappe_moi (x,y) = 
    let mobilisable_from (i,j) =
      let is_friendly_galleon ship =
        ship.joueur = !mon_id && ship.btype = Bateau_galion in
      let friendly_galleons =
        L.filter is_friendly_galleon
                 (A.to_list (liste_bateaux_position (i,j))) in
      let movable b = b.deplacable
      in
      match info_terrain (i,j) with
      | (Terrain_ile | Terrain_volcan) when (i,j) <> (x,y) ->
        (* keep enough forces to defend *)
        let l = L.filter movable friendly_galleons in
        let nl = L.length l in
        let immobile = L.length friendly_galleons - nl  in
        let grounded_forces = max 0 (num_force_frappe_adv (i,j) - immobile) in
        take (nl - grounded_forces) l
      | _ when (i,j) = (x,y) -> friendly_galleons
      | _ -> L.filter movable friendly_galleons
    in
    let acc = ref [] in
    for_pos_in_range (x,y) (fun i j ->
      acc := mobilisable_from (i,j) @ !acc
    );
    !acc
  in

  (* offensive movement function *)

  let move_all fleet pos =
    L.iter (fun b -> log_error "move_all" (deplacer b.id pos)) fleet
  in

  let attaque_totale fleet ((x,y) as ile) =
    move_all fleet ile;
    (* remember the forces have gone down for future moves *)
    enemy_caravelles.(x).(y) <- 0;
    enemy_galleons.(x).(y) <- 0 (* même s'il y a pas d'ennemi là
                                   c'est pas grave *)
  in
  

  (* capturer îles ennemies proches *)

  let maybe_capture_position pos =
    let force = force_frappe_moi pos in
    if L.length force > num_force_frappe_adv pos
    then attaque_totale force pos
  in

  A.iter (fun ile -> if info_ile_joueur ile = !adversaire_id
                         then maybe_capture_position ile)
             (liste_iles ());

  (* attaquer bateaux ennemis
     ne pas attaquer les caravelles trop bien protégées
  *)

  for_pos_in_terrain (fun i j ->
    if max enemy_galleons.(i).(j) enemy_caravelles.(i).(j) > 0
    then maybe_capture_position (i,j)
  );

  (** positionnement **)

  (* critical tiles = those reachable by the enemy
                      + important objectives *)
  let critical = A.make_matrix taille_terrain taille_terrain false in
   for_pos_in_terrain (fun x y ->
     (try for_pos_in_range (x,y) (fun i j ->
       if enemy_galleons.(i).(j) > 0 then raise Not_found)
      with Not_found -> critical.(x).(y) <- true);
     (* make the AI aware of isolated caravelles/islands
        as important targets *)
     if enemy_caravelles.(x).(y) > 0 then critical.(x).(y) <- true;
     if (info_terrain (x,y) = Terrain_ile ||
         info_terrain (x,y) = Terrain_volcan)
       && info_ile_joueur (x,y) = !adversaire_id
     then critical.(x).(y) <- true
   );
  
  (* calculate distances to the critical area using a BFS *)
  let dist_to_critical = A.make_matrix taille_terrain taille_terrain (-1) in
  (let bfs_queue = Queue.create () in
   for_pos_in_terrain (fun x y -> if critical.(x).(y) then (
                                    dist_to_critical.(x).(y) <- 0;
                                    Queue.push (x,y) bfs_queue )
   );
   let process_node (x,y) =
     let d = dist_to_critical.(x).(y) in
     L.iter (fun (i,j) -> if min i j >= 0 && max i j <= taille_terrain - 1
                                && dist_to_critical.(i).(j) = -1
                             then ( dist_to_critical.(i).(j) <- d+1;
                                    Queue.push (i,j) bfs_queue ) )
               [(x+1,y);(x-1,y);(x,y+1);(x,y-1)]
   in
   while not (Queue.is_empty bfs_queue) do
     process_node (Queue.pop bfs_queue)
   done
  );

  (* tile value = critical tiles in range *)
  let tile_value = A.make_matrix taille_terrain taille_terrain 0 in
  let tile_value_list = ref [] in
  for_pos_in_terrain (fun x y ->
    for_pos_in_range (x,y) (fun i j ->
      tile_value.(x).(y) <- tile_value.(x).(y)
                          + (if critical.(i).(j) then 1 else 0)
    );
    tile_value_list := (tile_value.(x).(y), (x,y)) :: !tile_value_list
  );
  
  (* tactical movements close to the enemy *)
  let tactical_positions =
    let compare_decreasing a b = compare b a in
    let sorted_by_value = L.map snd (L.sort compare_decreasing
                                            !tile_value_list) in
    let is_interesting_position (i,j) =
      (force_frappe_moi (i,j) <> []) && critical.(i).(j) in
(*    let compare_force_frappe a b =
      compare (force_frappe_moi a) (force_frappe_moi b) in *)
    (shuffle_list
       (take 12
          (L.filter is_interesting_position
             sorted_by_value)))
  in
  L.iter maybe_capture_position tactical_positions;

  (* guiding the incoming stream of backup units *)
  for_pos_in_terrain (fun x y ->
    if not critical.(x).(y) then (
      let ships = liste_bateaux_position (x,y) in
      let my_galleons = L.filter (fun b -> b.deplacable
                                           && b.joueur = !mon_id
                                           && b.btype = Bateau_galion)
                                    (A.to_list ships) in
      if my_galleons <> [] then
        let target =
          let min_by_dist (k,l) (i,j) =
            if dist_to_critical.(i).(j) < dist_to_critical.(k).(l)
            then (i,j) else (k,l) in
          foldl1 min_by_dist
                 (shuffle_list (L.filter (fun (i,j) -> not critical.(i).(j))
                                            (norm_1_ball (x,y)))) in
        (* Printf.printf "goto %d %d\n" (fst target) (snd target); *)
        move_all my_galleons target
    ));


  (*** amasser armée ***)
  let rec recruit_galleons ile =
    if info_ile_or ile >= galion_cout && info_terrain ile = Terrain_ile then (
      match construire Bateau_galion ile with
      | Limite_atteinte -> ()
      | err -> ( log_error "4" err; recruit_galleons ile )
    )
  in
  A.iter recruit_galleons (mes_iles ());

  (*** colonisation ***)
  (* priorité aux îles non volcaniques *)
  (* arrive à la fin pour profiter du cleanup des forces ennemies *)

  if bateau_existe !scout then (

  let scout_pos = (info_bateau !scout).pos in

  let scout_target =
    
    let bfs_queue = Queue.create () in
    let predecessor = A.make_matrix taille_terrain taille_terrain None in
    let (x_s,y_s) = scout_pos in
    Queue.push scout_pos bfs_queue;
    
    let process_node (x,y) =
      A.iter (fun (i,j) -> if min i j >= 0 && max i j <= taille_terrain - 1
                              && predecessor.(i).(j) = None
                              && dist_to_critical.(i).(j) >= 1
                           then (
                             predecessor.(i).(j) <- Some (x,y);
                             if (info_terrain (i,j) = Terrain_ile ||
                                 info_terrain (i,j) = Terrain_volcan)
                                && info_ile_joueur (i,j) = -1
                             then raise (Free_island_found (i,j))
                             else Queue.push (i,j) bfs_queue
                           ))
            [|(x+1,y);(x-1,y);(x,y+1);(x,y-1)|]
    in
    try
      while not (Queue.is_empty bfs_queue) do
        process_node (Queue.pop bfs_queue)
      done;
      None
    with Free_island_found (x_ile, y_ile) -> (
      let path = ref [] and i = ref x_ile and j = ref y_ile in
      while (!i,!j) <> (x_s,y_s) do
        path := (!i,!j) :: !path;
        let Some (k,l) = predecessor.(!i).(!j) in
        i := k; j := l
      done;
      path := (x_s,y_s) :: !path;
      Some (last (take 5 !path))
    )
      
  in

  match scout_target with
  | None -> ()
  | Some target -> ( log_error "scout_move" (deplacer !scout target);
                     if (info_terrain target = Terrain_ile ||
                         info_terrain target = Terrain_volcan)
                       && info_ile_joueur target = -1
                     then log_error "colonisation" (coloniser target) )
  );
  
  flush_outputs ()


(*
** Fonction appelée à la fin de la partie
*)
let partie_fin () =

  flush_outputs ()



(****************************************************)

;;

(* /!\ Ne touche pas a ce qui suit /!\ *)
Callback.register "ml_partie_init" partie_init;;
Callback.register "ml_jouer_tour" jouer_tour;;
Callback.register "ml_partie_fin" partie_fin;;
