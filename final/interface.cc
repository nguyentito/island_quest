///
// This file has been generated, if you wish to
// modify it in a permanent way, please refer
// to the script file : gen/generator_caml.rb
//

extern "C" {
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <caml/memory.h>
}
#include "interface.hh"

template <typename Lang, typename Cxx>
Lang cxx2lang(Cxx in)
{
  return in.__if_that_triggers_an_error_there_is_a_problem;
}

template <>
value cxx2lang<value, int>(int in)
{
  CAMLparam0();
  CAMLreturn(Val_int(in));
}

template<>
value cxx2lang<value, std::string>(std::string in)
{
  CAMLparam0();
  size_t l = in.length();
  char * out = (char *) malloc(l + 1);
  for (int i = 0; i < l; i++) out[i] = in[i];
  out[l] = 0;
  CAMLreturn(caml_copy_string(out));
}

template <>
value cxx2lang<value, bool>(bool in)
{
  CAMLparam0();
  CAMLreturn(Val_int(in));
}

template <typename Cxx>
value cxx2lang_array(const std::vector<Cxx>& in)
{
  CAMLparam0();
  CAMLlocal1(v);

  size_t size = in.size();
  if (size == 0)
    CAMLreturn(Atom(0));

  v = caml_alloc(size, 0);
  for (int i = 0; i < size; ++i)
    caml_initialize(&Field(v, i), cxx2lang<value, Cxx>(in[i]));

  CAMLreturn(v);
}

template <typename Lang, typename Cxx>
Cxx lang2cxx(Lang in)
{
  return in.__if_that_triggers_an_error_there_is_a_problem;
}

template<>
std::string lang2cxx<value, std::string>(value in)
{
  CAMLparam1(in);
  CAMLreturnT(std::string, String_val(in));
}

template <>
int lang2cxx<value, int>(value in)
{
  CAMLparam1(in);
  CAMLreturnT(int, Int_val(in));
}

template <>
bool lang2cxx<value, bool>(value in)
{
  CAMLparam1(in);
  CAMLreturnT(bool, Int_val(in));
}

template <typename Cxx>
std::vector<Cxx> lang2cxx_array(value in)
{
  CAMLparam1(in);
  std::vector<Cxx> out;
  mlsize_t size = Wosize_val(in);

  for (int i = 0; i < size; ++i)
    out.push_back(lang2cxx<value, Cxx>(Field(in, i)));

  CAMLreturnT(std::vector<Cxx>, out);
}
///
// Type de bateau
//
template <>
value cxx2lang<value, bateau_type>(bateau_type in)
{
  CAMLparam0();
  CAMLreturn(Val_int(in));
}

template <>
bateau_type lang2cxx<value, bateau_type>(value in)
{
  CAMLparam1(in);
  CAMLreturnT(bateau_type, (bateau_type)Int_val(in));
}

///
// Type de terrain
//
template <>
value cxx2lang<value, terrain>(terrain in)
{
  CAMLparam0();
  CAMLreturn(Val_int(in));
}

template <>
terrain lang2cxx<value, terrain>(value in)
{
  CAMLparam1(in);
  CAMLreturnT(terrain, (terrain)Int_val(in));
}

///
// Erreurs possibles
//
template <>
value cxx2lang<value, erreur>(erreur in)
{
  CAMLparam0();
  CAMLreturn(Val_int(in));
}

template <>
erreur lang2cxx<value, erreur>(value in)
{
  CAMLparam1(in);
  CAMLreturnT(erreur, (erreur)Int_val(in));
}

///
// Représente la position sur la carte
//
template <>
value cxx2lang<value, position>(position in)
{
  CAMLparam0();
  CAMLlocal1(out);
  out = caml_alloc(2, 0);
  caml_initialize(&Field(out, 0), cxx2lang<value, int>(in.x));
  caml_initialize(&Field(out, 1), cxx2lang<value, int>(in.y));
  CAMLreturn(out);
}

