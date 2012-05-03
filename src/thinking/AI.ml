(**
Implemente la logique de l'IA
**)
open BatPervasives
open Entities
open Entities.Color
open Entities.Move
open Entities.Vertex
open Board
open Globals



let genmove c =
  let b = board#get in
  let rec try_id i =
    match b#get i with
    | Corner (_, Empty, _) | Border (_, Empty, _) | Middle (_, Empty, _) -> i
    | _ -> try_id (i +1)
  in
  { color = c; vert = (vertex_of_int b#size (try_id 0)) }

let _ =
  let event_clear = Globals.event_clear#get in
  event_clear#add_handler (fun () -> Globals.board#get#clear)

let refresh_groups move = ()