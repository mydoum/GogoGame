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

(* SETUP *)
let _ =
  Timer.set_timer 7.5; (* set le timeout a 9.5 secondes *)
  let _ = Thread.sigmask Unix.SIG_BLOCK [Sys.sigalrm] in ()

let refresh_groups move =
  let { color = c; vert = v } = move in
  let { pass = p ; nb = _ ; letter = _ } = v in
  if p then ()
  else
    Group_again.make_group c board#get#blacks board#get#whites
      (int_of_v v)

let rec genmove c =
  if !Fuseki.fuseki
  then (* premier coup, on joue D4 *)
  try
    Fuseki.genmove c
  with Fuseki.Not_Fuseki -> (Fuseki.fuseki := false; genmove c)
  else
    (let _ = Timer.run () in
      let b = board#get in
      let ch = Event.new_channel () in
      let writer_end () = Event.poll (Event.send ch ())
      and reader_end () = Event.poll (Event.receive ch) in
      let _ =
        Thread.create (UCT.uctSearch
              ~nbSim:50
              ~color: c
              ~last_move: (Globals.last_played#get)
              ~blacks: b#blacks
              ~whites: b#whites
              ~channel: (reader_end)) ()
      in
      let _ = Thread.wait_signal [Sys.sigalrm] in
      let _ = writer_end () in
      Best.get_move b c)

(* let genmove c = let b = board#get in let rec try_id i = match b#get i   *)
(* with | Corner (_, Empty, _) | Border (_, Empty, _) | Middle (_, Empty,  *)
(* _) -> i | _ -> try_id (i +1) in { color = c; vert = (vertex_of_int      *)
(* b#size (try_id 0)) }                                                    *)

let _ =
  let event_clear = Globals.event_clear#get in
  event_clear#add_handler (fun () -> Globals.board#get#clear)
