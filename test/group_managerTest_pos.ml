(**TA TA TAAAAAM le test des groupes
**)
open OUnit

open Printf

open Entities

open Entities.Move

open Entities.Vertex

open Entities.Color

open Group_again

open Board

open Globals

open Group

open BatPervasives

open Group_again.Groups

let test_count ~expected =
  let count = !Group_again.Groups.count_groups
  in
  assert_bool
    (sprintf
        "nombre de groupes detectes incorrect (count a %d, attendu %d)"
        count expected)
    (count = expected)

let test_liberty ~expected ~vertices =
  let head = int_of_v ( List.hd vertices) in
  let count = get_group_lib head
  in
  assert_bool
    (sprintf "nombre de libertes detectees incorrectes (count a %d, attendu %d)"
        count expected) (count = expected)

let test_monoids ~vertices =
  let vertices = List.map (int_of_vertex 13) vertices
  in
  assert_bool "groupes mal detecte (pierres non trouvable dans la liste)"
    (List.for_all (fun m -> (group_of_stone m) <> dummy_group) vertices)

let are_in_same_group ~color ~vertices =
  let head = List.hd vertices in
  let g = Group_again.Groups.get_group_id (int_of_v head)
  in
  List.iter
    (fun m ->
          let s = int_of_v m in
          let find = Group_again.Groups.get_group_id s
          in
          (assert_bool
              (Printf.sprintf "{%s} est dans le groupe zero"
                  (string_of_vertex m))
              (find <> 0);
            assert_bool
              (Printf.sprintf "{%s} n'est pas dans le groupe de {%s}"
                  (string_of_vertex m) (string_of_vertex head))
              (g = find)))
    vertices

let stupid_monoid () = (* setup *)
  (Board_init.self_init ();
    let v = { pass = false; nb = 7; letter = 'D'; } in
    let m = { color = Black; vert = v; }
    in
    (* tests *)
    (Engine.play m;
      test_count ~expected: 1;
      test_monoids ~vertices: [ v ];
      test_liberty ~expected: 4 ~vertices: [ v ]))

let multiples_monoids () = (* setup *)
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 7; letter = 'D'; }
    
    and v2 = { pass = false; nb = 4; letter = 'K'; }
    and v3 = { pass = false; nb = 8; letter = 'J'; }
    and v4 = { pass = false; nb = 5; letter = 'F'; }
    and v5 = { pass = false; nb = 7; letter = 'F'; }
    
    and v6 = { pass = false; nb = 7; letter = 'H'; } in
    let m1 = { color = Black; vert = v1; }
    
    and m2 = { color = White; vert = v2; }
    and m3 = { color = Black; vert = v3; }
    and m4 = { color = White; vert = v4; }
    and m5 = { color = Black; vert = v5; }
    
    and m6 = { color = White; vert = v6; } in
    let l = [ v1; v2; v3; v4; v5; v6 ]
    in
    (* tests *)
    (Engine.play m1;
      Engine.play m2;
      Engine.play m3;
      Engine.play m4;
      Engine.play m5;
      Engine.play m6;
      test_count ~expected: 6;
      test_monoids ~vertices: l))

let large_multiple_monoids () =
  let count = ref 1 in
  let next_id id = id + 2 in
  let fill_board () =
    let my_id = ref 0
    in
    (Engine.play { color = Black; vert = vertex_of_id !my_id; };
      while !my_id < 166 do my_id := next_id !my_id;
        Engine.play { color = Black; vert = vertex_of_id !my_id; };
        incr count done)
  in
  (* setup *)
  (Board_init.self_init ();
    fill_board ();
    (* tests *)
    test_count ~expected: !count)

let simple_allongement () = (* setup *)
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 7; letter = 'F'; }
    
    and v2 = { pass = false; nb = 7; letter = 'G'; }
    in
    (* tests *)
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = Black; vert = v2; };
      test_count ~expected: 1;
      are_in_same_group ~color: Black ~vertices: [ v1; v2 ];
      test_liberty ~expected: 6 ~vertices: [v1; v2] ))