template <>
position lang2cxx<value, position>(value in)
{
  CAMLparam1(in);
  position out;
  out.x = lang2cxx<value, int>(Field(in, 0));
  out.y = lang2cxx<value, int>(Field(in, 1));
  CAMLreturnT(position, out);
}

///
// Représente un bateau
//
template <>
value cxx2lang<value, bateau>(bateau in)
{
  CAMLparam0();
  CAMLlocal1(out);
  out = caml_alloc(6, 0);
  caml_initialize(&Field(out, 0), cxx2lang<value, int>(in.id));
  caml_initialize(&Field(out, 1), cxx2lang<value, position>(in.pos));
  caml_initialize(&Field(out, 2), cxx2lang<value, int>(in.joueur));
  caml_initialize(&Field(out, 3), cxx2lang<value, bateau_type>(in.btype));
  caml_initialize(&Field(out, 4), cxx2lang<value, int>(in.nb_or));
  caml_initialize(&Field(out, 5), cxx2lang<value, bool>(in.deplacable));
  CAMLreturn(out);
}

template <>
bateau lang2cxx<value, bateau>(value in)
{
  CAMLparam1(in);
  bateau out;
  out.id = lang2cxx<value, int>(Field(in, 0));
  out.pos = lang2cxx<value, position>(Field(in, 1));
  out.joueur = lang2cxx<value, int>(Field(in, 2));
  out.btype = lang2cxx<value, bateau_type>(Field(in, 3));
  out.nb_or = lang2cxx<value, int>(Field(in, 4));
  out.deplacable = lang2cxx<value, bool>(Field(in, 5));
  CAMLreturnT(bateau, out);
}

/*
** Inititialize caml
*/
static inline void _init_caml()
{
    static bool is_initialized = false;

    if (!is_initialized)
    {
        is_initialized = true;

        const char* argv[2] = {"./caml", NULL};
        caml_startup(const_cast<char**>(argv));
    }
}

///
// Retourne la nature du terrain désigné par ``pos``.
//
extern "C" value ml_info_terrain(value pos)
{
  CAMLparam0();
  CAMLxparam1(pos);
  CAMLreturn((cxx2lang<value, terrain>(api_info_terrain(lang2cxx<value, position>(pos)))));
}

///
// Retourne le joueur qui possède l'île à l'emplacement ``pos``. Retourne -1 si l'île est libre ou si la position indiquée n'est pas une île
//
extern "C" value ml_info_ile_joueur(value pos)
{
  CAMLparam0();
  CAMLxparam1(pos);
  CAMLreturn((cxx2lang<value, int>(api_info_ile_joueur(lang2cxx<value, position>(pos)))));
}

///
// Retourne l'or contenu sur l'île à l'emplacement ``pos``. Retourne -1 si la case spécifiée n'est pas une île.
//
extern "C" value ml_info_ile_or(value pos)
{
  CAMLparam0();
  CAMLxparam1(pos);
  CAMLreturn((cxx2lang<value, int>(api_info_ile_or(lang2cxx<value, position>(pos)))));
}

///
// Retourne le bateau ayant pour identifiant ``id``
//
extern "C" value ml_info_bateau(value id)
{
  CAMLparam0();
  CAMLxparam1(id);
  CAMLreturn((cxx2lang<value, bateau>(api_info_bateau(lang2cxx<value, int>(id)))));
}

///
// Retourne vrai si le bateau ayant pour identifiant ``id`` existe et est encore à flots
//
extern "C" value ml_bateau_existe(value id)
{
  CAMLparam0();
  CAMLxparam1(id);
  CAMLreturn((cxx2lang<value, bool>(api_bateau_existe(lang2cxx<value, int>(id)))));
}

///
// Retourne la liste de bateaux à la position ``pos``
//
extern "C" value ml_liste_bateaux_position(value pos)
{
  CAMLparam0();
  CAMLxparam1(pos);
  CAMLreturn((cxx2lang_array<bateau>(api_liste_bateaux_position(lang2cxx<value, position>(pos)))));
}

