(******************************************************************************)
(* OASIS: architecture for building OCaml libraries and applications          *)
(*                                                                            *)
(* Copyright (C) 2011-2013, Sylvain Le Gall                                   *)
(* Copyright (C) 2008-2011, OCamlCore SARL                                    *)
(*                                                                            *)
(* This library is free software; you can redistribute it and/or modify it    *)
(* under the terms of the GNU Lesser General Public License as published by   *)
(* the Free Software Foundation; either version 2.1 of the License, or (at    *)
(* your option) any later version, with the OCaml static compilation          *)
(* exception.                                                                 *)
(*                                                                            *)
(* This library is distributed in the hope that it will be useful, but        *)
(* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY *)
(* or FITNESS FOR A PARTICULAR PURPOSE. See the file COPYING for more         *)
(* details.                                                                   *)
(*                                                                            *)
(* You should have received a copy of the GNU Lesser General Public License   *)
(* along with this library; if not, write to the Free Software Foundation,    *)
(* Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA              *)
(******************************************************************************)


(** BaseLog tests
    @author Sylvain Le Gall
  *)


open OUnit2
open TestCommon
open BaseLog
open OASISContext


let tests =
  let test_of_vector (nm, f) =
    nm >::
    (fun test_ctxt ->
       let tmpdir = bracket_tmpdir test_ctxt in
       let ctxt =
         {(oasis_ctxt test_ctxt) with
          srcfs = new OASISFileSystem.host_fs tmpdir}
       in
       f ctxt)
  in
  let assert_equal_log ~ctxt msg exp =
    assert_equal
      ~msg
      ~printer:(fun lst ->
                  String.concat ", "
                    (List.map
                       (fun (e, d) -> Printf.sprintf "%S %S" e d)
                       lst))
      exp
      (load ~ctxt ())
  in

    "BaseLog" >:::
    (List.map test_of_vector
       [
         "normal",
         (fun ctxt ->
            register ~ctxt "toto" "mytoto";
            assert_bool
              "Event toto exists"
              (exists ~ctxt "toto" "mytoto");
            unregister ~ctxt "toto" "mytoto";
            assert_bool
              "Event toto doesn't exist"
              (not (exists ~ctxt "toto" "mytoto")));

         "double",
         (fun ctxt ->
            register ~ctxt "toto" "mytoto";
            assert_equal_log ~ctxt
              "Log contains 1 element"
              ["toto", "mytoto"];
            register ~ctxt "toto" "mytoto";
            assert_equal_log ~ctxt
              "Log still contains 1 element"
              ["toto", "mytoto"])
       ])