let zigzag_allongement () = (* setup *)
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 7; letter = 'D'; }
    
    and v2 = { pass = false; nb = 8; letter = 'D'; }
    and v3 = { pass = false; nb = 8; letter = 'E'; }
    and v4 = { pass = false; nb = 9; letter = 'E'; }
    
    and v5 = { pass = false; nb = 9; letter = 'F'; }
    in
    (* tests *)
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = Black; vert = v2; };
      Engine.play { color = Black; vert = v3; };
      Engine.play { color = Black; vert = v4; };
      Engine.play { color = Black; vert = v5; };
      Playing.play_v ~vertices: [ v1; v2; v3; v4; v5 ];
      test_count ~expected: 1;
      are_in_same_group ~color: Black ~vertices: [ v1; v2; v3; v4; v5 ];
      test_liberty ~expected: 9 ~vertices:[v1; v2; v3; v4; v5]))

let reverse_allongement () = (* setup *)
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 7; letter = 'D'; }
    
    and v2 = { pass = false; nb = 8; letter = 'D'; }
    
    and v3 = { pass = false; nb = 6; letter = 'D'; }
    in
    (* tests (Playing.play_v ~vertices: [ v1; v2; v3 ]; *)
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = Black; vert = v2; };
      Engine.play { color = Black; vert = v3; };
      test_count ~expected: 1;
      are_in_same_group ~color: Black ~vertices: [ v1; v2; v3 ];
      test_liberty ~expected: 8 ~vertices:[v1; v2; v3]))

let test_fusion () = (* setup *)
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 7; letter = 'D'; }
    
    and v2 = { pass = false; nb = 6; letter = 'D'; }
    and v3 = { pass = false; nb = 6; letter = 'G'; }
    and v4 = { pass = false; nb = 5; letter = 'G'; }
    and v5 = { pass = false; nb = 4; letter = 'D'; }
    and v6 = { pass = false; nb = 4; letter = 'E'; }
    and v7 = { pass = false; nb = 4; letter = 'F'; }
    and v8 = { pass = false; nb = 4; letter = 'H'; }
    and v9 = { pass = false; nb = 4; letter = 'J'; }
    and v10 = { pass = false; nb = 4; letter = 'K'; }
    and v11 = { pass = false; nb = 5; letter = 'L'; }
    and v12 = { pass = false; nb = 6; letter = 'L'; }
    and v13 = { pass = false; nb = 7; letter = 'L'; }
    and v14 = { pass = false; nb = 5; letter = 'D'; }
    and v15 = { pass = false; nb = 4; letter = 'G'; }
    
    and v16 = { pass = false; nb = 4; letter = 'L'; }
    in
    (* tests *)
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = Black; vert = v2; };
      Engine.play { color = Black; vert = v3; };
      Engine.play { color = Black; vert = v4; };
      Engine.play { color = Black; vert = v5; };
      Engine.play { color = Black; vert = v6; };
      Engine.play { color = Black; vert = v7; };
      Engine.play { color = Black; vert = v8; };
      Engine.play { color = Black; vert = v9; };
      Engine.play { color = Black; vert = v10; };
      Engine.play { color = Black; vert = v11; };
      Engine.play { color = Black; vert = v12; };
      Engine.play { color = Black; vert = v13; };
      test_count ~expected: 5;
      Engine.play { color = Black; vert = v14; };
      test_count ~expected: 4;
      Engine.play { color = Black; vert = v15; };
      test_count ~expected: 2;
      Engine.play { color = Black; vert = v16; };
      test_count ~expected: 1;
      are_in_same_group ~color: Black ~vertices: [ v1; v16 ]))

let simple_couleurs () =
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 5; letter = 'F'; }
    
    and v2 = { pass = false; nb = 6; letter = 'D'; }
    in
    (* tests *)
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = White; vert = v2; };
      test_count ~expected: 2))

let zigzag_color () =
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 7; letter = 'D'; }
    
    and v2 = { pass = false; nb = 8; letter = 'D'; }
    and v3 = { pass = false; nb = 8; letter = 'E'; }
    and v4 = { pass = false; nb = 9; letter = 'E'; }
    
    and v5 = { pass = false; nb = 9; letter = 'F'; }
    in
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = Black; vert = v2; };
      Engine.play { color = Black; vert = v3; };
      Engine.play { color = Black; vert = v4; };
      Engine.play { color = Black; vert = v5; };
      test_count ~expected: 1;
      let v6 = { pass = false; nb = 7; letter = 'G'; }
      
      and v7 = { pass = false; nb = 8; letter = 'G'; }
      and v8 = { pass = false; nb = 8; letter = 'H'; }
      and v9 = { pass = false; nb = 9; letter = 'H'; }
      
      and v10 = { pass = false; nb = 9; letter = 'J'; }
      in
      (Engine.play { color = Black; vert = v6; };
        Engine.play { color = Black; vert = v7; };
        Engine.play { color = Black; vert = v8; };
        Engine.play { color = Black; vert = v9; };
        Engine.play { color = Black; vert = v10; };
        test_count ~expected: 2)))