///
// Retourne la liste des ID des bateaux à la position ``pos``
//
extern "C" value ml_liste_id_bateaux_position(value pos)
{
  CAMLparam0();
  CAMLxparam1(pos);
  CAMLreturn((cxx2lang_array<int>(api_liste_id_bateaux_position(lang2cxx<value, position>(pos)))));
}

///
// Retourne la liste des positions des îles de la carte
//
extern "C" value ml_liste_iles(value unit)
{
  CAMLparam0();
  CAMLxparam1(unit);
  CAMLreturn((cxx2lang_array<position>(api_liste_iles())));
}

///
// Retourne la liste des positions des îles qui vous appartiennent
//
extern "C" value ml_mes_iles(value unit)
{
  CAMLparam0();
  CAMLxparam1(unit);
  CAMLreturn((cxx2lang_array<position>(api_mes_iles())));
}

///
// Retourne l'ID du dernier bateau construit. Son comportement n'est pas défini si vous n'avez pas encore créé de bateau à ce tour-ci.
//
extern "C" value ml_id_dernier_bateau_construit(value unit)
{
  CAMLparam0();
  CAMLxparam1(unit);
  CAMLreturn((cxx2lang<value, int>(api_id_dernier_bateau_construit())));
}

///
// Retourne la distance entre deux positions
//
extern "C" value ml_distance(value depart, value arrivee)
{
  CAMLparam0();
  CAMLxparam2(depart, arrivee);
  CAMLreturn((cxx2lang<value, int>(api_distance(lang2cxx<value, position>(depart), lang2cxx<value, position>(arrivee)))));
}

///
// Construire un bateau de type ``btype`` sur l'île à la position ``pos``
//
extern "C" value ml_construire(value btype, value pos)
{
  CAMLparam0();
  CAMLxparam2(btype, pos);
  CAMLreturn((cxx2lang<value, erreur>(api_construire(lang2cxx<value, bateau_type>(btype), lang2cxx<value, position>(pos)))));
}

///
// Déplace le bateau représenté par l'identifiant ``id`` jusqu'à la position `pos`` (si elle est dans la portée du bateau)
//
extern "C" value ml_deplacer(value id, value pos)
{
  CAMLparam0();
  CAMLxparam2(id, pos);
  CAMLreturn((cxx2lang<value, erreur>(api_deplacer(lang2cxx<value, int>(id), lang2cxx<value, position>(pos)))));
}

///
// Colonise l'île à la position ``pos``
//
extern "C" value ml_coloniser(value pos)
{
  CAMLparam0();
  CAMLxparam1(pos);
  CAMLreturn((cxx2lang<value, erreur>(api_coloniser(lang2cxx<value, position>(pos)))));
}

///
// Charge la caravelle identifiée par ``id`` de ``nb_or`` d'or.
//
extern "C" value ml_charger(value id, value nb_or)
{
  CAMLparam0();
  CAMLxparam2(id, nb_or);
  CAMLreturn((cxx2lang<value, erreur>(api_charger(lang2cxx<value, int>(id), lang2cxx<value, int>(nb_or)))));
}

///
// Décharge la caravelle identifiée par ``id`` de ``nb_or`` d'or.
//
extern "C" value ml_decharger(value id, value nb_or)
{
  CAMLparam0();
  CAMLxparam2(id, nb_or);
  CAMLreturn((cxx2lang<value, erreur>(api_decharger(lang2cxx<value, int>(id), lang2cxx<value, int>(nb_or)))));
}

///
// Transfère ``montant`` or de la caravelle ``id_source`` à la caravelle ``id_dest``
//
extern "C" value ml_transferer(value montant, value id_source, value id_dest)
{
  CAMLparam0();
  CAMLxparam3(montant, id_source, id_dest);
  CAMLreturn((cxx2lang<value, erreur>(api_transferer(lang2cxx<value, int>(montant), lang2cxx<value, int>(id_source), lang2cxx<value, int>(id_dest)))));
}