let oeil () =
  (Board_init.self_init ();
    let v1 = { pass = false; nb = 6; letter = 'G'; }
    
    and v2 = { pass = false; nb = 8; letter = 'G'; }
    and v3 = { pass = false; nb = 7; letter = 'H'; }
    and v4 = { pass = false; nb = 7; letter = 'G'; }
    
    and v5 = { pass = false; nb = 7; letter = 'F'; }
    in
    (Engine.play { color = Black; vert = v1; };
      Engine.play { color = Black; vert = v2; };
      Engine.play { color = Black; vert = v3; };
      Engine.play { color = White; vert = v4; };
      test_count ~expected: 4;
      Engine.play { color = Black; vert = v5; };
      test_count ~expected: 4))

let square () =
  Board_init.self_init ();
  let v1 = { pass = false; nb = 9; letter = 'E'; }
  and v2 = { pass = false; nb = 9; letter = 'F'; }
  and v3 = { pass = false; nb = 9; letter = 'G'; }
  and v4 = { pass = false; nb = 9; letter = 'H'; }
  and v5 = { pass = false; nb = 8; letter = 'H'; }
  and v6 = { pass = false; nb = 7; letter = 'H'; }
  and v7 = { pass = false; nb = 6; letter = 'H'; }
  and v8 = { pass = false; nb = 6; letter = 'G'; }
  and v9 = { pass = false; nb = 6; letter = 'F'; }
  and v10 = { pass = false; nb = 6; letter = 'E'; }
  and v11 = { pass = false; nb = 7; letter = 'E'; }
  and v12 = { pass = false; nb = 8; letter = 'E'; }
  and v13 = { pass = false; nb = 8; letter = 'F'; }
  and v14 = { pass = false; nb = 7; letter = 'F'; }
  and v15 = { pass = false; nb = 8; letter = 'H'; }
  and v16 = { pass = false; nb = 7; letter = 'G'; }
  in
  Engine.play { color = Black; vert = v1; };
  Engine.play { color = Black; vert = v2; };
  Engine.play { color = Black; vert = v3; };
  Engine.play { color = Black; vert = v4; };
  test_count ~expected: 1;
  Engine.play { color = Black; vert = v5; };
  Engine.play { color = Black; vert = v6; };
  Engine.play { color = Black; vert = v7; };
  Engine.play { color = Black; vert = v8; };
  test_count ~expected: 1;
  Engine.play { color = Black; vert = v9; };
  Engine.play { color = Black; vert = v10; };
  Engine.play { color = Black; vert = v11; };
  Engine.play { color = Black; vert = v12; };
  test_count ~expected: 1;
  test_liberty ~expected: 20 ~vertices: [v1];
  Engine.play { color = White; vert = v13; };
  Engine.play { color = White; vert = v14; };
  test_count ~expected: 2
  (* test_liberty ~expected: 2 ~vertices: [v13]; *)
  (* test_liberty ~expected: 18 ~vertices: [v1]  *)
  (* Engine.play { color = Black; vert = v15; };  *)
  (* Engine.play { color = Black; vert = v16; };  *)
  (*  test_liberty ~expected: 13 ~vertices: [v1]; *)
  (* test_count ~expected: 2;                     *)
  (*  test_liberty ~expected: 13 ~vertices: [v1]  *)
                                               

let suite () =
  "groupes" >:::
  [ "groupes monoides" >:::
  [ "stupides" >:: stupid_monoid; "multiples" >:: multiples_monoids;
  "large" >:: large_multiple_monoids ];
  "allongement de groupes" >:::
  [ "simple" >:: simple_allongement; "zigzag" >:: zigzag_allongement;
  "renversement" >:: reverse_allongement;
  "fusion de deux
  groupes" >:: test_fusion ];
  "multicolores" >:::
  [ "simple couleurs" >:: simple_couleurs;
  "zigzig color" >:: zigzag_color ];
  "attaque" >::: [ "oeil" >:: oeil;"square" >:: square ] ]