///
// Retourne le numéro de votre joueur
//
extern "C" value ml_mon_joueur(value unit)
{
  CAMLparam0();
  CAMLxparam1(unit);
  CAMLreturn((cxx2lang<value, int>(api_mon_joueur())));
}

///
// Retourne le numéro de votre adversaire
//
extern "C" value ml_adversaire(value unit)
{
  CAMLparam0();
  CAMLxparam1(unit);
  CAMLreturn((cxx2lang<value, int>(api_adversaire())));
}

///
// Retourne les scores du joueur désigné par l'identifiant ``id``
//
extern "C" value ml_score(value id_joueur)
{
  CAMLparam0();
  CAMLxparam1(id_joueur);
  CAMLreturn((cxx2lang<value, int>(api_score(lang2cxx<value, int>(id_joueur)))));
}

///
// Retourne le numéro du tour actuel
//
extern "C" value ml_tour_actuel(value unit)
{
  CAMLparam0();
  CAMLxparam1(unit);
  CAMLreturn((cxx2lang<value, int>(api_tour_actuel())));
}

///
// Retourne le nombre de bateaux que possède le joueur désigné par l'identifiant ``id``
//
extern "C" value ml_nombre_bateaux(value id_joueur)
{
  CAMLparam0();
  CAMLxparam1(id_joueur);
  CAMLreturn((cxx2lang<value, int>(api_nombre_bateaux(lang2cxx<value, int>(id_joueur)))));
}

///
// Affiche le contenu d'une valeur de type bateau_type
//
extern "C" value ml_afficher_bateau_type(value v)
{
  CAMLparam0();
  CAMLxparam1(v);
  api_afficher_bateau_type(lang2cxx<value, bateau_type>(v));
  CAMLreturn(Val_unit);
}

///
// Affiche le contenu d'une valeur de type terrain
//
extern "C" value ml_afficher_terrain(value v)
{
  CAMLparam0();
  CAMLxparam1(v);
  api_afficher_terrain(lang2cxx<value, terrain>(v));
  CAMLreturn(Val_unit);
}

///
// Affiche le contenu d'une valeur de type erreur
//
extern "C" value ml_afficher_erreur(value v)
{
  CAMLparam0();
  CAMLxparam1(v);
  api_afficher_erreur(lang2cxx<value, erreur>(v));
  CAMLreturn(Val_unit);
}

///
// Affiche le contenu d'une valeur de type position
//
extern "C" value ml_afficher_position(value v)
{
  CAMLparam0();
  CAMLxparam1(v);
  api_afficher_position(lang2cxx<value, position>(v));
  CAMLreturn(Val_unit);
}

///
// Affiche le contenu d'une valeur de type bateau
//
extern "C" value ml_afficher_bateau(value v)
{
  CAMLparam0();
  CAMLxparam1(v);
  api_afficher_bateau(lang2cxx<value, bateau>(v));
  CAMLreturn(Val_unit);
}

///
// Fonction appelée au début de la partie
//
void partie_init()
{
  _init_caml();
  CAMLparam0();
  CAMLlocal1(_ret);
  static value *closure = NULL;
  if (closure == NULL)
    closure = caml_named_value("ml_partie_init");
  _ret = callback(*closure, Val_unit);
  CAMLreturn0;
}


///
// Fonction appelée à chaque tour
//
void jouer_tour()
{
  _init_caml();
  CAMLparam0();
  CAMLlocal1(_ret);
  static value *closure = NULL;
  if (closure == NULL)
    closure = caml_named_value("ml_jouer_tour");
  _ret = callback(*closure, Val_unit);
  CAMLreturn0;
}


///
// Fonction appelée à la fin de la partie
//
void partie_fin()
{
  _init_caml();
  CAMLparam0();
  CAMLlocal1(_ret);
  static value *closure = NULL;
  if (closure == NULL)
    closure = caml_named_value("ml_partie_fin");
  _ret = callback(*closure, Val_unit);
  CAMLreturn0;
}


